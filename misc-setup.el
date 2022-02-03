(require 'highlight-symbol)

(global-set-key (kbd "C-x 9") 'delete-other-windows-vertically)

(defun kill-symbol ()
  (interactive)
  (destructuring-bind (b . e)
      (bounds-of-thing-at-point 'symbol)
    (copy-region-as-kill b e))
  ;; (kill-new (thing-at-point 'symbol))
  )

(global-set-key (kbd "M-s") 'kill-symbol)

(defun duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg))

(global-set-key (kbd "C-d") 'duplicate-line)
;; (define-key google3-mode-map (kbd "C-d") 'duplicate-line)
;; (define-key google3-mode-map (kbd "C-c C-d")
(define-key c++-mode-map (kbd "C-d") 'duplicate-line)
;; google3-run-test-at-point

(add-to-list 'load-path "~/.emacs.d/move-lines/")

(mapc
 (function
  (lambda (sym)
    (put sym 'delete-selection t)       ; for delsel (Emacs)
    (put sym 'pending-delete t)))       ; for pending-del (XEmacs)
 '(c-electric-pound
   c-electric-slash
   c-electric-star
   c-electric-semi&comma
   c-electric-lt-gt
   c-electric-colon))
(mapc
 (function
  (lambda (sym)
    (put sym 'delete-selection (if (fboundp 'delete-selection-uses-region-p)
                                   'delete-selection-uses-region-p
                                 t))
    (put sym 'pending-delete t)))
 '(c-electric-brace
   c-electric-paren))

(require 'move-lines)
(move-lines-binding)

(add-hook 'flymake-mode-hook
          (lambda ()
            (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
            (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)))

(defun reopen-window ()
  (interactive)
  (let ((buf (current-buffer)))
    (delete-window)
    (delete-other-windows)
    (switch-to-buffer-other-window buf)
    ))

(defun reopen-window-vertically ()
  (interactive)
  (let ((buf (current-buffer)))
    (delete-window)
    (delete-other-windows)
    (split-window-vertically)
    (switch-to-buffer-other-window buf)
    ))


(defun make-scratch-script ()
  (interactive)
  (let ((buf (buffer-name)))
    (find-file-other-window "~/.emacs.d/scratch.el")
    (goto-char (point-min))
    (insert "\n)\n\n\n")
    (goto-char (point-min))

    (insert (format "(with-current-buffer %s\n  "
                    (prin1-to-string buf)))))

(defun zip-with-right (f xs ys)
  (if (null xs)
      ys
    (if (null ys)
        ys
      (destructuring-bind ((x . xs) (y . ys)) (list xs ys)
        (cons (funcall f x y) (zip-with-right f xs ys))))))

(defun zip-with-left (f xs ys)
  (zip-with-right f ys xs))

(defun add-padding (width line)
  (let ((pad (make-string (- width (length line)) ? )))
    (concat line pad)))

(defun columns (cols lines &optional sep)
  (let* ((sep (or sep " "))
         (headings (-repeat cols 0))
         (width
          (reduce (apply-partially
                   'zip-with-left
                   (lambda (ln h) (max h (length ln))))
                  lines
                  :initial-value headings
                  ))
         (lines
          (mapcar
           (apply-partially 'zip-with-right
                            'add-padding
                            width)
           lines)))
    (mapcar
     (lambda (l) (mapconcat 'identity l sep))
     lines)))
