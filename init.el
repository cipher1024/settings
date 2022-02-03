;; For DEBUGGING: use (toggle-debug-on-error) before eval

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(find-file-noselect "~/.emacs.d/init.el")
(find-file-noselect "~/.emacs.d/scratch.el")
(find-file-noselect "~/.emacs.d/lean4-setup.el")
(find-file-noselect "~/.emacs.d/do-not-disturb.el")
(find-file-noselect "~/Google Stuff/priority.org")
(find-file-noselect "~/priority.org")
(load "~/.emacs.d/package-setup.el")
(load "~/.emacs.d/straight-setup.el")
;; (load "~/.emacs.d/elisp-setup.el")

;; org-latex-packages-alist

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;; (load-file "~/.emacs.d/lisp/cedet-1.0.1/common/cedet.el")
;; (global-ede-mode 1)                      ; Enable the Project management system
;; (semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion
;; (global-srecode-minor-mode 1)            ; Enable template insertion menu

;; ;; (setq load-path (cons "~/.emacs.d/lisp/ecb" load-path))
;; ;; (require 'ecb)
(setq-default indent-tabs-mode nil)

(defmacro after-init (&rest body)
  `(add-hook 'after-init-hook
          (lambda ()
            ,@body)))

;; (use-package forge)

(use-package f
  :ensure t)
(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))
(require 'quelpa)
(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)
(add-to-list 'quelpa-melpa-recipe-stores "/Users/simon/melpa/recipes")
(use-package dash
  :ensure t)
(use-package projectile
  :ensure t)
(use-package git-commit
  :ensure t)
(use-package ghub
  :ensure t)
(use-package neotree
  :ensure t)

;; (let ((package-check-signature nil))
;;   (package-install 'let-alist)
;;   (package-install 'ghub)
;;   (package-install 'auctex))

;; (use-package smartparens-config
;;   :ensure smartparens
;;   :config (smartparens-global-strict-mode))

;; (require 'real-auto-save)
;; (require 'f)
;; (unload-feature 'proof-site t)

;; (desktop-save-mode 10)
;; (desktop-read)
;; (desktop-save ".")

(defmacro do-after-init (&rest code)
  `(add-hook 'after-init-hook (lambda () ,@code)))

(do-after-init (delete-selection-mode 1))
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; (selected-window-group)
;; (current-window)



;; (find-file "~/.emacs.d/lean-setup.el")
;; (find-file "~/personal.org")
;; (setup-lean-displays)
;; (find-file "~/org-mode/daily-schedule.org")
;; (split-window-right)
;; (find-file "~/.emacs.d/init.el")

;; (find-file-in "~/org-mode/more.org" (get-top-right-panel))
;; (find-file-in "~/org-mode/projects.org" (get-top-right-panel))
;; (find-file-in "~/org-mode/more.org" (get-second-window))
;; (window-list) top-right-panel
;; (split-window (frame-root-window) nil 'right)
;; (find-file "~/lean/unity/semantics-lean/")
;; (split-window-below)

;; (ansi-term "/bin/sh")
(tool-bar-mode -1)
(toggle-frame-maximized)
(global-linum-mode t)

;; ; (find-file-other-frame "~/lean/lean/src/emacs/lean-server.el")
;; ; (select-lean-project)

;; (eval-after-load "enriched"
;;   '(defun enriched-decode-display-prop (start end &optional param)
;;      (list start end)))

(show-paren-mode 1)
(setq paren-match-face 'highlight)
(use-package mic-paren :ensure t)
(paren-activate)

      ;; (let ((HOME (getenv "HOME")))
      ;;   (list
      ;;    (cons "Init" (format "%s/lean/lean4/src/Init" HOME)))))

;; (assoc "Init2" lean4-project-list)


;; (let ((HOME (getenv "LEAN_PATH")))
        ;; (list


;; (set-lean4-project "Init2" ".")

;; (let ((HOME (getenv "HOME")))
  ;;   (setenv "LEAN_PATH" (format "Init=%s/lean/lean4/src/Init:%s=%s" HOME name (expand-file-name dir)))
  ;; ))


;; (defun setup-auto-revert ()
;;    (file-notify-add-watch
;;     buffer-file-name '(change) (lambda (event) (revert-buffer t t))))

;; (add-hook 'read-only-mode-hook 'setup-auto-revert t)

;; (require 'quelpa)
;; (quelpa
;;  '(magit-todos :fetcher github
;;                :repo "alphapapa/magit-todos"))

;; (my-daily-schedule)

(require 'lean-input)
(setq default-input-method "Lean"
      ;; lean-input-tweak-all '(lean-input-compose
      ;;                        (lean-input-prepend "/")
      ;;                        (lean-input-nonempty))
      ;; lean-input-user-translations '(("/" "/"))
      )
(lean-input-setup)
;; magit-log-buffer-file
(defun white-and-black ()
  (interactive)
  (set-background-color "black")
  (set-foreground-color "white"))

(defun black-and-white ()
  (interactive)
  (set-foreground-color "black")
  (set-background-color "white"))

(defun travis-edit-config ()
  (interactive)
  (find-file (f-join (find-root-dir-safe ".travis.yml") ".travis.yml")))

(defun appveyor-edit-config ()
  (interactive)
  (find-file (f-join (find-root-dir-safe ".appveyor.yml") ".appveyor.yml")))

(defun emacs-edit-dir-local ()
  (interactive)
  (find-file (f-join (find-root-dir-safe ".dir-locals.el") ".dir-locals.el")))

(use-package yasnippet)
(use-package yasnippet-snippets
  :ensure t)
(use-package quelpa)
;; (quelpa 'yasnippet-lean '(yasnippet-lean :fetcher file :path "~/.emacs.d/yasnippet-lean/yasnippet-lean.el"))
;; (quelpa 'yasnippet-lean '(yasnippet-lean :fetcher github :repo "leanprover-community/yasnippet-lean"))
;; (unload-feature 'yasnippet-lean t)

(use-package dash-at-point)

(when (member "DejaVu Sans Mono" (font-family-list))
  (set-face-attribute 'default nil :font "DejaVu Sans Mono-11"))
(require 'unicode-fonts)
(unicode-fonts-setup)

;; (use-package magit-gh-pulls)
;; (use-package ht)
;; (list-packages)


;; (load-file (let ((coding-system-for-read 'utf-8))
;;              (shell-command-to-string "agda-mode locate")))

;; (unload-feature 'yasnippet-lean t)
(use-package yasnippet-lean
  :quelpa
  (yasnippet-lean
   ;; :fetcher github :repo "leanprover-community/yasnippet-lean"
   :fetcher file :path "~/.emacs.d/yasnippet-lean/"
   ;; :fetcher url :url "file:///Users/simon/.emacs.d/yasnippet-lean/yasnippet-lean.el"
   :files ("yasnippet-lean.el" "snippets")))
  ;; (yasnippet-lean :fetcher file :path "~/.emacs.d/yasnippet-lean/yasnippet-lean.el"))

(use-package highlight-symbol
  :quelpa
  (highlight-symbol
   :fetcher github :repo "nschum/highlight-symbol.el"))

(setq yas-indent-line 'fixed)

;; (package-install 'forge)
;; (use-package forge
;;   :after magit)

;; (forge :fetcher github
;;        :repo "magit/forge"
;;        :files ("lisp/*.el" "docs/forge.texi")
;;        ;; Forge-0.1.0 is not compatible with Magit-2.90.x.  While it
;;        ;; would theoretically be possible to use Forge-0.1.0 with a
;;        ;; Magit snapshot doing so would not be reasonable because many
;;        ;; bugs have been fixed in the Forge snapshot by now.  Once
;;        ;; Magit-2.91.0 and then Forge-0.2.0 have been released this
;;        ;; kludge has to be removed again.
;;        :version-regexp "PREVENT-STABLE")

(setq erc-autojoin-channels-alist
      '(("freenode.net" "#leanprover")))
;; (erc :server "irc.freenode.net" :port 6667 :nick "simon`")

(use-package solarized-theme)

;; (load-theme 'solarized-light t nil)
;; (disable-theme 'solarized-light)
;; (load-theme 'solarized-dark t nil)
;; (disable-theme 'solarized-dark)

;; (use-package folding
;;   :ensure t
;;   :config
;;   (folding-mode-add-find-file-hook)
;;   (folding-add-to-marks-list 'lean-mode "--{{{" "--}}}" nil t))

(defun below-toolchain (tc d)
  (let ((parent (file-name-directory (directory-file-name d))))
    ;; (print parent)
    (if (or (equal parent d) (equal tc parent))
        d
      (below-toolchain tc parent)
      ;; parent
      )))

(defun lean-lib-root ()
  (let ((toolchain "/Users/simon/.elan/toolchains/"))
    (below-toolchain toolchain default-directory)))

(defun extract-lean-version (root)
  (let ((base (file-name-nondirectory (directory-file-name root)))
        (p "leanprover-community-lean-"))
    (if (string-prefix-p p base)
        (format "leanprover-community/lean:%s"
                (seq-drop base (length p)))
      base)))

;; (require 'buffer-timer)
;; (unload-feature 'buffer-timer t)
(setq compilation-ask-about-save nil)
(use-package activity-watch-mode)
;; (global-activity-watch-mode)

(defun activity-watch--create-heartbeat (time)
  "Create heartbeart to sent to the activity watch server.
Argument TIME time at which the heartbeat was computed."
  (let ((branch (magit-get-current-branch))
        (project-name (projectile-project-name))
        (file-name (buffer-file-name (current-buffer))))
    `((timestamp . ,(ert--format-time-iso8601 time))
      (duration . 0)
      (data . ((language . ,(if (activity-watch--s-blank (symbol-name major-mode)) "unknown" major-mode))
               (project . ,(if (activity-watch--s-blank project-name) "unknown"
                             (if branch (concat project-name ":" branch) project-name)))
               (file . ,(if (activity-watch--s-blank file-name) "unknown" file-name)))))))


(defun create-missing-leanpkg-toml ()
  (let* ((root (lean-lib-root))
         (lean-path (concat (file-name-as-directory root) "lib/lean/library"))
         (default-directory lean-path))
    (unless (file-exists-p
             (concat (file-name-as-directory lean-path)
                     "leanpkg.toml"))
       (call-process "sh" nil nil nil
                     "/Users/simon/.elan/toolchains/make_toml.sh"
                     (extract-lean-version root))
       (lean-server-restart))))

;; (let* ((default-directory "/Users/simon/.elan/toolchains/leanprover-community-lean-3.6.1/include/lean_ext"))
(let* ((default-directory "/Users/simon/.elan/toolchains/3.4.2/include/lean_ext"))
;; (let* ((default-directory "/Users/simon/.elan/toolchains/stable/include/lean_ext"))
  (create-missing-leanpkg-toml)
  )

(use-package fold-this
  :ensure t)

;; (use-package zoom-frm)

;; (custom-set-variables '(haskell-tags-on-save t))

;; (load-file "~/.emacs.d/origami-setup.el")
(load-file "~/.emacs.d/template.el")
(load-file "~/.emacs.d/scale.el")
(load-file "~/.emacs.d/theme.el")
(load-file "~/.emacs.d/yasnippet-setup.el")
(electric-pair-mode 1)
;; (call-process-shell-command "eval $(opam env)")
;; (call-process-shell-command "which coqtop")

(global-set-key (kbd "C-.") 'other-window)
(global-set-key (kbd "C-,") (lambda () (interactive) (other-window -1)))
;; (describe-function 'other-window)

(autoload 'recover-buffers "recover-buffers" nil t)

(use-package multiple-cursors
  :ensure t)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(load "~/.emacs.d/coq-setup.el")
;; (load "~/.emacs.d/cedille-setup.el")
(load "~/.emacs.d/global-text-size.el")

(load "~/.emacs.d/helm-setup.el")
(load "~/.emacs.d/my-project-list.el")
;; (load "~/.emacs.d/dash-setup.el")
(load "~/.emacs.d/elisp-setup.el")
(load "~/.emacs.d/project.el")
(load "~/.emacs.d/lean4-setup.el")
;; (load "~/.emacs.d/agda-setup.el")
(load "~/.emacs.d/rust-setup.el")
(load "~/.emacs.d/cedet-setup.el")
(load "~/.emacs.d/vlc-setup.el")
(load "~/.emacs.d/md-setup.el")
(load "~/.emacs.d/schedule.el")
(load "~/.emacs.d/straight-setup.el")
;; (load "~/.emacs.d/mail-setup.el")
;; (load "~/.emacs.d/c-ide-setup.el")
;; (load "~/.emacs.d/wunderlist-setup.el")

(load "~/.emacs.d/tla-setup.el")
;; (require 'tla-mode)
;; (unload-feature 'tla-mode)
;; (require 'neotree)

(load "~/.emacs.d/yaml-setup.el")
;; (load "~/.emacs.d/toml-setup.el")
(load "~/.emacs.d/magit-setup.el")
(load "~/.emacs.d/markdown-setup.el")
;; (load "~/.emacs.d/org-setup.el")

(load "~/.emacs.d/latex-setup.el")
;; (load "~/.emacs.d/agenda-setup.el")
;; (load "~/.emacs.d/babel-setup.el")
(load "~/.emacs.d/lsp-setup.el")
(load "~/.emacs.d/haskell-setup.el")
(load "~/.emacs.d/ibuffer-setup.el")
(load "~/.emacs.d/ivy-setup.el")
(load "~/.emacs.d/misc-setup.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("7f1d414afda803f3244c6fb4c2c64bea44dac040ed3731ec9d75275b9e831fe5" default))
 '(package-archives
   '(("melpa-local" . "/Users/simon/melpa/html")
     ("melpa" . "http://melpa.org/packages/")
     ("org" . "http://orgmode.org/elpa/")
     ("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(zygospore helm-gtags helm yasnippet ws-butler volatile-highlights use-package undo-tree iedit dtrt-indent counsel-projectile company clean-aindent-mode anzu))
 '(safe-local-variable-values
   '((read-only-mode)
     (eval progn
           (when
               (and
                (buffer-file-name)
                (equal
                 (file-name-extension
                  (buffer-file-name))
                 "lean"))
             (create-missing-leanpkg-toml))
           (read-only-mode))
     (eval when
           (and
            (buffer-file-name)
            (equal
             (file-name-extension
              (buffer-file-name))
             "lean"))
           (progn
             (setq-local compile-command
                         (format "cd %s; yes | bash test_single.sh /Users/simon/lean/lean4/build/debug2/shell/lean %s yes"
                                 (file-name-directory
                                  (buffer-file-name))
                                 (buffer-file-name)))))
     (eval when
           (and
            (buffer-file-name)
            (equal
             (file-name-extension
              (buffer-file-name))
             "lean"))
           (create-missing-leanpkg-toml))
     (intero-stack-yaml . "/Users/simon/Documents/Haskell/VLC/stack.yaml")
     (intero-targets "vlc:lib" "vlc:exe:convert-queue" "vlc:exe:list-tags" "vlc:exe:new-monitor" "vlc:exe:rename-download-files" "vlc:exe:vlc-enqueue" "vlc:exe:vlc-get-meta" "vlc:exe:vlc-query" "xml-generics:lib")
     (haskell-language-extensions quote
                                  ("-XDuplicateRecordFields" "-XDeriveGeneric" "-XFlexibleContexts" "-XGADTs" "-XBangPatterns" "-XTupleSections" "-XGeneralizedNewtypeDeriving" "-XRankNTypes" "-XDeriveGeneric" "-XLambdaCase" "-XFlexibleInstances" "-XTypeSynonymInstances" "-XOverloadedLabels" "-XDuplicateRecordFields" "-XDeriveFunctor" "-XDeriveFoldable" "-XDeriveTraversable" "-XMultiParamTypeClasses" "-XFunctionalDependencies" "-XNoImplicitPrelude"))
     (eval when
           (and
            (buffer-file-name)
            (equal
             (file-name-extension
              (buffer-file-name))
             "lean"))
           (progn
             (lean4-mode)
             (local-set-key
              (kbd "C-c C-c")
              'recompile)
             (setq-local compile-command "~/lean/lean4/run_tests.sh")))
     (eval setenv "LEAN_BIN" "~/lean/lean-master/bin/lean"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
