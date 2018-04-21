(load "~/.emacs.d/package-setup.el")
;; org-latex-packages-alist


;; (load-file "~/.emacs.d/lisp/cedet-1.0.1/common/cedet.el")
;; (global-ede-mode 1)                      ; Enable the Project management system
;; (semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion
;; (global-srecode-minor-mode 1)            ; Enable template insertion menu

;; ;; (setq load-path (cons "~/.emacs.d/lisp/ecb" load-path))
;; ;; (require 'ecb)


(load "~/.emacs.d/lisp/PG/generic/proof-site")
(load "~/.emacs.d/my-project-list.el")
(load "~/.emacs.d/elisp-setup.el")
(load "~/.emacs.d/project.el")
(load "~/.emacs.d/lean-setup.el")
(load "~/.emacs.d/schedule.el")
(load "~/.emacs.d/straight-setup.el")
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
(load "~/.emacs.d/ivy-setup.el")

;; (desktop-save-mode 10)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; (selected-window-group)
;; (current-window)

;; (find-file "~/.emacs.d/lean-setup.el")
;; (find-file "~/personal.org")
;; (setup-lean-displays)
(find-file "~/org-mode/daily-schedule.org")
(split-window-right)
(find-file "~/.emacs.d/init.el")

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
