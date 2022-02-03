

;; You need to modify the following line
;; (setq load-path
;;       (cons (concat (getenv "HOME")
;;                     "/lean/lean4/lean4-mode")
;;             load-path))
;; (setq lean4-rootdir nil)
;; (setq lean4-mode-required-packages '(dash f flycheck lsp-mode magit-section s))

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;; (package-initialize)
;; (let ((need-to-refresh t))
;;   (dolist (p lean4-mode-required-packages)
;;     (when (not (package-installed-p p))
;;       (when need-to-refresh
;;         (package-refresh-contents)
;;         (setq need-to-refresh nil))
;;       (package-install p))))


(require 'straight)

;; (require 'lean4-mode)
;; (require 'lean4-mode)
(use-package lean4-mode
  :straight (lean4-mode :type git :host github :repo "leanprover/lean4"
             :files ("lean4-mode/lean4*.el"))
  ;; to defer loading the package until required
  :commands (lean4-mode)
  :config (my-lean4-config))

(defun set-lean-path ()
  (interactive)
  (setenv "LEAN_PATH" (mapconcat (lambda (x) (format "%s=%s" (car x) (cdr x))) lean4-path ":")))
;; (set-lean-path)
;; (defcustom lean4-path nil
;;   "doc string"
;;   :type '(alist :key-type string :value-type string))

;; (defun lean4-make-lean-path ()
;;   (mapconcat (lambda (x) (format "%s=%s" (car x) (cdr x))) lean4-path ":"))
;;
;; change
;;  * lean4-execute
;;    add let binding:
;;     (compilation-environment
;;         (cons (cons "LEAN_PATH" (lean4-make-lean-path))
;;               compilation-environment))

(defun set-lean4-project (name dir &optional set-path)
  (let ((dir (expand-file-name dir)))
    (if-let (dir2 (assoc name lean4-path))
        (progn
          (unless (equal dir (cdr dir2))
            (error (format "project %s already exists at %s" name (cdr dir2))))
          (when set-path
            (set-lean-path)))
      (progn
        (add-to-list 'lean4-path (cons name dir))
        (when set-path
          (set-lean-path))
        ;; (setenv "LEAN_PATH" (mapconcat (lambda (x) (format "%s=%s" (car x) (cdr x))) lean4-path ":"))
        ))))
;; (setq lean4-path lean4-project-list)
(setq lean4-path nil)
;; (set-lean4-project "Init" "~/lean/lean4/src/Init")
;; (set-lean4-project "PurePtr" ".")
;; (set-lean-path)
;; (getenv "LEAN_PATH")
;; (setenv "LEAN_PATH")
;; (setenv "LEAN_ROOT" (expand-file-name "~/lean/lean4"))

;; (defun lean--version ()
;;   (let ((version-line (car (process-lines "lean" "-v"))))
;;     (setq version-line (string-remove-prefix "Lean (version " version-line))
;;     (setq version-line (split-string version-line (rx (or "." " " ","))))
;;     (-take 3 version-line)))

;; (defun lean-show-version ()
;;   (interactive)
;;   (message "Lean %s" (mapconcat 'identity (lean--version) ".")))

;; (defun lean-select-mode ()
;;   (let ((version (lean--version)))
;;     (cond ((equal (car version) "4") (lean4-mode))
;;           ((equal (car version) "3") (lean-mode)))))

(defun my-lean4-config ()
  (setq lean4-autodetect-lean3 t)
  (define-key lean4-mode-map (kbd "C-c C-g") 'lean4-toggle-info)
  (define-key lean4-mode-map (kbd "M-.") 'xref-find-definitions)
  (add-hook 'lean4-mode-hook 'highlight-symbol-mode)
  ;; (push '("\\.lean$" . lean-select-mode) auto-mode-alist)
  (add-hook 'lean4-mode-hook 'yas-minor-mode)
  (add-hook 'lean4-mode-hook 'lsp-headerline-breadcrumb-mode)
  ;; (add-hook 'lean4-mode-hook 'lean4-create-lsp-workspace)
  )

;; (setq flycheck-mode-hook (-drop 1 flycheck-mode-hook))

;; (remove-hook 'lsp-eldoc-hook 'lsp-document-highlight)
;; (add-hook 'lsp-eldoc-hook 'lsp-document-highlight)

(add-hook 'emacs-lisp-mode-hook 'highlight-symbol-mode)

(defalias 'lean4-find-definition 'xref-find-definitions)

(add-hook 'flycheck-mode-hook
          (lambda ()
            (define-key flycheck-mode-map (kbd "M-n") 'flycheck-next-error)
            (define-key flycheck-mode-map (kbd "M-p") 'flycheck-previous-error)))

;; (defun lean4-create-lsp-workspace ()
;;   (when-let ((root (vc-find-root "." "lakefile.lean")))
;;     (lsp-workspace-folders-add root)))

;; (remove-hook 'lean4-mode-hook 'lean4-create-lsp-workspace)
;; (add-hook 'lean4-mode-hook 'lean4-create-lsp-workspace)

;; (unload-feature 'lean4-mode t)
;; (unload-feature 'lsp-ui t)
;; (unload-feature 'smartparens t)
;; lean4-mode

(setq lsp-enable-links nil)
(setq lsp-headerline-breadcrumb-enable nil)

(setq lean4-lake-test-results nil)

(defun assoc-insert (key value table)
  (cons (cons key value)
        (assoc-delete-all key table)))

(defun lean4-lake-add-test-results (branch hash result)
  (let* ((key default-directory)
         (table (cadr (assoc key lean4-lake-test-results))))
    (setq table (assoc-insert branch
                              (list result hash)
                              table))
    (setq lean4-lake-test-results
          (assoc-insert key
                        (list table nil)
                        lean4-lake-test-results))))

(defun lean4-lake-get-test-table ()
  (let* ((key default-directory)
         (file (concat default-directory "test-result.el")))
    (when-let
        ((entry (cdr (assoc key lean4-lake-test-results))))
      (destructuring-bind (table timestamp) entry
        (when-let ((_ (file-exists-p file))
                   (new-stamp
                    (file-attribute-modification-time
                     (file-attributes file)))
                   (_ (time-less-p timestamp new-stamp)))
          (load-file file)
          (setq lean4-lake-test-results
                (assoc-insert key (list table new-stamp)
                              lean4-lake-test-results))
          (setq entry
                (cdr (assoc key lean4-lake-test-results)))))
      (car entry))))

(defun lean4-lake-get-test-results (branch hash)
  (let* ((key default-directory)
         (table (lean4-lake-get-test-table)))
    (if-let ((entry (assoc branch table)))
      (destructuring-bind (_ r h) entry
        (when (equal hash h)) r))))

(defun lean4-get-core-lib-path ()
  (let* ((bin-path
          (car (last (process-lines
                      "elan" "which" lean4-executable-name))))
         (root (file-name-directory
                (directory-file-name
                 (file-name-directory bin-path)))))
    (concat root "lib/lean/src")))

(defun seq-insert-at (seq idx x)
  (concat
   (seq-take seq idx)
   x
   (seq-drop seq idx)))

(defun seq-insert-before (seq word x)
  (let ((idx (search word seq)))
    (seq-insert-at seq idx x)))

(defun grep-insert-arg (arg &optional ext ignore-dir)
  (let* ((cmd (car grep-find-command))
         (idx (1- (cdr grep-find-command)))
         (cmd
          (seq-insert-at cmd idx
                         (shell-quote-argument arg)))
         (options nil))

    (when ext
        (setq options
              (cons
               (format "-name %s"
                       (shell-quote-argument ext))
               options)))

    (when ignore-dir
        (setq options
              (cons
               (format "-name %s -prune"
                       (shell-quote-argument ignore-dir))
               ;; (format "-path %s -prune -o "
                       ;; (shell-quote-argument
                        ;; (format "./%s/*"
                                ;; ignore-dir)))
               options)))

    (when options
      (setq cmd
            (seq-insert-before
             cmd "-type"
             (concat (mapconcat 'identity
                                options " -o ")
                     " "))))

    cmd))

(defun lean4-find (regexp)
  (interactive "sSearch: ")
  (let ((default-directory (lean4-get-core-lib-path))
        (cmd (grep-insert-arg regexp)))
    (find-grep cmd)))

(defun lean4-find-in-repo (regexp)
  (interactive "sSearch: ")
  (let ((default-directory
          (vc-find-root default-directory ".git"))
        (cmd (grep-insert-arg regexp "*.lean" "lean_packages")))
    (find-grep cmd)))

(grep-compute-defaults)

;; (require 'template)
;; (unload-feature 'template t)
;; (unload-feature 'lean4-mode t)
;; (template-initialize)
