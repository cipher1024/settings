
(use-package cc-mode
  :ensure t)

(add-to-list 'load-path
             "~/.emacs-lisp/ecb/")

;; (require 'ecb)
(require 'ecb-autoloads)
;; (add-hook 'c++-mode-hook 'ecb-minor-mode)

(setq ecb-tip-of-the-day nil)

(defun semanticdb-save-all-db-idle ()
  "Save all semantic tag databases from idle time.
Exit the save between databases if there is user input."
   (semantic-safe "Auto-DB Save: %S"
     ;; FIXME: Use `while-no-input'?
    (save-excursion
      (semantic-exit-on-input 'semanticdb-idle-save
        (mapc (lambda (db)
                (semantic-throw-on-input 'semanticdb-idle-save)
                (semanticdb-save-db db t))
              semanticdb-database-list))
      )))
