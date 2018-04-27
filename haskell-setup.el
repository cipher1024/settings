;; (add-to-list 'load-path "~/stack-ide/stack-mode/")
;; (add-to-list 'load-path "~/.stack/snapshots/x86_64-osx/lts-4.0/7.10.3/share/x86_64-osx-ghc-7.10.3/HaRe-0.8.2.1/elisp/")
;; Install Intero
(require 'haskell-mode)
;; (require 'haskell-emacs)
;; (require 'stack-mode)
(require 'intero)
(require 'company-ghc)
(require 'flycheck-haskell)
(require 'flycheck-ghcmod)
;; (require 'hare)
(require 'helm-ghc)
(require 'scion)
(require 'hindent)

(require 'hs-lint)
(defun my-haskell-mode-hook ()
    (local-set-key "\C-cl" 'hs-lint))
(add-hook 'haskell-mode-hook 'my-haskell-mode-hook)

(defun launch-latexmk ()
  (let ((buf-name (latexmk-buffer-name)))
    (when (not (get-buffer buf-name))
      (let ((buf (get-buffer-create buf-name)))
	(start-process "latexmk" buf
		       "latexmk" "-xelatex" "-pvc" "structure.tex" "-view=none" "-silent")
	(add-hook 'kill-buffer-hook 'kill-latexmk t t)))))

(defun stack-install ()
  (interactive)
  (let ((buf-name "*stack install*"))
    (when (not (get-buffer buf-name))
      (let ((buf (get-buffer-create buf-name)))
	(start-process "stack" buf
		       "stack" "install")
	(switch-to-buffer-other-window buf)))))

(defun stack-edit-stack-yaml ()
  (interactive)
  (find-file (f-join (find-root-dir-safe "stack.yaml") "stack.yaml")))

(defun stack-edit-package-yaml ()
  (interactive)
  (find-file (f-join (find-root-dir-safe "package.yaml") "package.yaml")))

(defun travis-edit-config ()
  (interactive)
  (find-file (f-join (find-root-dir-safe ".travis.yml") ".travis.yml")))

;; (add-hook 'haskell-mode-hook (lambda () (ghc-init) (hare-init)))
(add-hook 'haskell-mode-hook 'flycheck-mode)
;; (add-hook 'haskell-mode-hook 'stack-mode)
(add-hook 'haskell-mode-hook 'intero-mode)
(add-hook 'haskell-mode-hook 'set-truncate-lines)
(add-hook 'haskell-mode-hook
	  (lambda () (local-set-key (kbd "C-c C-r") 'intero-restart)))
(intero-global-mode 1)
;; (remove-hook 'haskell-mode-hook 'structured-haskell-mode)


(add-hook 'haskell-mode-hook #'hindent-mode)
