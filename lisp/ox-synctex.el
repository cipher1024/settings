;;; ox-synctex.el --- Synctex functionality for org LaTeX export -*- lexical-binding: t-*-

;; Copyright (C) 2013 Aaron Ecay

;; Author: Aaron Ecay <address@hidden>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This code provides synctex support for org mode export to latex.
;; To activate, execute (ox-synctex-activate).  To deactivate,
;; (ox-synctex-deactivate)

;; TODOs:
;; - support multi-file documents through #+include and friends
;; - do something so that clicks on a minted source code block go to
;;   the .org file and not the .pyg intermediate
;; - ...

;;; Code:

;;;; Internal functions and variable

(defvar ox-synctex--concordance nil
  "The concordance resulting from the last export operation.")

(defun ox-synctex--read-concordance (concordance src-line)
  "Get the output line number from CONCORDANCE for input line SRC-LINE."
  ;; TODO: not robust against malformed concordances
  (while (and (caadr concordance)
              (<= (caadr concordance) src-line))
    (setq concordance (cdr concordance)))
  (cdar concordance))

(defun ox-synctex--propertize-buffer ()
  "Put line-number text properties on a buffer.

Each line gets a org-line-num-pre property, which is its line
number in the buffer.  When export operations change the buffer,
the text property will still reflect the original state of affairs."
  (save-restriction
    (widen)
    (while (= 0 (forward-line 1))
      (put-text-property (point) (point-at-eol)
                        'ox-synctex-line-num
                        (line-number-at-pos)))))

(defun ox-synctex--line-number-at-pos (pos)
  "Return the buffer line number at POS, widening if necessary.

This function first looks for text properties set by
`ox-synctex--propertize-buffer' which allow it to return an
accurate line number in a buffer copy modified during export.  It
falls back to the usual method of calculating line numbers if no
text properties are found."
  (or (get-text-property pos 'ox-synctex-line-num)
      (save-excursion
        (widen)
        (line-number-at-pos pos))))

(defun ox-synctex--add-line-to-element (element)
  "Add begin and end line numbers to an element as returned by `org-element'."
  (let* ((plist (cadr element))
        (beg (plist-get plist :begin))
        (end (plist-get plist :end)))
    (and beg (plist-put plist :begin-line (ox-synctex--line-number-at-pos
beg)))
    (and end (plist-put plist :end-line (ox-synctex--line-number-at-pos end)))
    element))


