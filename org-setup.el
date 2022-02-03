
;; ;; ;; (unload-feature 'org-ref t)
;; ;; ;; (unload-feature 'org-ref-url-utils t)
;; ;; ;; (unload-feature 'doi-utils t)
;; ;; ;; (unload-feature 'org-ref-utils t)
;; ;; ;; (unload-feature 'org-ref-pdf t)
(require 'rx)
(require 'org-inlinetask)
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package org
  :ensure t)
(use-package auctex
  :defer t
  :ensure t)
;; (use-package org-ref
;;   :ensure t)
(use-package cdlatex
  :ensure t)

(require 'org)
(require 'latex)
;; (require 'doi-utils)
;; (require 'ox-synctex)

;; ;; (mapc 'print org-ref-cite-types)
(use-package pdf-tools
  :ensure t)
;; (require 'org-ref-pdf)
;; (require 'org-ref-url-utils)
;; (require 'org-ref-bibtex)
;; (require 'org-ref-latex)
;; (require 'helm-bibtex)
;; (require 'org-ref-arxiv)
;; ;; (require 'org-ref-pubmed)
;; ;; (require 'org-ref-isbn)
;; ;; (require 'org-ref-wos)
;; (require 'org-ref-scopus)
;; (use-package x2bib
;;   :ensure t)
;; (require 'org-exp)
;; org-icalendar
;; (print "bar")
;; ;; ;; (define-key global-map "\C-cl" 'org-store-link)
;; ;; ;; (define-key global-map "\C-ca" 'org-agenda)
;; ;; ;; (setq org-log-done t)
;; ;; ;; ;; (org-babel-load-file "org-ref.org")
;; ;; ;; (add-to-list 'package-archives
;; ;; ;; 	     '("melpa" . "http://melpa.org/packages/") t)
;; ;; ;; ;; (add-hook 'org-mode-hook 'turn-on-org-cdlatex)
;; ;; ;; ;; (add-to-list 'org-latex-packages-alist '("" "amsthm"))
(add-hook 'org-mode-hook 'turn-on-org-cdlatex)
(add-hook 'org-mode-hook 'auto-fill-mode)
(add-hook 'org-mode-hook 'set-truncate-lines)
(add-hook 'org-mode-hook 'latex-math-mode)
;; (remove-hook 'org-mode-hook 'latex-math-mode)

(defun my-org-mode-hook ()
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
(add-hook 'org-mode-hook #'my-org-mode-hook)

;; ;; ;; If you use helm-bibtex as the citation key completion method you should set these variables too.

;; ;; ;; (setq bibtex-completion-bibliography "~/Dropbox/bibliography/references.bib"
;; ;; ;;       bibtex-completion-library-path "~/Dropbox/bibliography/bibtex-pdfs/"
;; ;; ;;       bibtex-completion-notes-path "~/Dropbox/bibliography/helm-bibtex-notes/")

;; ;; ;; open pdf with system pdf viewer (works on mac)
;; ;; (setq bibtex-completion-pdf-open-function
;; ;;   (lambda (fpath)
;; ;;     (start-process " /Applications/Skim.app/Contents/MacOS/Skim" "--dired" fpath)))

;; ;; ;; ;; alternative
;; ;; ;; ;; (setq bibtex-completion-pdf-open-function 'org-open-file)

;; (setenv "PKG_CONFIG_PATH" "/usr/local/Cellar/zlib/1.2.8/lib/pkgconfig:/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig")

(add-to-list 'org-modules 'org-mac-iCal)

;; (goto-char (line-end-position)) ; aloo too

(setq org-latex-default-packages-alist
      (seq-filter (lambda (x) (not (and (listp x) (equal (cadr x) "fixltx2e"))))
                  org-latex-default-packages-alist))


(defmacro temporary-changes (&rest body)
  ;; (let ((saved (make-symbol "undo-list")))
  `(let ((buffer-undo-list nil))
     ,@body
     (primitive-undo (length buffer-undo-list) buffer-undo-list)))

(defmacro trace (stuff)
  (let ((val (make-symbol "val")))
    `(let ((,val ,stuff))
       (print (quote ,stuff))
       (print ,val))))

(add-hook 'org-agenda-cleanup-fancy-diary-hook
          (lambda ()
            (goto-char (point-min))
            (save-excursion
              (while (re-search-forward "^[a-z]" nil t)
                (goto-char (match-beginning 0))
                (insert "0:00-24:00 ")))
            (while (re-search-forward "^ [a-z]" nil t)
              (goto-char (match-beginning 0))
              (save-excursion
                (re-search-backward "^[0-9]+:[0-9]+-[0-9]+:[0-9]+ " nil t))
              (insert (match-string 0)))))

;; (defun bind-pdf-compile-key ()
;;   (interactive)
;;   (local-set-key (kbd "C-c C-c") 'org-latex-export-to-pdf))
;; (local-unset-key "C-c C-c")

;; (add-hook 'org-mode-hook 'bind-pdf-compile-key)
;; (remove-hook 'org-mode-hook 'bind-pdf-compile-key)

(use-package which-key
	:ensure t
	:config
	(which-key-mode))

;; (use-package org-ref
;; 	:ensure t
;; 	:after org)

;; (use-package org-latex
;;   :ensure t)
;; (require 'org-ref)

;; ;; (require 'nist-webbook)
;; (require 'org-ref-scifinder)
;; ;; (require 'org-ref-worldcat)
(require 'ox-latex)
;; ;; ;; (setq org-ref-completion-library 'org-ref-ivy-cite)
;; ;; ;; (unload-feature 'org-ref t)


(add-to-list 'org-latex-classes
             '("thesis"
               "\\documentclass[12pt]{report}"
               ("\\chapter{%s}" . "\\chapter*{%s}")
	       ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
	       ))
;; see org-ref for use of these variables

;; ;; open pdf with system pdf viewer (works on mac)
(setq bibtex-completion-pdf-open-function
  (lambda (fpath)
    (start-process "open" "*open*" "open" fpath)))

;; ;; ;; ;; alternative
;; ;; ;; ;; (setq bibtex-completion-pdf-open-function 'org-open-file)

;; ;; (setf (cdr (assoc 'org-mode bibtex-completion-format-citation-functions)) 'org-ref-format-citation)

(setq org-latex-prefer-user-labels t)

(setq reftex-default-bibliography '("/Users/simon/org-mode/thesis/ref.bib"))

(setq org-ref-bibliography-notes "/Users/simon/Dropbox/bibliography/notes.org"
      org-ref-default-bibliography '("/Users/simon/org-mode/thesis/ref.bib")
      org-ref-pdf-directory "/Users/simon/Dropbox/bibliography/bibtex-pdfs/")

(setq bibtex-completion-bibliography "/Users/simon/org-mode/thesis/ref.bib"
      bibtex-completion-library-path "/Users/simon/Dropbox/bibliography/bibtex-pdfs/"
      bibtex-completion-notes-path "/Users/simon/Dropbox/bibliography/helm-bibtex-notes")

(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
	"bibtex %b"
	"pdflatex -interaction nonstopmode -output-directory %o %f"
	"pdflatex -interaction nonstopmode -output-directory %o %f"))

(setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5)

(defun skim (&rest doc)
  (shell-command
   (format "/Applications/Skim.app/Contents/MacOS/Skim %s &"
	   (string-join doc " "))))

(defun org-pdf-find-next-line-aux (cur-ln)
  (re-search-forward "^l\\.\\([0-9]+\\)")
  (let ((ln (string-to-number (match-string-no-properties 1))))
    (if (<  cur-ln ln)
        ln
      (org-pdf-find-next-line-aux cur-ln))))

(defun org-pdf-find-next-line ()
  (let ((ln (line-number-at-pos)))
    (with-current-buffer "*Org PDF LaTeX Output*"
      (goto-char (point-min))
      (org-pdf-find-next-line-aux ln))))

(defun next-org-pdf-error-message ()
  (interactive)
  (goto-line 1)
  (re-search-forward "^l\\.\\([0-9]+\\)"))

(defun next-org-pdf-error ()
  (interactive)
  (let* ((ln (org-pdf-find-next-line)))
    (goto-line ln)))

(setq current-tex-buffer "/Users/simon/org-mode/thesis/structure.tex")

(defun set-current-tex-buffer ()
  (interactive)
  (setq current-tex-buffer (buffer-file-name)))

(defun next-org-pdf-error-struct ()
  (interactive)
  (find-file current-tex-buffer)
  (goto-line 1)
  (next-org-pdf-error))

(defun org-pdf-compile-struct ()
  (interactive)
  (with-current-buffer (find-file-noselect "/Users/simon/org-mode/thesis/structure.org")
    (org-latex-export-to-pdf)))

;; ;; (key-chord-define-global "kk" 'org-ref-cite-hydra/body)

;; (doi-utils-def-bibtex-type
;;  article ("journal-article" "article-journal" "paper-conference"
;; 	  "chapter" "report" "article" "inproceedings")
;;  author title journal year volume number pages doi url)

;; ;; (setq org-publish-project-alist
;; ;;       '(("orgfiles"
;; ;; 	 :base-directory "~/org-mode/thesis/"
;; ;; 	 :base-extension "org"
;; ;; 	 :publishing-directory "~/org-mode/thesis/pdf/"
;; ;; 	 :publishing-function org-latex-publish-to-pdf
;; ;; 	 :exclude
;; ;; 	 :headline-levels 3
;; ;; 	 :section-numbers nil
;; ;; 	 :with-toc nil)))

;; ;; (auto-fill-mode)

;; ;; (defun my/org-ref-open-pdf-at-point ()
;; ;;   "Open the pdf for bibtex key under point if it exists."
;; ;;   (interactive)
;; ;;   (print "here")
;; ;;   (let* ((results (org-ref-get-bibtex-key-and-file))
;; ;;          (key (car results))
;; ;;          (pdf-file (funcall org-ref-get-pdf-filename-function key))
;; ;; 	 (pdf-other (bibtex-completion-find-pdf key)))
;; ;;     (print pdf-file)
;; ;;     (print pdf-other)
;; ;;     (cond ((file-exists-p pdf-file)
;; ;;        (org-open-file pdf-file))
;; ;;       (pdf-other
;; ;;        (org-open-file pdf-other))
;; ;;       (message "No PDF found for %s" key))))
;; ;; (setq org-ref-open-pdf-function 'my/org-ref-open-pdf-at-point)
;; ;; (setq helm-bibtex-pdf-field "File")
;; ;; (progn (unload-feature 'org-ref t) (eval-buffer))

;; (defun concat-map (f xs)
;;   (if (null xs)
;;       nil
;;       (append (apply f (list (car xs)))
;; 	      (concat-map f (cdr xs)))))

;; ;; #print axioms : display assumed axioms

;; ;; (defun left-most-windows ()
;; ;;   (mapcar 'symbol-value
;; ;; 	  (seq-filter
;; ;; 	   'boundp
;; ;; 	   (list 'first-window 'second-window))))

;; ;; (defun thesis-source-p (buffer)
;; ;;   (when-let ((fn (buffer-file-name buffer)))
;; ;;     (and (or (equal (file-name-extension fn) "org")
;; ;; 	     (equal (file-name-extension fn) "bib"))
;; ;; 	 (consp (cl-intersection (left-most-windows)
;; ;; 				 (get-buffer-window-list buffer)
;; ;; 				 :test 'equal)))))

;; ;; (defun kill-thesis-sources ()
;; ;;   (mapc 'kill-buffer
;; ;; 	(seq-filter 'thesis-source-p (buffer-list))))


;;   "User-defined entities used in Org-mode to produce special characters.
;; Each entry in this list is a list of strings.  It associates the name
;; of the entity that can be inserted into an Org file as \\name with the
;; appropriate replacements for the different export backends.  The order
;; of the fields is the following

;; name                 As a string, without the leading backslash
;; LaTeX replacement    In ready LaTeX, no further processing will take place
;; LaTeX mathp          A Boolean, either t or nil.  t if this entity needs
;;                      to be in math mode.
;; HTML replacement     In ready HTML, no further processing will take place.
;;                      Usually this will be an &...; entity.
;; ASCII replacement    Plain ASCII, no extensions.  Symbols that cannot be
;;                      represented will be left as they are, but see the.
;;                      variable `org-entities-ascii-explanatory'.
;; Latin1 replacement   Use the special characters available in latin1.
;; utf-8 replacement    Use the special characters available in utf-8.

;; If you define new entities here that require specific LaTeX
;; packages to be loaded, add these packages to `org-latex-packages-alist'."
;;   :group 'org-entities
;;   :version "24.1"
;;   :type '(repeat
;; 	  (list
;; 	   (string :tag "name  ")
;; 	   (string :tag "LaTeX ")
;; 	   (boolean :tag "Require LaTeX math?")
;; 	   (string :tag "HTML  ")
;; 	   (string :tag "ASCII ")
;; 	   (string :tag "Latin1")
;; 	   (string :tag "utf-8 "))))
(defconst org-entities-user
  '( ("Diamond" "\\Diamond" t "&Diamond" "Diamond" "Diamond" "⃟")
     ("Box" "\\Box " t "&Box" "Box" "Box" "☐")
     ("tlaleadsto" "\\tlaleadsto" t "&~>" "~>" "~>" "⇝")
     ("mapsto" "\\mapsto" t "&|->" "|->" "|->" "↦")
     ("nat" "\\nat" t "&nat" "nat" "nat" "ℕ")
     ("forall2" "\\A" t "&forall;" "[for all]" "[for all]" "∀")
     ("exist2" "\\E" t "&exist;" "[there exists]" "[there exists]" "∃")
     ("exist3" "\\EE" t "&exist;" "[there exists]" "[there exists]" "*∃*")
     ("vdash" "\\vdash " t "&vdash;" "[vdash]" "[vdash]" "⊢")
     ("models" "\\models " t "&#8872;" "[models]" "[models]" "⊨")
     ("monus" "\\monus " t "&#2238;" "[monus]" "[monus]" "∸")
     ;; ("OneSpace" "\\1" t "&Box" "Box" "" "")
     ) )

;; lpp/invoke-pdf-latex-command

(make-local-variable 'org-root-doc)

(defun select-root-directory (root)
  (setq default-directory (file-name-as-directory (find-root-dir-safe root))))

;; (defun org-export-and-compile ()
;;   (org-latex-export-to-latex)
;;   (latex-preview-pane-update))

;; (defun org-preview-pane-mode ()
;;   (latex-preview-pane-mode)
;;   (setq-local latex-preview-pane-multifile-mode  'auctex)
;;   (setq-local lpp-TeX-master
;; 	      (replace-regexp-in-string "\.org$" ".tex"
;; 					org-root-doc))
;;   (setq-local TeX-master lpp-TeX-master)
;;   ;; (setq-local pdf-latex-command "latexmk")
;;   (remove-hook 'after-save-hook 'latex-preview-pane-update)
;;   (add-hook 'after-save-hook 'org-export-and-compile t t))

;; (require 'tex
;; (TeX-revert-document-buffer)

(defun setup-todo-list ()
  (add-to-list 'org-agenda-files (buffer-file-name))
  (add-hook 'kill-buffer-hook
	    (lambda ()
	      (setq org-agenda-files (remove (buffer-file-name) org-agenda-files)))
	    t t))

;; (require 'org-projectile)

;; org-projectile-todo-files

(setq org-auto-sync-pdf t)

(defun org-toggle-auto-sync-pdf ()
  (interactive)
  (setq-local org-auto-sync-pdf (not org-auto-sync-pdf)))

(defun org-subdocument-of (root)
  (select-root-directory root)

  ;; (latex-preview-update)
  ;; (org-preview-pane-mode root)
  (setq org-root-doc root)
  (find-file-noselect org-root-doc)
  ;; (org-latex-export-parent-to-latex)
  (when (file-exists-p (set-extension org-root-doc ".pdf"))
    (display-pdf (set-extension org-root-doc ".pdf"))
    (org-sync-pdf))
  (setup-todo-list)
  (setq-local org-auto-sync-pdf nil)
  ;; (print "before")
  ;; (remove-hook 'after-save-hook 'latex-preview-pane-update)
  (add-hook 'before-save-hook 'org-latex-export-parent-and-sync t t)
  ;; (remove-hook 'before-save-hook 'org-latex-export-parent-and-sync t t)
  ;; (print "after")
  ;; (add-hook 'after-save-hook 'latex-preview-pane-update nil 'make-it-local)
  ;; (add-hook 'after-save-hook 'touch-file t t)
  (when (eq major-mode 'org-mode)
    (org-preview-latex-fragment)))

(defun touch-file ()
  "Force modification of current file, unless already modified."
  (interactive)
  (if (and (verify-visited-file-modtime (current-buffer))
           (not (buffer-modified-p)))
      (progn
	(shell-command (concat "touch " (shell-quote-argument (buffer-file-name))))
	(clear-visited-file-modtime))))

(defun org-install-stylesheets ()
  (add-hook 'after-save-hook
	    (lambda ()
	      (select-root-directory org-root-doc)
	      (start-process "install-stylesheets-macosx.hs"
			     (get-buffer-create "*install-stylesheets-macosx*")
			     "stack" "install-stylesheets-macosx.hs"))
	    nil t))

;; (defun org-latex-export-parent-to-latex ()
;;   (with-current-buffer (or (get-buffer org-root-doc)
;; 			   (find-file-noselect org-root-doc))
;;     (org-latex-export-to-latex))
;;   (latex-preview-pane-update))

(defun org-latex-export-parent-to-latex ()
  (with-current-buffer (find-file-noselect org-root-doc)
    (when-let (tex (get-file-buffer (set-extension org-root-doc ".tex")))
      (kill-buffer tex))
    (org-latex-export-to-pdf)
    ;; (org-latex-export-to-latex)
    ;; (compile-latex (set-extension org-root-doc ".tex"))
    ))

(defun org-latex-export-parent-and-sync ()
  (if org-auto-sync-pdf
      (org-latex-sync-pdf)
    (save-buffer-mask-hook)
    (not-modified)
    (org-latex-export-parent-to-latex)))

(defun org-latex-sync-pdf ()
  (interactive)
  (let ((p (point))
	;; (end (sentence-end)))
	(end (line-end-position))
	(buffer-undo-list nil) )
    ;; (temporary-changes
    (goto-char end)
    (insert "\n   \\pdfcomment{this-is-the-current-position}")
    (let ((p2 (point))
	  (after-save-hook nil)
	  (before-save-hook nil) )
      (save-buffer)
      ;; (primitive-undo 1 buffer-undo-list)
      (org-latex-export-parent-to-latex)
      (delete-region end p2)
      (goto-char p)
      (save-buffer)
      (not-modified)
      )))

(defun latexmk-buffer-name ()
  (let* ((fn (buffer-file-name (current-buffer))))
    (format "*latexmk %s*" fn)))

;; (defun kill-latexmk ()
;;   (kill-buffer (latexmk-buffer-name)))

(defun launch-latexmk ()
  (let ((buf-name (latexmk-buffer-name)))
    ;; (when (not (get-buffer buf-name))
    (let ((buf (or (get-buffer buf-name) (get-buffer-create buf-name))))
      (start-process "latexmk" buf
                     "latexmk" "-xelatex" "-pvc" "structure.tex" "-view=none")
      ;; "-silent")
      (add-hook 'kill-buffer-hook 'kill-latexmk t t))))

(defun set-extension (fp ext)
  (concat (file-name-sans-extension fp) ext))

;; (TeX-command-master)
;; org-get-heading
;; org-previous-visible-heading
;; pdf-view-jump-to-register
;; doc-view-search
;; buffer-substring-no-properties



;; pdf-view-goto-page
(defun org-sync-pdf ()
  (let ((buf (get-file-buffer (org-target-pdf-file))))
    ;; (trace (org-current-heading))
    ;; (when-let (hd (org-current-heading))
    ;; (let ((page (org-pdf-page-of hd)))
    (when-let (page (org-pdf-page-of-annot "this-is-the-current-position"))
    ;; (org-pdf-page-of (org-current-heading))
    ;; ))
	;; (print (org-current-heading))
      (with-current-buffer buf
	(pdf-view-goto-page page (get-buffer-window buf))))))

(defmacro mask-hook (hooks &rest args)
  (let ((vars (mapcar (lambda (x) (list x 'nil)) hooks)))
    `(let ,vars
       ,@args)))

(defun save-buffer-mask-hook ()
  (mask-hook (after-save-hook before-save-hook)
	     (save-buffer)))

(defun org-pdf-page-of-annot (annot)
  (let* ((outline (pdf-info-getannots nil (get-file-buffer (org-target-pdf-file))))
	 (entry (car (seq-filter
		      (lambda (entry)
			(equal annot
			       (cdr (assoc 'contents entry))) )
		      outline))))
    (cdr (assoc 'page entry))))

(defun org-pdf-page-of-heading (h)
  (let* ((outline (pdf-info-outline (get-file-buffer (org-target-pdf-file))))
	 (hh (seq-take-while (lambda (c) (not (equal (string c) "["))) h))
	 (entry (car (seq-filter
		      (lambda (entry)
			(string-match-p hh (cdr (assoc 'title entry))) )
		      outline))))
    (cdr (assoc 'page entry))))

(defun org-current-heading ()
  (save-excursion
    (trace (org-before-first-heading-p))
    (if (org-before-first-heading-p)
	(progn
	  (org-next-visible-heading 1)
	  (substring-no-properties (org-get-heading)))
      (trace (org-get-heading))
      (if (string-match-p "TODO\\|END" (substring-no-properties (org-get-heading)))
	  (progn
	    (org-previous-visible-heading 1)
	    (org-current-heading))
	(substring-no-properties (org-get-heading))))))

(defun org-target-pdf-file ()
  (concat (file-name-as-directory default-directory)
	  (set-extension org-root-doc ".pdf")))

(defun org-target-tex-file ()
  (concat (file-name-as-directory default-directory)
	  (set-extension org-root-doc ".tex")))

(defun org-preview-pdf ()
  (interactive)
  (with-current-buffer
      (find-file-other-window (org-target-pdf-file))))

(defun org-view-latex ()
  (interactive)
  (with-current-buffer (find-file (org-target-tex-file))
    (TeX-command-run-all) ))

(defun display-pdf (&optional pdf)
  (interactive)
  (let ((pdf (or pdf (set-extension org-root-doc ".pdf"))))
    (save-selected-window
      (with-current-buffer (find-file-other-window pdf)
	(unless (boundp 'pdf-setup)
	  ;; revert-without-query
	  (add-to-list 'revert-without-query (expand-file-name pdf))
	  (add-to-list 'revert-without-query pdf)
	  (setq-local pdf-setup t))
	;; (display-buffer (current-buffer))
	(revert-buffer)))))

(defun compile-latex (root)
  (let* ((buf-name (latexmk-buffer-name))
	 (buf (get-buffer-create buf-name)))
    (save-selected-window
      (with-current-buffer buf
	(let* ((pdf (set-extension root ".pdf"))
	       (command "xelatex"))
	  (let ((r (with-current-buffer buf
		     (erase-buffer)
		     ;; (call-process "xelatex" nil buf-name nil root)
		     (call-process "latexmk" nil buf-name nil "-xelatex" "-f" root)
		     )))
	    (print r)
	    (if (= r 0)
		(progn
		  (display-pdf pdf)
		  (org-sync-pdf))
	      (progn
		;; (with-current-buffer (get-file-buffer pdf)
		;; 	(set-buffer (current-buffer))
		(display-buffer buf)
		(with-current-buffer buf
		  (goto-char (point-max)))))
	    ))))))

;; latex-preview-pane-mode

;; (setq org-default-notes-file (concat org-directory "/notes.org"))
;; (define-key global-map "\C-cc" 'org-capture)
;; (string-join '("latexmk" "-xelatex" "-pvc" "structure.tex" "-view=none") " ")

(add-hook 'doc-view-mode-hook #'pdf-tools-install)
(add-hook 'doc-view-mode-hook (lambda () (linum-mode -1)))
(add-hook 'pdf-view-mode-hook (lambda () (linum-mode -1)))
;; (add-hook 'pdf-view-mode-hook 'auto-revert-mode)
;; [[https://github.com/politza/pdf-tools][pdf-tools]]

(setq org-latex-prefer-user-labels t)
