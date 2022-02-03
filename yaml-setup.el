(use-package yaml-mode
  :ensure t)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode) '("\\.yaml\\'" . yaml-mode))

(add-hook 'yaml-mode-hook
          (lambda ()
            (variable-pitch-mode nil)
            (text-scale-set 1)))
