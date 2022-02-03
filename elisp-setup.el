(add-hook 'emacs-lisp-mode 'set-truncate-lines)
(add-hook 'emacs-lisp-mode 'company-mode)
(add-hook 'emacs-lisp-mode
          (lambda () (flycheck-mode -1)))

(add-to-list 'flycheck-disabled-checkers 'emacs-lisp-checkdoc)
