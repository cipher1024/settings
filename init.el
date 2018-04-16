
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives
   (quote
    (("melpa" . "http://melpa.org/packages/")
     ("org" . "http://orgmode.org/elpa/")
     ("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))))
; package-archives
(package-initialize)

(unless (package-installed-p 'use-packhaage)
	(package-refresh-contents)
	(package-install 'use-package))
(setq load-path (cons "~/.emacs.d/lisp/" load-path))

;; org-latex-packages-alist


;; (load-file "~/.emacs.d/lisp/cedet-1.0.1/common/cedet.el")
;; (global-ede-mode 1)                      ; Enable the Project management system
;; (semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion
;; (global-srecode-minor-mode 1)            ; Enable template insertion menu

;; ;; (setq load-path (cons "~/.emacs.d/lisp/ecb" load-path))
;; ;; (require 'ecb)
(load "~/.emacs.d/project.el")
(load "~/.emacs.d/lean-setup.el")
(load "~/.emacs.d/schedule.el")
;; (load "~/.emacs.d/c-ide-setup.el")
;; (load "~/.emacs.d/wunderlist-setup.el")

;; (require 'tla-mode)
;; (require 'neotree)
;; (load "~/.emacs.d/yaml-setup.el")
;; (load "~/.emacs.d/toml-setup.el")
(load "~/.emacs.d/latex-setup.el")
(load "~/.emacs.d/org-setup.el")
(load "~/.emacs.d/babel-setup.el")
(load "~/.emacs.d/haskell-setup.el")
(load "~/.emacs.d/ibuffer-setup.el")

;; (desktop-save-mode 10)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; (split-window-right)
;; (selected-window-group)
;; (current-window)

;; (find-file "~/.emacs.d/lean-setup.el")
;; (find-file "~/personal.org")
(find-file "~/.emacs.d/init.el")
;; (setup-lean-displays)

(find-file-in "~/personal.org" (get-top-right-panel))
;; (find-file-in "~/org-mode/more.org" (get-top-right-panel))
;; (find-file-in "~/org-mode/projects.org" (get-top-right-panel))
;; (find-file-in "~/org-mode/more.org" (get-second-window))
;; (window-list) top-right-panel
;; (split-window (frame-root-window) nil 'right)
;; (find-file "~/lean/unity/semantics-lean/")
;; (split-window-below)

;; (ansi-term "/bin/sh")
(tool-bar-mode -1)
(maximize-frame)
(global-linum-mode t)

;; ; (find-file-other-frame "~/lean/lean/src/emacs/lean-server.el")
;; ; (select-lean-project)

;; (eval-after-load "enriched"
;;   '(defun enriched-decode-display-prop (start end &optional param)
;;      (list start end)))

(show-paren-mode 1)
(setq paren-match-face 'highlight)
(require 'mic-paren)
(paren-activate)
