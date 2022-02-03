;; (unload-feature 'CEDET)
;; (load-file "~/.emacs.d/lisp/cedet/cedet-devel-load.el")
;; (load-file "~/.emacs.d/lisp/cedet/contrib/cedet-contrib-load.el")
;; (load-file "~/.emacs.d/lisp/cedet/common/cedet.el")

;; (require 'ggtags)
;; (add-hook 'c-mode-common-hook
;;           (lambda ()
;;             (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'asm-mode)
;;               (ggtags-mode 1))))

;; (define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
;; (define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
;; (define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
;; (define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
;; (define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
;; (define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)

;; (define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark)

(add-to-list 'load-path "~/.emacs.d/lisp/emacs-c-ide-demo/custom")

(when (not package-archive-contents)
    (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(setq use-package-always-ensure t)

(require 'company-clang)
(use-package ggtags)
;; (use-package ninja-mode)

;; (require 'setup-general)
;; (if (version< emacs-version "24.4")
;;     (require 'setup-ivy-counsel)
;;   (require 'setup-helm)
(require 'setup-helm-gtags)
;; )
(require 'setup-ggtags)
(require 'setup-cedet)
;; (require 'setup-editing)
(use-package company-c-headers
  :init
  (add-to-list 'company-backends 'company-c-headers))

;; (global-semantic-tag-folding-mode 1)

;; function-args
;; (require 'function-args)
;; (fa-config-default)
;; (define-key c-mode-map  [(tab)] 'company-complete)
;; (define-key c++-mode-map  [(tab)] 'company-complete)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (zygospore helm-gtags helm yasnippet ws-butler volatile-highlights use-package undo-tree iedit dtrt-indent counsel-projectile company clean-aindent-mode anzu))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; (add-hook 'dired-mode-hook 'helm-gtags-mode)
;; (add-hook 'eshell-mode-hook 'helm-gtags-mode)
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
;; (add-hook 'asm-mode-hook 'helm-gtags-mode)

;; (define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
;; (define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
;; (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
;; (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
;; (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
;; (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

;; (setq-local imenu-create-index-function #'ggtags-build-imenu-index)
(global-ede-mode t)

;; (require 'semantic-ia)          ; names completion and display of tags
;; (require 'semantic-gcc)         ; auto locate system include files
;; (require 'semanticdb)
(global-semanticdb-minor-mode 1)
;; (require 'semanticdb-ectag)
;; (semantic-load-enable-primary-exuberent-ctags-support)

;; (global-semantic-idle-tag-highlight-mode 1)
;; (setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 4)
(setq c-basic-offset 4)

(define-key c-mode-map (kbd "C-c C-c") 'recompile)
(define-key c++-mode-map (kbd "C-c C-c") 'recompile)

(use-package cmake-mode)
(use-package cmake-ide)
(use-package cmake-project)
(require 'semantic/ia)

(setq-mode-local c-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))

(defun my-semantic-hook ()
  (imenu-add-to-menubar "TAGS"))
(add-hook 'semantic-init-hooks 'my-semantic-hook)

;; (when (cedet-gnu-global-version-check t)
;;   (semanticdb-enable-gnu-global-databases 'c-mode)
;;   (semanticdb-enable-gnu-global-databases 'c++-mode))
