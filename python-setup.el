
;; python-mode-hook
;; delete the default contents of python mode
(setq python-mode-hook
      (list (lambda nil
              (setq imenu-create-index-function py--imenu-create-index-function)
              (setq indent-tabs-mode py-indent-tabs-mode))))

  ;; (lambda nil
  ;;   (setq py-this-abbrevs-changed abbrevs-changed)
  ;;   (load abbrev-file-name nil t)
  ;;   (setq abbrevs-changed py-this-abbrevs-changed)))

(use-package company-jedi
  :ensure t)

(use-package flycheck-color-mode-line
  :ensure t)

;; Code Completion and Navigation
;;
(defun company-jedi-setup ()
  (add-to-list 'company-backends 'company-jedi))
(add-hook 'python-mode-hook 'company-jedi-setup)

(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)
(add-hook 'python-mode-hook 'jedi:setup)

(setq jedi-custom-file (expand-file-name "jedi-custom.el" user-emacs-directory))
(when (file-exists-p jedi-custom-file)
  (load jedi-custom-file))

;; Interactive Programming
;;
(setq
 python-shell-interpreter "ipython"
 python-shell-interpreter-args "-i")

;; Syntax Checking and Formating
;;
(add-hook 'after-init-hook 'global-flycheck-mode)
(setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)

(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode)

(use-package py-autopep8
  :ensure t)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