(defun ox-synctex--propertize-string (data string)
  "Add line number text properties to STRING, based on DATA.

The function works by copying the properties added by
`ox-synctex--add-line-to-element' to the string.  This will allow
the construction of a concordance from the exported string."
  (let ((len (length string)))
    (when (> len 1)
      (put-text-property 0 1 'org-line-num
                         (org-element-property :begin-line data)
                         string)
      (put-text-property (1- len) len 'org-line-num
                         (org-element-property :end-line data)
                         string)))
  string)

(defun ox-synctex--build-concordance ()
  "Build a concordance, based on text properties added by
`ox-synctex--propertize-string' and accumulated in in an export
result buffer.

Has the form ((OUT-LINE . IN-LINE) ...)"
  (save-excursion
    (let ((res '())
          next)
      (goto-char (point-min))
      (while (setq next (next-single-property-change (point) 'org-line-num))
        (goto-char next)
       (let ((ln (get-text-property (point) 'org-line-num)))
         ;; TODO: `ln' should never be nil, but sometimes it is.  For
         ;; now, we hack around that with this `when'.
         (when ln
           (setq res (cons (cons (line-number-at-pos) ln)
                           res))))
        (forward-char 1))
      (setq res (nreverse res))
      (setq next res)
      (while (cdr next)
        (if (equal (caar next) (caadr next))
            (setcdr next (cddr next))
          (setq next (cdr next))))
      res)))

(defun ox-synctex--patch-synctex (file)
  "Patch the synctex file resulting from the last export
operation, using the information stored in
`ox-synctex--concordance'."
  (let* ((file-base (file-name-nondirectory
                    (replace-regexp-in-string "\\.tex\\'" "." file)))
        (synctex-file (concat file-base "synctex.gz")))
    (cond
     ((not ox-synctex--concordance)
      (message "No concordance, not patching."))
     ((not (file-exists-p synctex-file))
      (message "No synctex file found, not patching."))
     (t
      (let* ((conc ox-synctex--concordance)
            (buf (find-file-noselect synctex-file)))
       (with-current-buffer buf
         (let ((max-index 0)
               the-index extra-path new-index)
           (goto-char (point-min))
           (while (re-search-forward "^Input:\\([0-9]+\\):" nil t)
             (setq max-index (max max-index (string-to-number (match-string
1)))))
           (setq new-index (number-to-string (1+ max-index)))
           (goto-char (point-min))
           (when (re-search-forward (concat "^Input:\\([0-9]+\\):\\(.*\\)"
                                            (regexp-quote file-base) "tex$")
                                    nil t)
             (setq the-index (string-to-number (match-string 1)))
             (setq extra-path (match-string 2))
             (goto-char (line-end-position))
             (insert (format "\nInput:%s:%s%sorg" new-index extra-path
file-base)))
           (goto-char (point-min))
           (while (re-search-forward (format
"^[vhxkgr$[()]\\(%s\\),\\([0-9]+\\):"
                                             the-index)
                                     nil t)
             (let ((new-line (ox-synctex--read-concordance
                              ox-synctex--concordance
                              (string-to-number (match-string 2)))))
               (when new-line
                 (replace-match new-index nil t nil 1)
                 (replace-match (int-to-string new-line)
                                nil t nil 2))))
           (save-buffer)))
       (kill-buffer buf))))))

;;;; Hooks and advice

(defun ox-synctex--before-processing-hook (&rest ignore)
  (ox-synctex--propertize-buffer))

(defconst ox-synctex--parsers-to-patch
  (append org-element-greater-elements org-element-all-elements))

;;; Patch all `org-element' parsers to add line number info to their
;;; return values.
(dolist (parser ox-synctex--parsers-to-patch)
  (let ((parser-fn (intern (format "org-element-%s-parser"
                                  (symbol-name parser)))))
    (eval `(defadvice ,parser-fn (around ox-synctex)
            "Advice added by `ox-synctex'."
            ad-do-it
            (setq ad-return-value (ox-synctex--add-line-to-element
                                   ad-return-value))))))

;;; Patch element->string conversion to carry through the line numbers
;;; added above
(defadvice org-export-transcoder (around ox-synctex)
  ad-do-it
  (when (and ad-return-value
            (org-export-derived-backend-p
             (plist-get (ad-get-arg 1) :back-end)
             'latex))
    (setq ad-return-value
         `(lambda (data contents &optional info)
            (ox-synctex--propertize-string
             data
             (if info
                 (,ad-return-value data contents info)
               ;; The plain text transcoder takes only 2 arguments;
               ;; here contents is really info.  I couldn't find a
               ;; better way to inspect the arity of elisp
               ;; functions...?
               (,ad-return-value data contents)))))))

;;; Patch to build the concordance once we have the export result.  We
;;; need to hack around the fact that the original function strips
;;; text properties from its return value which we need.
(defadvice org-export-as (around ox-synctex)
  (cl-letf (((symbol-function 'org-no-properties)
            (lambda (s &optional _restricted) s)))
    ad-do-it)
  (when (org-export-derived-backend-p (ad-get-arg 0) 'latex)
    (with-temp-buffer
      (insert ad-return-value)
      (setq ox-synctex--concordance (ox-synctex--build-concordance))))
  (setq ad-return-value (org-no-properties ad-return-value)))

;;; Actually do the patching after compilation
(defadvice org-latex-compile (around ox-synctex)
  ad-do-it
  (ox-synctex--patch-synctex (ad-get-arg 0))
  ;; Some PDF viewers (eg evince) don't notice changes to the synctex
  ;; file, so we need to poke them to reload the pdf after we've
  ;; finished changing it.
  (call-process dired-touch-program nil nil nil
               (replace-regexp-in-string "\\.tex\\'" "." (ad-get-arg 0))))

;;;; User-facing functions

(defun ox-synctex-activate ()
  (interactive)
  (add-hook 'org-export-before-processing-hook
            #'ox-synctex--before-processing-hook)
  (ad-activate-regexp "ox-synctex"))

(defun ox-synctex-deactivate ()
  (interactive)
  (remove-hook 'org-export-before-processing-hook
              #'ox-synctex--before-processing-hook)
  (ad-deactivate-regexp "ox-synctex"))

(provide 'ox-synctex)

;;; ox-synctex.el ends here
