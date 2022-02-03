;; (add-to-list 'load-path "~/stack-ide/stack-mode/")
;; (add-to-list 'load-path "~/.stack/snapshots/x86_64-osx/lts-4.0/7.10.3/share/x86_64-osx-ghc-7.10.3/HaRe-0.8.2.1/elisp/")
;; Install Intero
;; (use-package intero
;;     :ensure t)
(use-package helm-ghc
    :ensure t)
;; (use-package scion
;;     :ensure t)
;; (use-package hindent
;;     :ensure t)
;; (use-package dante
;;   :ensure t
;;   :after haskell-mode
;;   :commands 'dante-mode
;;   :init
;;   (add-hook 'haskell-mode-hook 'flycheck-mode)
;;   ;; OR:
;;   ;; (add-hook 'haskell-mode-hook 'flymake-mode)
;;   (add-hook 'haskell-mode-hook 'dante-mode)
;;   ;; ;; (add-hook 'haskell-mode-hook 'haskell-doc-mode)
;;   ;; (add-hook 'haskell-mode-hook 'haskell-decl-scan-mode)
;;   ;; ;; (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
;;   ;; ;; (add-hook 'haskell-mode-hook 'haskell-indentation-mode)
;;   )

;; (use-package haskell-hlint
;;   :ensure t)
;; (add-hook 'dante-mode-hook
;;    '(lambda () (flycheck-add-next-checker 'haskell-dante
;;                 '(warning . haskell-hlint))))

;; (use-package lsp-mode
;;   :ensure t)
;; (use-package lsp-ui
;;   :ensure t)
;; (use-package lsp-haskell
;;   :ensure t)

;; (unload-feature 'intero t)

(defun my-haskell-mode-hook ()
  (lsp)
  ;; (hindent-mode)
  (flycheck-mode)
  ;; (smartparens-mode)
  ;; (lsp-haskell-set-completion-snippets-on)
  (lsp-haskell-set-hlint-on)
  (lsp-haskell-set-liquid-on)
  ;; (setq haskell-mode-stylish-haskell-path "brittany")
  (setq haskell-hoogle-url "https://www.stackage.org/lts/hoogle?q=%s"))

(add-hook 'haskell-mode-hook 'my-haskell-mode-hook)

;; (unload-feature 'lsp-mode t)

;; (use-package company-haskell
;;     :ensure t)

;; LSP
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))
(use-package yasnippet
  :ensure t)
(use-package lsp-mode
  :ensure t
  :hook (haskell-mode . lsp)
  :commands lsp)
(use-package lsp-ui
  :ensure t
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  :commands lsp-ui-mode)
(use-package lsp-haskell
 :ensure t
 :config
 ;; (setq lsp-haskell-process-path-hie "ghcide")
 ;; (setq lsp-haskell-process-args-hie '())
 (add-hook 'haskell-mode-hook #'lsp)
 (add-hook 'haskell-literate-mode-hook #'lsp)

 ;; Comment/uncomment this line to see interactions between lsp client/server.
 ;;(setq lsp-log-io t)
)
(use-package flycheck-haskell
    :ensure t)

;; (use-package eglot
;;   :ensure t
;;   :config
;;   (add-to-list 'eglot-server-programs '(haskell-mode . ("ghcide" "--lsp"))))

;; (use-package haskell-mode
;;     :ensure t)
;; ;; (require 'haskell-emacs)
;; ;; (require 'stack-mode)
;; ;; (require 'intero)
;; ;; (require 'dante)
;; (use-package company-ghc
;;   :config
;;   (add-to-list 'company-backends 'company-ghc))

;; ;; (require 'hare)
;; ;; (require 'helm-ghc)
;; ;; (require 'scion)
;; ;; (require 'hindent)
;; ;; (unload-feature 'scion t)
;; ;; (use-package flycheck-haskell)

;; (use-package haskell-mode
;;   :config
;;   (setq haskell-indentation-layout-offset 4
;;         haskell-indentation-left-offset 4
;; 	flycheck-checker 'haskell-hlint
;; 	;; flycheck-disabled-checkers '(haskell-stack-ghc haskell-ghc)
;;         ))

;; (use-package hlint-refactor
;;   :bind (:map hlint-refactor-mode-map
;; 	      ("C-c l b" . hlint-refactor-refactor-buffer)
;; 	      ("C-c l r" . hlint-refactor-refactor-at-point))
;;   :hook (haskell-mode . hlint-refactor-mode))

;; ;; (add-hook 'haskell-mode-hook (lambda () (local-unset-key "\C-cl")))

;; (use-package hs-lint
;;   :load-path "lisp/"
;;   :bind (:map haskell-mode-map
;;               ("C-c l l" . hs-lint)))

(defun stack-install ()
  (interactive)
  (let ((buf-name "*stack install*"))
    (let ((buf (get-buffer-create buf-name))
	  (dir (find-root-dir "stack.yaml")))
      (with-current-buffer buf
        (erase-buffer)
	(setq default-directory dir)
	(start-process "stack" buf
		       "stack" "install")
	(switch-to-buffer-other-window buf)
        (redisplay)))))

(defun stack-clean ()
  (interactive)
  (let ((buf-name "*stack install*"))
    (let ((buf (get-buffer-create buf-name))
	  (dir (find-root-dir "stack.yaml")))
      (with-current-buffer buf
	(setq default-directory dir)
	(start-process "stack" buf
		       "stack" "clean")
	(switch-to-buffer-other-window buf)))))

(defun stack-edit-stack-yaml ()
  (interactive)
  (find-file (f-join (find-root-dir-safe "stack.yaml") "stack.yaml")))

(defun stack-edit-package-yaml ()
  (interactive)
  (find-file (f-join (find-root-dir-safe "package.yaml") "package.yaml")))

;; (add-hook 'haskell-mode-hook (lambda () (ghc-init) (hare-init)))
(add-hook 'haskell-mode-hook 'flycheck-mode)
;; (add-hook 'haskell-mode-hook 'stack-mode)
;; (add-hook 'haskell-mode-hook 'intero-mode)
;; (add-hook 'haskell-mode-hook 'dante-mode)
(add-hook 'haskell-mode-hook (lambda () (toggle-truncate-lines 1)))

;; (add-hook 'haskell-mode-hook
	  ;; (lambda () (local-set-key (kbd "C-c l r") 'intero-restart)))
;; (intero-global-mode 1)
;; (remove-hook 'haskell-mode-hook 'structured-haskell-mode)

(defun stack-build-buffer ()
    (format "*stack %s*" (find-root-dir-safe "stack.yaml")))

(defun stack-kill-build ()
  (interactive)
  (let* ((prj (find-root-dir-safe "stack.yaml"))
	 (buf-name (stack-build-buffer)))
    (when-let (buf (get-buffer buf-name))
      (with-current-buffer buf
	(insert "\n; kill process")
	(kill-buffer)))))

(defun stack-build ()
  (interactive)
  (let* ((prj (find-root-dir-safe "stack.yaml"))
	 (buf-name (stack-build-buffer))
	 (default-directory prj))
    (unless (get-buffer buf-name)
      (setq-local stack-process
		  (start-process "stack" buf-name
				 "stack" "build" "--ghc-options" "-Werror" "--file-watch"))
      (set-process-query-on-exit-flag stack-process nil)
      (set-process-filter stack-process 'remove-ugly)
      )))

(defun stack-test ()
  (interactive)
  (let* ((prj (find-root-dir-safe "stack.yaml"))
	 (buf-name (stack-build-buffer))
	 (default-directory prj))
    (unless (get-buffer buf-name)
      (setq-local stack-process
		  (start-process "stack" buf-name
				 "stack" "test" ;; "tlaplus-quickcheck"
				 "--ghc-options" "-Werror" "--file-watch"))
      (set-process-query-on-exit-flag stack-process nil)
      (set-process-filter stack-process 'remove-ugly)
      )))

;; (use-package lean-mode
;;   :bind (:map lean-mode-map
;; 	      ("S-SPC" . company-complete)))

;; (use-package flycheck
;;   :hook (prog-mode . flycheck-mode)
;;   :config
;;   ;; Use the load-path from running Emacs when checking elisp files
;;   (setq flycheck-emacs-lisp-load-path 'inherit)

;;   ;; Only flycheck when I actually save the buffer
;;   (setq flycheck-check-syntax-automatically '(mode-enabled save)))

;; (add-to-list 'company-backends 'company-ghc)

(defun remove-ugly (pc output)
  (with-current-buffer (process-buffer pc)
    (goto-char (point-max))
    (insert output)))

;; (defun remove-ugly (pc output)
;;   (with-current-buffer (process-buffer pc)
;;     (goto-char (point-max))
;;     (insert (string-join (split-string output "") ""))
;;     (goto-char (point-max))))
  ;; (setq kept
  ;; 	(cons (string-join (split-string output "") "")
  ;; 	      kept)))

(defun haskell-run-weeder ()
  (interactive)
  (let* ((prj (find-root-dir-safe "stack.yaml"))
	 (buf-name "*haskell tool*")
	 (default-directory prj))
    (switch-to-buffer-other-window (get-buffer-create buf-name))
    (setq-local stack-process
		(start-process "weeder" buf-name
			       "stack" "exec" "weeder" "--" "." ))))

(defun haskell-run-hlint ()
  (interactive)
  (let* ((prj (find-root-dir-safe "stack.yaml"))
	 (buf-name "*haskell tool*")
	 (default-directory prj))
    (switch-to-buffer-other-window (get-buffer-create buf-name))
    (setq-local stack-process
		(start-process "hlint" buf-name
			       "stack" "exec" "hlint" "--" "." ))))

(defun lines-aux (acc)
  (if (= (point-max) (point))
      (reverse acc)
    (let ((ln (buffer-substring-no-properties (line-beginning-position)
					      (line-end-position) )))
      (forward-line)
      (lines-aux (cons ln acc)))))

(defun lines ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n"))
(lines)
;; (print (car (lines)))

;; #'buffer-substring-no-properties
;; (mapcar 'print (seq-take (lines (buffer-string-no-properties)) 3))
;; (forward-line)
(defun stack-view-build ()
  (interactive)
  (when-let (buf (get-buffer (stack-build-buffer)))
    (with-current-buffer buf
      (let ((lns (reverse (seq-take (reverse (lines)) 50))))
	(message "%s" (string-join lns "\n"))))))

;; (add-hook 'haskell-mode-hook #'hindent-mode)
;; (remove-hook 'haskell-mode-hook #'hindent-mode)


;; (defun my-correct-symbol-bounds (pretty-alist)
;;   "Prepend a TAB character to each symbol in this alist,
;; this way compose-region called by prettify-symbols-mode
;; will use the correct width of the symbols
;; instead of the width measured by char-width."
;;   (mapcar (lambda (el)
;;             (setcdr el (string ?\t (cdr el)))
;;             el)
;;           pretty-alist))

;; (custom-set-variables '(haskell-font-lock-symbols t)
;;                       '(haskell-font-lock-symbols-alist
;;                         (and (fboundp 'decode-char)
;;                              (list (cons "&&" (decode-char 'ucs #XE100))
;;                                    (cons "***" (decode-char 'ucs #XE101))
;;                                    (cons "*>" (decode-char 'ucs #XE102))
;;                                    (cons "\\\\" (decode-char 'ucs #XE103))
;;                                    (cons "||" (decode-char 'ucs #XE104))
;;                                    (cons "|>" (decode-char 'ucs #XE105))
;;                                    (cons "::" (decode-char 'ucs #XE106))
;;                                    (cons "==" (decode-char 'ucs #XE107))
;;                                    (cons "===" (decode-char 'ucs #XE108))
;;                                    (cons "==>" (decode-char 'ucs #XE109))
;;                                    (cons "=>" (decode-char 'ucs #XE10A))
;;                                    (cons "=<<" (decode-char 'ucs #XE10B))
;;                                    (cons "!!" (decode-char 'ucs #XE10C))
;;                                    (cons ">>" (decode-char 'ucs #XE10D))
;;                                    (cons ">>=" (decode-char 'ucs #XE10E))
;;                                    (cons ">>>" (decode-char 'ucs #XE10F))
;;                                    (cons ">>-" (decode-char 'ucs #XE110))
;;                                    (cons ">-" (decode-char 'ucs #XE111))
;;                                    (cons "->" (decode-char 'ucs #XE112))
;;                                    (cons "-<" (decode-char 'ucs #XE113))
;;                                    (cons "-<<" (decode-char 'ucs #XE114))
;;                                    (cons "<*" (decode-char 'ucs #XE115))
;;                                    (cons "<*>" (decode-char 'ucs #XE116))
;;                                    (cons "<|" (decode-char 'ucs #XE117))
;;                                    (cons "<|>" (decode-char 'ucs #XE118))
;;                                    (cons "<$>" (decode-char 'ucs #XE119))
;;                                    (cons "<>" (decode-char 'ucs #XE11A))
;;                                    (cons "<-" (decode-char 'ucs #XE11B))
;;                                    (cons "<<" (decode-char 'ucs #XE11C))
;;                                    (cons "<<<" (decode-char 'ucs #XE11D))
;;                                    (cons "<+>" (decode-char 'ucs #XE11E))
;;                                    (cons ".." (decode-char 'ucs #XE11F))
;;                                    (cons "..." (decode-char 'ucs #XE120))
;;                                    (cons "++" (decode-char 'ucs #XE121))
;;                                    (cons "+++" (decode-char 'ucs #XE122))
;;                                    (cons "/=" (decode-char 'ucs #XE123))))))

;; (defun my-ligature-list (ligatures codepoint-start)
;;   "Create an alist of strings to replace with
;; codepoints starting from codepoint-start."
;;   (let ((codepoints (-iterate '1+ codepoint-start (length ligatures))))
;;     (-zip-pair ligatures codepoints)))

;;                                         ; list can be found at https://github.com/i-tu/Hasklig/blob/master/GlyphOrderAndAliasDB#L1588
;; (setq my-hasklig-ligatures
;;       (let* ((ligs '("&&" "***" "*>" "\\\\" "||" "|>" "::"
;;                      "==" "===" "==>" "=>" "=<<" "!!" ">>"
;;                      ">>=" ">>>" ">>-" ">-" "->" "-<" "-<<"
;;                      "<*" "<*>" "<|" "<|>" "<$>" "<>" "<-"
;;                      "<<" "<<<" "<+>" ".." "..." "++" "+++"
;;                      "/=" ":::" ">=>" "->>" "<=>" "<=<" "<->")))
;;         (my-correct-symbol-bounds (my-ligature-list ligs #Xe100))))

;; ;; nice glyphs for haskell with hasklig
;; (defun my-set-hasklig-ligatures ()
;;   "Add hasklig ligatures for use with prettify-symbols-mode."
;;   (setq prettify-symbols-alist
;;         (append my-hasklig-ligatures prettify-symbols-alist))
;;   (prettify-symbols-mode))

;; (add-hook 'haskell-mode-hook 'my-set-hasklig-ligatures)

;; (remove-hook 'haskell-mode-hook 'my-set-hasklig-ligatures)

;; (setq package-check-signature nil)
;; (package-install 'auctex)
;; (package-install 'spinner)
;; (package-install 'let-alist)
;; (package-install 'ghub)
