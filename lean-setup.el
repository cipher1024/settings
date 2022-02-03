
;;; Code:
(require 'project)

;; (use-package company
;;     :ensure t)

;; (quelpa '(lean4-mode :repo "leanprover/lean4-mode" :fetcher github))

;; (quelpa '(lean4-mode
;;           :fetcher url
;;           :url "https://raw.githubusercontent.com/leanprover/lean4/lean4-mode/*.el"))

;; (quelpa
;;  '(rainbow-mode :fetcher url
;;                 :url "http://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/packages/rainbow-mode/rainbow-mode.el"))


(defmacro enable-info-buffer (buffer-or-name panel &rest body)
  "Create and animate an information buffer select where it will be displayed.

BUFFER-OR-NAME is the buffer that will be created by a mode
PANEL specifies where BUFFER-OR-NAME should be displayed
BODY is a series of instructions that will result in the creation of BUFFER-OR-NAME"
  (cons 'progn
	(append
	 body
	 `((dolist (x (get-buffer-window-list ,buffer-or-name))
	     (switch-to-prev-buffer x)))
	 `((set-window-buffer ,panel ,buffer-or-name)))))

;; (setq lean-mode-required-packages
;;       '(lean-mode helm-lean company-lean company dash dash-functional f
;; 		flycheck let-alist s seq))

;; (let ((need-to-refresh t))
;;   (dolist (p lean-mode-required-packages)
;;     (when (not (package-installed-p p))
;;       (when need-to-refresh
;;         (package-refresh-contents)
;;         (setq need-to-refresh nil))
;;       (package-install p))))

(use-package dash)
(use-package dash-functional)
(use-package f)
(use-package lsp-mode)
(quelpa '(lean-mode :repo "cipher1024/lean-mode" :fetcher github))
(quelpa '(helm-lean :repo "cipher1024/lean-mode" :fetcher github))
(quelpa '(company-lean :repo "cipher1024/lean-mode" :fetcher github))
;; (quelpa '(lean-mode :repo "leanprover/lean-mode" :fetcher github))
;; (quelpa '(helm-lean :repo "leanprover/lean-mode" :fetcher github))
;; (quelpa '(company-lean :repo "leanprover/lean-mode" :fetcher github))

;; (defmacro lean-with-current-buffer-maybe (bufname &rest body)
;;   "If BUFNAME is a live buffer, run BODY in it."
;;   (declare (indent defun)
;;            (debug t))
;;   `(-when-let* ((bufname ,bufname)
;;                 (buf (get-buffer bufname)))
;;      (with-current-buffer buf
;;        ,@body)))

;; (defun lean--make-diff-temp-buffer (bufname string prefix)
;;   "Insert STRING into BUFNAME, with optional PREFIX."
;;   (with-current-buffer (get-buffer-create bufname)
;;     (let ((inhibit-read-only t))
;;       (erase-buffer)
;;       (when prefix (insert prefix))
;;       (insert string)
;;       (newline))
;;     (current-buffer)))

;; (defun lean-diff-strings (s1 s2 prefix diff-buffer-name context)
;;   "Compare S1 and S2, with PREFIX.
;; Use DIFF-BUFFER-NAME to name newly created buffers.  Display CONTEXT lines
;; of context around differences."
;;   (let ((same-window-buffer-names '("*Diff*"))
;;         (b1 (lean--make-diff-temp-buffer (format "*lean-%s-A*" diff-buffer-name) s1 prefix))
;;         (b2 (lean--make-diff-temp-buffer (format "*lean-%s-B*" diff-buffer-name) s2 prefix)))
;;     (set-window-dedicated-p (selected-window) nil)
;;     (lean-with-current-buffer-maybe diff-buffer-name
;;       (kill-buffer))
;;     (unwind-protect
;;         (diff b1 b2 `(,(format "--unified=%d" context) "--minimal" "--ignore-all-space") 'noasync)
;;       (kill-buffer b1)
;;       (kill-buffer b2))
;;     (lean-with-current-buffer-maybe "*Diff*"
;;       (diff-refine-hunk)
;;       (rename-buffer diff-buffer-name)
;;       (save-excursion
;;         (goto-char (point-min))
;;         (let ((inhibit-read-only t))
;;           (when (re-search-forward "^@@" nil t)
;;             (delete-region (point-min) (match-beginning 0)))
;;           (while (re-search-forward " *\n *\n\\( *\n\\)+" nil t)
;;             ;; Remove spurious spacing added to prevent diff from mixing terms
;;             (replace-match "\n" t t)))))))

;; (defun lean-not-is-expected (x)
;;   (not (equal "but is expected to have type" x)))
;; (defun lean-not-is-actual (x)
;;   (not (equal "has type" x)))

;; (defun lean-diff-types ()
;;   (interactive)
;;   (let* ((errs (with-current-buffer (get-buffer lean-next-error-buffer-name)
;;                   (buffer-substring-no-properties (point-min) (point-max))))
;;          (lns (split-string errs "\n"))
;;          (msg (seq-take-while 'lean-not-is-actual lns))
;;          (types (seq-drop (seq-drop-while 'lean-not-is-actual lns) 1 ))
;;          (expected (seq-take-while (lambda (x) (not (string-empty-p x)))
;;                                    (seq-drop (seq-drop-while 'lean-not-is-expected types) 1)))
;;          (actual (seq-take-while 'lean-not-is-expected types)))
;;     (unless (null expected)
;;       (save-selected-window
;;         (with-current-buffer (get-buffer-create "*lean-diff*")
;;           (pop-to-buffer
;;            ;; (switch-to-buffer-other-window
;;            (current-buffer) '())
;;           (lean-diff-strings (mapconcat 'identity actual "\n")
;;                              (mapconcat 'identity expected "\n")
;;                              "type: " "*lean-diff*" 5)
;;           (with-current-buffer (get-buffer-create "*lean-diff*")
;;             (let ((buffer-read-only nil))
;;               (save-excursion
;;                 (insert (mapconcat 'identity msg "\n" ))
;;                 (insert "\n")))))))))

;; (require 'unicode-fonts)
(use-package company
  :ensure t
  :diminish ""
  :init
  :config
  (global-company-mode)
  (define-key company-mode-map (kbd "S-SPC") #'company-complete))

;; (global-set-key (kbd "S-SPC") #'company-complete)

;; (if (not (boundp 'lean-version))
;;     (setq lean-version "master"))

;; You need to modify the following two lines:
;; (if lean-rootdir
;;     (progn
;;       (setq load-path (delq lean-rootdir (delq lean-emacs-path load-path)))
;;       (unload-feature 'lean-mode t)))
;; (setq lean-rootdir (format "~/lean/lean-%s" lean-version))
;; (setq lean-bin (format "%s/bin" lean-rootdir))
;; (setq lean-emacs-path (format "%s/src/emacs" lean-rootdir))
;; (setenv "PATH" (concat lean-bin ":" (getenv "PATH") ":" lean-bin))
;; (setq lean-rootdir "~/lean/lean-3.3.0")
;; (setq lean-emacs-path "~/lean/lean/src/emacs")

;; (setq lean-projects '())

(defun lean-make-file ()
  (interactive)
  ;; (unless (member (buffer-file-name) lean-projects)
  ;;   (add-to-list 'lean-projects (buffer-file-name)) )
    (lean-execute "--make")
    (let ((check-mode lean-server-check-mode)
          (buf (current-buffer)))
      (lean-check-nothing)
      (let ((pcs (get-buffer-process "*compilation*")))
        (with-current-buffer "*compilation*"
          (setq-local previous-sentinel (process-sentinel pcs))
          (print (format "disabling Lean checking"))
          (setq-local lean-check-mode check-mode)
          (setq-local lean-buffer buf)
          (set-process-sentinel pcs
                                (lambda (a b)
                                  (with-current-buffer "*compilation*"
                                    (print (format "setting Lean checking: %s" lean-check-mode))
                                    (apply previous-sentinel a b nil)
                                    (let ((check-mode lean-check-mode))
                                      (with-current-buffer lean-buffer
                                        (lean-set-check-mode check-mode)
                                        (print "restart server")
                                        (lean-server-restart))))))
          ))))

;; (with-current-buffer "*compilation*"
;;   (cons lean-check-mode lean-buffer)
;;       )

(defun lean-compile-string-2 (exe-name args file-names)
  "Concatenate EXE-NAME, ARGS, and FILE-NAME."
  (format "%s %s %s" exe-name args (mapconcat 'identity file-names " ")))

(defun lean-execute-2 (&optional arg files)
  "Execute Lean in the current buffer."
  (interactive)
  (when (called-interactively-p 'any)
    (setq arg (read-string "arg: " arg)))
  (let ((cc compile-command)
        (target-file-name
         (or files
             (if (buffer-file-name)
                 (list (buffer-file-name))
               (list (flymake-init-create-temp-buffer-copy
                      'lean-create-temp-in-system-tempdir))))))
    (print (shell-quote-argument (f-full (lean-get-executable lean-executable-name))))
    (print (or arg ""))
    (print (map 'list (lambda (x) (shell-quote-argument (f-full x))) target-file-name))
    (compile (lean-compile-string-2
              (shell-quote-argument (f-full (lean-get-executable lean-executable-name)))
              (or arg "")
              (map 'list (lambda (x) (shell-quote-argument (f-full x))) target-file-name)))
    ;; restore old value
    (setq compile-command cc)))

;; (magit-refresh-all)

(defun call-make ()
  (interactive)
  (when-let (default-directory (find-root-dir "Makefile"))
    (compile "make")))

;; (call-make)

(defun lean-make-project ()
  (interactive)
  ;; (unless (member (buffer-file-name) lean-projects)
  ;;   (add-to-list 'lean-projects (buffer-file-name)) )

  (let* ((root (find-root-dir-safe "leanpkg.toml"))
         (default-directory root))
    (lean-execute-2 "--make" (list (f-join root "src")))))

;; (defun lean-make-changes ()
;;   (interactive)
;;   (print "a"))

(defun lean-make-changes ()
  (interactive)
  ;; (unless (member (buffer-file-name) lean-projects)
  ;;   (add-to-list 'lean-projects (buffer-file-name)) )
  (print "c")

  (let* ((root (find-root-dir-safe "leanpkg.toml"))
         ;; (root (file-name-directory (directory-file-name (magit-git-dir))))
         (default-directory root)
         (modified-files
          (magit--with-refresh-cache
              (list 'magit-git-dir)
            (map 'list (lambda (x) (expand-file-name x root))
                 (append (magit-unstaged-files)
                         (magit-staged-files)))))
         )
    ;; (print "a")
    (print modified-files)
    ;; (print "b")
    (lean-execute-2 "--make" modified-files)))


(use-package unicode-fonts
  :ensure t)

;; (mac-command-modifier ?\:)
 ;; (input-decode-map)
;; key-translation-map

;; (set-window-dedicated-p (get-buffer-window) t)

(defcustom lean-keybinding-make-file (kbd "C-c C-c")
  "Lean Keybinding for std-exe #1"
  :group 'lean-keybinding :type 'key-sequence)

;; (unload-feature 'lean-mode t)
;; (unload-feature 'magit t)
;; (require 'magit)

;; (set-window-dedicated-p (get-buffer-window "*Lean Goal*") t)
;; (set-window-dedicated-p (get-buffer-window "*Lean Next Error*") t)

;; (setq load-path (cons lean-emacs-path load-path))
(use-package lean-mode
  :ensure t
  :config
  (add-hook 'lean-mode-hook 'set-truncate-lines)
  (add-hook 'lean-mode-hook 'highlight-symbol-mode)
  (add-hook 'lean-mode-hook 'yas-minor-mode)

;; (add-hook 'lean-mode-hook 'flycheck-inline-mode nil t)

  (define-key lean-mode-map (kbd "C-c C-t") 'lean-diff-types)
  (define-key lean-mode-map (kbd "C-c C-c") #'lean-make-file)
  (unicode-fonts-setup)
  ;; (setq prettify-symbols-alist
  ;;       '(">>=" . ?))
  ;; (prettify-symbols-mode)
  (lean-input-incorporate-changed-setting
   'lean-input-user-translations
   `( ("func" "⥤")
      ("McE" "ℰ")
      ("iP" "⨿")
      ("boxvert" "◫")
      ("++" "⧺")
      ("sb1" "𝟭")
      ;; (list "+" "++")
      ;; ("^b_" ,(lean-input-to-string-list "ᵇ"))

      ))
  )


;; (defun unload-lean ()
;;   (unload-feature 'lean-setup)
;;   (unload-feature 'lean-mode)
;;   (setenv "PATH" (string-join (delete lean-bin (split-string (getenv "PATH") ":")) ":"))
;;   (setq load-path (delq lean-rootdir (delete lean-emacs-path load-path))))

;; (defun reload-lean (&optional version)
;;   (unload-lean)
;;   (if version
;;       (setq lean-version version)
;;     (setq lean-version "master"))
;;   (load 'lean-setup))

;; (defun set-lean-version (version)
;;   (if (not (equal version lean-version))
;;       (reload-lean version)))

(defmacro mk-layout-window (name &rest def)
  `(progn
     (defun ,(make-symbol (concat "get-" (symbol-name name))) ()
       (if (and (boundp (quote ,name))
		(windowp ,name))
	   ,name
	 ,(cons 'progn def)))))

(defmacro orelse (x y)
  (let ((var (make-symbol "var")))
  `(let ((,var ,x))
     (if ,var ,var ,y))))

(defmacro first-non-nil (&rest instr)
  (if (null instr) 'nil
    `(orelse ,(car instr) (first-non-nil ,@(cdr instr)))))

(defmacro mk-window-getter (name &rest def)
  `(if (and (boundp (quote ,name))
	    ,name
	    (window-live-p ,name))
       ,name
     (progn
       (setq ,name (first-non-nil ,@def))
       ,name)))

(defun reset-display ()
  (setq first-window nil)
  (setq second-window nil)
  (setq bottom-right-panel nil)
  (setq top-right-panel nil))

;; (reset-display)
(defun get-first-window ()
  (mk-window-getter
   first-window
   (car (window-list))))
;; (get-first-window)
;; (def-layout-window first-window (car (window-list)))

;; (def-layout-window second-window
;;   (orelse (window-in-direction 'below (get-first-window))
;; 	  (split-window-below (get-first-window))))
(defun get-second-window ()
    (mk-window-getter second-window
		      (window-in-direction 'below (get-first-window))
		      (split-window (get-first-window) nil 'below)))
;; (get-second-window)
;; (selected-window)
;; (def-layout-window top-right-panel
;;   (orelse (window-in-direction 'right (get-first-window))
;; 	  (split-window-right (get-first-window))))
(defun window-parent-or-self (window)
  (orelse (window-parent window) window))

; (defun window-right (w)
;   (when (window-combined-p w t)
;     (window-next-sibling w)))

; (defun window-below (w)
;   (when (window-combined-p w)
;     (window-next-sibling w)))

(defun get-top-right-panel ()
  (mk-window-getter top-right-panel
		    (when (and (boundp 'bottom-right-panel)
			       (window-live-p bottom-right-panel))
		      (orelse
		       (window-in-direction 'above bottom-right-panel)
		       (split-window bottom-right-panel nil 'above)))
		    (window-right (window-parent-or-self (get-first-window)))
		    (split-window (window-parent-or-self (get-first-window)) nil 'right)))
;; (window-tree)
;; (window-list)
;; (split-window nil 'above)
;; (get-top-right-panel)
(defun get-bottom-right-panel ()
  (mk-window-getter bottom-right-panel
		    (when (and (boundp 'top-right-panel)
			       (window-live-p top-right-panel))
		      (orelse
		       (window-in-direction 'below (get-top-right-panel))
		       (split-window (get-top-right-panel) nil 'below)))
		    (split-window (window-parent-or-self (get-first-window)) nil 'right)))
;; (get-bottom-right-panel)
;; (def-layout-window bottom-right-panel
;;   (orelse (window-in-direction 'below (get-top-right-panel))
;; 	  (split-window-below (get-top-right-panel))))

;; (defun setup-lean-displays ()
;;   "documentation"
;;   (progn
;;     (setq first-window (selected-window))
;;     (setq top-right-panel (split-window-right))
;;     (select-window top-right-panel)
;;     (setq bottom-right-panel (split-window-below))
;;     (select-window first-window)
;;     (setq second-window (split-window-below))
;;     (enable-info-buffer lean-show-goal-buffer-name top-right-panel
;; 			(lean-toggle-show-goal))
;;     (enable-info-buffer lean-next-error-buffer-name bottom-right-panel
;; 			(lean-toggle-next-error))
;;     (enable-info-buffer flycheck-error-list-buffer bottom-right-panel
;; 			(flycheck-mode)
;; 			(flycheck-list-errors))
;;     ))

(defun lean-put-errors-below-goal ()
  (interactive)
  (if-let ((w1 (get-buffer-window (get-buffer "*Lean Goal*")))
           (b-next-error (get-buffer "*Lean Next Error*")))
      (let ((w2 (split-window w1)))
        (set-window-buffer w2 b-next-error)
        ;; (set-window-dedicated-p w2 t)
        ;; (set-window-dedicated-p w1 t)
        )
    (message "no such buffers")))

;; (lean-toggle-show-goal)
;; (lean-toggle-next-error)

(defun lean-goal-error-tiling ()
  (interactive)
  (-if-let (window (get-buffer-window lean-next-error-buffer-name))
      (quit-window t window))
  (-if-let (window (get-buffer-window lean-show-goal-buffer-name))
      (quit-window t window))
  (let* ((w1 (get-buffer-window (current-buffer)))
         (w2 (split-window w1 nil 'right))
         (w3 (split-window w2 nil 'below))
         )
    (lean-ensure-info-buffer lean-next-error-buffer-name)
    (lean-ensure-info-buffer lean-show-goal-buffer-name)
    (set-window-buffer w2 lean-show-goal-buffer-name)
    (set-window-buffer w3 lean-next-error-buffer-name)
    ;; (set-window-dedicated-p w2 t)
    ;; (set-window-dedicated-p w3 t)
    (lean-next-error--handler)
    (lean-show-goal--handler)
  ))

(defun lean-toggle-info-buffer-in-window (buffer w)
  (-if-let (window (get-buffer-window buffer))
      (quit-window nil window)
    (lean-ensure-info-buffer buffer)
    (display-buffer buffer)))

(defun lean-toggle-next-error ()
  (interactive)
  (lean-toggle-info-buffer lean-next-error-buffer-name)
  (lean-next-error--handler))

(defun lean-toggle-show-goal ()
  "Show goal at the current point."
  (interactive)
  (lean-toggle-info-buffer lean-show-goal-buffer-name)
  (lean-show-goal--handler))



(setenv "LEAN_PATH")

;; (setq lean-projects
;;       (list (cons "unit-b" "~/lean/unity/semantics-lean/src")
;; 	    (cons "slim_check" "~/lean/slim_check")
;; 	    (cons "modexp" "~/lean/modexp")
;; 	    (cons "refine-tutorial" "~/lean/tutorials/writing a tactic")
;; 	    (cons "temporal-logic" "~/lean/temporal-logic")
;; 	    (cons "separation-logic" "~/lean/separation-logic")
;; 	    (cons "lean-lib" "~/lean/lean-lib")
;; 	    (cons "lambda-calc" "~/lean/lambda-calc")
;; 	    (cons "pipes" "~/lean/pipes")
;; 	    (cons "unitb-pointers" "~/lean/unitb-pointers")
;; 	    (cons "lean-prover" "~/lean/lean-master/")
;; 	    (cons "mathlib" "~/lean/mathlib/")
;; 	    (cons "differential-topology" "~/lean/lean-differential-topology/")
;; 	    ))

;; buffer-file-name
;; (progn
;;   (mapc 'print (mapcar 'buffer-name (buffer-list)))
;;   t)

(defun find-file-in (file window)
  (let ((curr (selected-window)))
    (select-window window)
    (let ((r (find-file file)))
      (select-window curr)
      r)))

(defun in-first-window (file)
    (find-file-in file (get-first-window)))

(defun in-second-window (file)
    (find-file-in file (get-second-window)))

(defun in-top-right-panel (file)
    (find-file-in file (get-top-right-panel)))

(defun not-libp (lib-pat path)
  (if (listp lib-pat)
      (null (seq-filter (lambda (p) (string-match p path)) lib-pat))
      (not (string-match lib-pat path))))
;; (seq-filter 'not-libp '("/foo/_target/" "bar" "/bar/_target/" "foo"))

(defun lean-serverp (path)
  (string-match "*lean-server std" (buffer-name path)))

(defun lean-select (prj)
  (select-project-source (cdr (assoc prj lean-projects)) "\\.lean" "/_target/"))

(defun lean-kill-servers ()
  (interactive)
  (mapc 'kill-buffer
	(seq-filter 'lean-serverp (buffer-list))))

(defun select-project-source (path ext lib-pat)
  (let* ((ls (last-n-mod-sources path ext lib-pat 2))
	 (d (print path))
	 (d (print ls))
	 (buf (find-file (car ls))))
	 ;; (shell-name (concat "sh: " prj)))
    ;; ;; (register-project prj path (list shell-name))
    ;; (find-file-in (car ls) (get-first-window))

    (find-file-other-window (concat path "/todo.org"))
    (set-buffer buf)
    ;; ;; (find-file-in (cadr ls) (get-second-window))
    ;; ;; (select-window (get-bottom-right-panel))
    ;; (setq default-directory path)
    ;; (select-window first-window)
    ;; (enable-info-buffer lean-show-goal-buffer-name (get-top-right-panel)
    ;; 			(lean-toggle-show-goal))
    ;; ;; (enable-info-buffer lean-next-error-buffer-name (get-bottom-right-panel)
    ;; ;; 			(lean-toggle-next-error))
    ;; ;; (enable-info-buffer flycheck-error-list-buffer (get-bottom-right-panel)
    ;; ;; 			(flycheck-mode)
    ;; ;; 			(flycheck-list-errors))
    ;; (setq current-directory path)
    ;; (pe/start-follow-current)
    ;; ;; (let ((sh (get-buffer shell-name)))
    ;; ;;   (if (not sh)
    ;; ;; 	  (progn
    ;; ;; 	    (select-window (get-bottom-right-panel))
    ;; ;; 	    (set-buffer (eshell))
    ;; ;; 	    (rename-buffer shell-name))
    ;; ;; 	(progn
    ;; ;; 	  (set-window-buffer (get-bottom-right-panel) sh))))
    ;; (close-other-projects)
    ) )

(defun lean-source-p (buffer)
  (when-let (fn (buffer-file-name buffer))
    (equal (file-name-extension fn) "lean")))

(defun kill-lean-sources ()
  (mapc 'kill-buffer
	(seq-filter
	 'lean-source-p (buffer-list))))

;; (find-file-other-window )
;; (selected-window)
;; (cdr (assoc "modexp" lean-projects))

;; (get-buffer-create flycheck-error-list-buffer)
;; (set-window-buffer bottom-right-panel flycheck-error-list-buffer)


;; (select-window bottom-right-panel)
;; (flycheck-mode)
;; (flycheck-get-error-list-window-list)
;; (get-buffer-window flycheck-error-list-buffer)
;; (set-window-buffer bottom-right-panel flycheck-error-list-buffer)
;; (flycheck-list-errors)
;; (set-window-next-buffers bottom-right-panel '("*Lean Goal*"))
;; (window-next-buffers top-right-panel)

; (shell-command "~/lean/fetch-prover.sh 3.3.0 &")
; (shell-command "~/lean/fetch-prover.sh master &")

(defun modification-time (fp)
  (cons (nth 5 (file-attributes fp)) fp))

(defun access-time (fp)
  (nth 4 (file-attributes fp)))

(defun compare-mod-time (x y)
  (version-list-< (car y) (car x)))

(defun take (n xs)
  (if (or (null xs) (<= n 0))
      nil
    (cons (car xs) (take (- n 1) (cdr xs)))))

; (take 3 (list 1 2))
; (take 3 (list 1 2 3 4 5 6))

(defun last-n-mod-sources (dir ext lib-pat n)
  (let* ((mod-files (mapcar 'modification-time (directory-files-recursively dir ext)))
	 (sorted-files (sort mod-files 'compare-mod-time)))
    (take n (seq-filter (-cut not-libp lib-pat <>) (mapcar 'cdr sorted-files)))))

(defun sort-on (ls key-fn cmp)
  (let ((keyed (mapcar (lambda (x) (cons (funcall key-fn x) x)) ls)))
    (mapcar 'cdr (sort keyed cmp))))

(defun last-accessed-sources (dir ext lib-pat)
  (let* ((files (directory-files-recursively dir ext))
	 (sorted-files (sort-on files 'access-time 'compare-mod-time)))
    (seq-filter (-cut not-libp lib-pat <>) sorted-files)))

; (nth 1 (list 1 2 3))

; (version-list-> (list 1) (list 2))
; (compare-mod-time (cons (list 1 2) 3) (cons (list 2 3) 5))
; (sort (mapcar 'modification-time (directory-files-recursively "~/lean/unity/semantics-lean/src" "\\.lean")) 'compare-mod-time)
; (last-n-mod-sources "~/lean/unity/semantics-lean/src" 3)
;; (defun foo (list)
;;   (interactive)
;;   (let ((arg (ido-completing-read "Select from list: " list)))
;;     (print arg)))

;; (setq options (list "apple" "orange"))
;; (flycheck-error-list-mode)
;; (foo options)
;; (defun select-lean-project ()
;;   (let* ((prj (x-popup-menu
;; 	       (list '(50 50) (selected-frame)) ;; where to popup
;; 	       (list "Please choose"            ;; the menu itself
;; 		     (cons "" lean-projects))))
;; 	 (last-open (last-n-mod-sources prj 3)))
;;     (progn
;;       (setq default-directory prj)
;;       ;; (find-file (file-name-as-directory prj))
;;       (mapc 'find-file last-open)
;;       (buffer-menu))))
; (select-lean-project)
; (leanpkg-find-dir-safe)
; (leanpkg-find-path-file)


;; (x-popup-menu
;;    (list '(50 50) (selected-frame)) ;; where to popup
;;    (list "Please choose"            ;; the menu itself
;;          (cons "" lean-projects)))
;;          ;; (cons "" (mapcar (function (lambda (item) (cons item item)))
;; 	 ;; 		  options))))

;; rm -rf /usr/local/lib/lean/library
;; mkdir -p build/release
;; cd build/release
;; cmake -DCMAKE_CXX_COMPILER=ccache-g++ -DCMAKE_BUILD_TYPE=RELEASE -G Ninja ../../src
;; ninja
;; ninja install
;; lean-leanpkg-build

;; ninja clean-olean

;; cmake -DCMAKE_CXX_COMPILER=ccache-g++ -DCMAKE_BUILD_TYPE=DEBUG -G Ninja ../../src

;; Lean 4
;; cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=DEBUG ../../src
;; cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang ../../src

;; cmake -D CMAKE_CXX_COMPILER=/usr/bin/clang++ -D CMAKE_C_COMPILER=/usr/bin/clang ../../src
;; cmake -D CMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++ -D CMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang ../../src

;; (setenv "LEAN_PATH" "../../../library:.")
(defun make-clean ()
  "Call `make clean`"
  (interactive)
  (let ((dir (file-name-as-directory (lean-leanpkg-find-dir-safe)))
        (orig-buf (current-buffer)))
    (with-current-buffer (get-buffer-create "*leanpkg*")
      (setq buffer-read-only nil)
      (erase-buffer)
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (insert "> make clean\n")
      (let* ((default-directory dir)
             (out-buf (current-buffer))
             (proc (start-process "make clean" (current-buffer)
                                  "find" "." "-name" "*.olean" "-delete")))
        nil))))

(defun unlines (lns)
  (mapconcat 'identity lns "\n"))

(defun keep-errors-only (proc string)
  (interactive)
  (let* ((lines (split-string string "\n"))
	 (new-string (seq-filter (lambda (x) (cl-search ": error" x)) lines)))
    (if (not (null new-string))
	(when (buffer-live-p (process-buffer proc))
	  (with-current-buffer (process-buffer proc)
	    (let ((moving (= (point) (process-mark proc))))
	      (save-excursion
		;; Insert the text, advancing the process marker.
		(goto-char (process-mark proc))
		(insert (unlines new-string))
		(set-marker (process-mark proc) (point)))
	      (if moving (goto-char (process-mark proc)))
	      (delete-process proc)))))))

(defun lean-leanpkg-edit-toml ()
  (interactive)
  (let ((dir (lean-leanpkg-find-dir-safe)))
    (find-file (f-join dir "leanpkg.toml"))))

(defun lean-leanpkg-edit-version ()
  (interactive)
  (let ((dir (lean-leanpkg-find-dir-safe)))
    (find-file (f-join dir "lean_version"))))

;; (defun lean-insert-hash ()
;;   (interactive)
;;   (let ((default-directory "~/lean/lean-master"))
;;     (call-process "git" nil (current-buffer) t "rev-parse" "HEAD")))

(defun lean-leanpkg-dev-switch ()
  (interactive)
  (let* ((dir (lean-leanpkg-find-dir-safe))
	 (leanpkg (f-join dir "leanpkg.toml"))
	 (leanpkg-dev (f-join dir "leanpkg-dev.toml"))
	 (leanpkg-bkp (f-join dir "leanpkg-bkp.toml")))
    (if (file-exists-p leanpkg)
	(cond
	 ((file-exists-p leanpkg-dev)
	  (rename-file leanpkg leanpkg-bkp)
	  (rename-file leanpkg-dev leanpkg)
	  (lean-server-restart)
	  (print "switched to dev-mode")
	  )
	 ((file-exists-p leanpkg-bkp)
	  (rename-file leanpkg leanpkg-dev)
	  (rename-file leanpkg-bkp leanpkg)
	  (lean-server-restart)
	  (print "switched to git-mode")
	  )
	 (t
	  (copy-file leanpkg leanpkg-dev)
	  (print "created leanpkg-dev.toml")
	  (find-file leanpkg-dev)))
      (error "no leanpkg.toml found"))))

(defun lean-quiet-sentinel (pcs _e)
  (setq lean-leanpkg-running nil)
  (with-current-buffer (process-buffer pcs)
    (insert "; (done)\n")))

(defun lean-leanpkg-find-dir-in (dir)
  (when dir
    (or (when (f-exists? (f-join dir "leanpkg.toml")) dir)
        (lean-leanpkg-find-dir-in (f-parent dir)))))

(defun lean-leanpkg-run-quiet (cmd)
  "Call `leanpkg $cmd`"
  (let ((dir (file-name-as-directory (lean-leanpkg-find-dir-safe)))
        (orig-buf (current-buffer)))
    (with-current-buffer (get-buffer-create "*leanpkg*")
      (setq buffer-read-only nil)
      (erase-buffer)
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (insert (format "> %s\n> leanpkg %s\n" dir cmd))
      (setq lean-leanpkg-running t)
      (let* ((default-directory dir)
             (proc (make-process :name "leanpkg"
				 :buffer (current-buffer)
				 :filter 'keep-errors-only
				 :sentinel 'lean-quiet-sentinel
                                 :command (list (lean-leanpkg-executable) cmd))))
        t ))))

(defun my-lean-leanpkg-run (prog exe cmd)
  "Call `leanpkg $cmd`"
  (let ((dir (file-name-as-directory (lean-leanpkg-find-dir-safe)))
        (orig-buf (current-buffer))
	(cmd (if (listp cmd) cmd (list cmd))))
    (with-current-buffer (get-buffer-create "*leanpkg*")
      (setq buffer-read-only nil)
      (erase-buffer)
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (insert (format "> %s %s\n" prog cmd))
      (setq lean-leanpkg-running t)
      (let* ((default-directory dir)
             (proc (make-process :name prog
				 :sentinel 'lean-quiet-sentinel
				 :buffer (current-buffer)
                                 :command (cons exe cmd))))
	t))))

(defun lean-leanpkg-profile ()
  (interactive)
  (my-lean-leanpkg-run "leanpkg"
		       (lean-leanpkg-executable)
		       (list "build" "--" "--profile" "--test-suite")))

(defun lean-leanpkg-profile-file ()
  "Profile current file."
  (interactive)
  (my-lean-leanpkg-run "lean" (lean-get-executable lean-executable-name)
		       (list (buffer-file-name) "--profile" "--test-suite")))

(defun lean-leanpkg-build-quiet ()
  "Call leanpkg build (quiet)."
  (interactive)
  (lean-leanpkg-run-quiet "build"))

(defun lean-leanpkg-test-quiet ()
  "Call leanpkg build (quiet)."
  (interactive)
  (lean-leanpkg-run-quiet "test"))

;; (use-package lean-mode
;;   :bind (:map lean-mode-map
;; 	      ("S-SPC" . company-complete)))

(defun lean-core-lib-path ()
  "The path to the version of core lib corresponding to current development."
  (f-join
   (f-parent (f-parent (string-trim (shell-command-to-string "elan which lean"))))
   "lib"
   "lean"
   "library"))

(defun lean-leanpkg-upgrade ()
  "Call leanpkg upgrade."
  (interactive)
  (lean-leanpkg-run "upgrade"))

;; (defun lean-clear-target ()
;;   (interactive)


;; (defun lean-show-goal-and-error-list ()
;;   "Enable flycheck and display its error list as well as Lean's current goal."
;;   (interactive)
;;   (enable-info-buffer
;;    lean-show-goal-buffer-name
;;    (get-top-right-panel)
;;    (lean-toggle-show-goal))
;;   (enable-info-buffer
;;    flycheck-error-list-buffer
;;    (get-bottom-right-panel)
;;    (flycheck-mode)
;;    (flycheck-list-errors)))

;; (defun lean-jump-to-error-message ()
;;   (interactive)
;;   (enable-info-buffer
;;    lean-next-error-buffer-name
;;    (get-top-right-panel)
;;    (lean-toggle-next-error))
;;   (select-window (get-top-right-panel)))

;; ;; DELETE THESE
;; (global-set-key (kbd "C-x l") 'lean-show-goal-and-error-list)
;; (global-set-key (kbd "C-x C-l") 'lean-jump-to-error-message)
;; ;; (add-hook 'lean-mode-hook 'lean-show-goal-and-error-list)

(defconst lean-cmd-keywords1
  '("import" "prelude" "protected" "private" "noncomputable" "definition" "meta" "renaming"
    "hiding" "exposing" "parameter" "parameters" "constant" "constants"
    "lemma" "variable" "variables" "theorem" "example" "abbreviation"
    "open" "export" "axiom" "axioms" "inductive" "coinductive"
    "structure" "universe" "universes" "hide"
    "precedence" "reserve" "declare_trace" "add_key_equivalence"
    "infix" "infixl" "infixr" "notation" "postfix" "prefix" "instance"
    "namespace" "section"
    "attribute" "local" "set_option" "extends" "include" "omit" "classes" "class"
    "attributes" "raw" "replacing" "@"
    "mutual" "def" "run_cmd"))

(defconst lean-cmd-keywords1-regexp
  (eval `(rx word-start (or ,@lean-cmd-keywords1) word-end)))

(cl-defun lean-def-definition-text (&key file line column)
  ;; (when (fboundp 'xref-push-marker-stack) (xref-push-marker-stack))
  ;; (when file
  ;;   (find-file file))
  ;; (goto-char (point-min))
  ;; (forward-line (1- line))
  ;; (forward-char column))
  (let ((buf (get-file-buffer file)))
    (with-current-buffer (or buf
			     (find-file-noselect file))
      (goto-char (point-min))
      (forward-line (1- line))
      (forward-char column)
      (re-search-backward lean-cmd-keywords1-regexp)
      (print "wha?")
      (let ((p1 (point)))
	(re-search-forward lean-cmd-keywords1-regexp)
	(re-search-forward lean-cmd-keywords1-regexp)
	(re-search-backward lean-cmd-keywords1-regexp)
	(print "oh ...")
	(let ((r (buffer-substring-no-properties p1 (point))))
	  (unless buf
	    (kill-buffer))
	  r)))))

(defun lean-show-definition-b ()
  (interactive)
  (with-current-buffer (get-buffer "*lean-definition-info*")
    (erase-buffer)
    (set-truncate-lines)
    (insert (unbounded-pp
	     (lean-server-send-synchronous-command
	      'search (list :query helm-pattern))))
    (switch-to-buffer-other-window (current-buffer))))

;; (switch-to-buffer-other-window
;;  (progn
;;    (lean-ensure-info-buffer "*lean-definition-info*")
;;    (get-buffer "*lean-definition-info*")))

(defun lean-show-definition ()
  (interactive)
  (lean-get-info-record-at-point
   (lambda (info-record)
     (let* ((src (plist-get info-record :source)))
       (lean-ensure-info-buffer "*lean-definition-info*")
       (with-current-buffer (get-buffer "*lean-definition-info*")
	 (erase-buffer)
	 (insert (apply #'lean-def-definition-text src))
	 (goto-char (point-min))
	 (switch-to-buffer-other-window (current-buffer)))))))

     ;; (-if-let (source-record (plist-get info-record :source))
     ;;     (apply #'lean-find-definition-cont source-record)
     ;;   (-if-let (id (plist-get info-record :full-id))
     ;;       (message "no source location available for %s" id)
     ;;     (message "unknown thing at point")))

(defun lean-leanpkg-clean ()
  (interactive)
  (let ((default-directory (lean-leanpkg-find-dir-safe)))
    (call-process "find" nil nil nil "." "-name" "*.olean" "-delete")))
  	;; /usr/bin/find . -name "*.olean" -delete

(defun lean-sphinx-snippet ()
  (interactive)
  (let ((cur nil))
    (goto-char (line-beginning-position))
    (insert (mapconcat 'identity
                       '(".. code-block:: lean"
                         ""
                         ;; "    namespace hidden"
                         ;; ""
                         "    -- BEGIN"
                         "    ")
                       "\n"))
    (setq cur (point))
    (insert (mapconcat 'identity
                       '(""
                         "    -- END"
                         ;; ""
                         ;; "    end hidden"
                         "    ")
                       "\n"))
    (goto-char cur)))

(defun parse-pos (str adj)
  (save-excursion
    (let* ((pos (split-string str ":"))
          (ln (string-to-number (nth 0 pos)))
          (col (string-to-number (nth 1 pos)))
          (kw "Try this:"))
      (if-let ((loc (string-match kw str)))
          (let* ((idx (+ loc (length kw)))
                 (suggestion (substring-no-properties str idx))
                 )
            (goto-line ln)
            (move-to-column (+ col adj))
            (delete-region (point) (line-end-position))
            (insert (format "%s," (string-trim suggestion)))
            )
        (let ((suggestion (mapconcat 'identity (cddr pos) "\n"))
              (indent (make-string (- col 1) ? )))
          (insert (format "%s\n%s" (string-trim suggestion) indent))
      )))))

(defun trim-blank-lines (beg-ln pt)
      (save-excursion
  (let ((ln (line-number-at-pos pt)))
    (goto-char pt)
    (if (= ln beg-ln)
        (if (equalp (char-before pt) (string-to-char " "))
            (progn (backward-char 1)
                   (trim-blank-lines beg-ln (point)))
          pt)
        (if (seq-every-p
              (lambda (x) (equalp x (string-to-char " ")))
              (buffer-substring-no-properties (line-beginning-position) (point)))
            (progn (forward-line (- 1)) (end-of-line)
                   (trim-blank-lines beg-ln (point)))
          pt)))))

;; (buffer-file-name)
(defun lean-apply-suggestion ()
  (interactive)
  ;; (with-current-buffer
  ;;     (get-file-buffer "/Users/simon/lean/mathlib/src/order/omega_complete_partial_order.lean")
    (let* ((advice
            (with-current-buffer lean-next-error-buffer-name
              (buffer-substring-no-properties (point-min) (point-max))))
           ;; (lns (split-string advice "\n"))
           ;; (repl (mapconcat 'identity (seq-take-while (lambda (x) (not (seq-empty-p x))) (seq-drop lns 2)) "\n"))
           (beg (parse-pos advice -1))

           ;; (end (parse-pos advice 0))
           ;; (last-line (trim-blank-lines (line-number-at-pos beg) end))
          ;; (current (buffer-substring-no-properties beg end))
           )
      beg
      ;; (insert beg)
      ;; (message "%S\n%S" beg advice)
      ;; (delete-region beg last-line)
      ;; (goto-char beg)
      ;; (insert repl)
      ;; (goto-char beg)
      ;; (message (format " ->\n%S\n%S" repl (buffer-substring-no-properties beg last-line)))
      ))

;; (defun lean-apply-suggestion ()
;;   (interactive)
;;   (with-current-buffer
;;       (get-file-buffer "~/lean/mathlib/data/multiset.lean")
;;     (let* ((advice
;;             (with-current-buffer lean-next-error-buffer-name
;;               (buffer-substring-no-properties (point-min) (point-max))))
;;            (lns (split-string advice "\n"))
;;            (repl (mapconcat 'identity (seq-take-while (lambda (x) (not (seq-empty-p x))) (seq-drop lns 2)) "\n"))
;;            (beg (parse-pos (nth 0 lns) -1))
;;            (end (parse-pos (nth 1 lns) 0))
;;            (last-line (trim-blank-lines (line-number-at-pos beg) end))
;;           ;; (current (buffer-substring-no-properties beg end))
;;           )
;;       (delete-region beg last-line)
;;       (goto-char beg)
;;       (insert repl)
;;       (goto-char beg)
;;       (message (format " ->\n%S\n%S" repl (buffer-substring-no-properties beg last-line))))))

(defun lean-get-tactic-snippet ()
  (with-current-buffer lean-next-error-buffer-name
    (goto-char (point-min))
    (search-forward "=== INSERT AT ")
    (let* ((pos
            (progn (looking-at "[0-9]+")
                   (match-data t)))
           (loc (string-to-number (buffer-substring-no-properties (car pos) (cadr pos))))
           (subject
            (buffer-substring-no-properties
             (progn
               (search-forward "\n")
               (skip-blank-lines)
               (point))
             (progn
               (search-forward "=== END INSERT ===")
               (beginning-of-line)
               (point)))))
      (cons loc subject))))

(defun insert-at-line (text line)
  (save-excursion
    (goto-char (point-min))
    (forward-line line)
    (insert text)
    ))

(defun skip-blank-lines ()
  (when (equal
         (substring-no-properties (thing-at-point 'line))
         "\n")
    (forward-line)
    (skip-blank-lines)))

;; (with-current-buffer (get-buffer "tactics.lean")
(defun lean-insert-suggestion ()
  (interactive)
  (let ((x (lean-get-tactic-snippet)))
    (let ((line (car x))
          (snippet (cdr x)))
      (insert-at-line snippet line))))

(defun lean-insert-stub ()
  (interactive)
  ;; (insert "{!  !}")
  ;; (forward-char -3)
  ;; (let ((p (point)))
  ;; (let ((start-pos p)
  ;;       (end-pos p))
  ;;   (let ((start-marker (make-marker))
  ;;         (end-marker (make-marker)))
  ;;     (set-marker start-marker start-pos (current-buffer))
  ;;     (set-marker end-marker end-pos (current-buffer))
  ;;     (lean-hole--command "Instance Stub" start-marker end-marker))))
  )



(add-hook 'rst-mode-hook (lambda () (set-input-method "Lean")))
(add-hook 'rst-mode-hook 'auto-fill-mode)

(defun query-swap-read-args (prompt regexp-flag &optional noerror)
  (unless noerror
    (barf-if-buffer-read-only))
  (let* ((from (query-replace-read-from prompt regexp-flag))
	 (to (if (consp from) (prog1 (cdr from) (setq from (car from)))
	       (query-replace-read-to from prompt regexp-flag)))
         (placeholder (query-replace-read-to from prompt regexp-flag)))
    (list from to
          placeholder
	  (and current-prefix-arg (not (eq current-prefix-arg '-)))
	  (and current-prefix-arg (eq current-prefix-arg '-)))))


;; (defun swap-strings (A-string B-string placeholder &optional delimited start end backward)
;;   (interactive
;;    (let ((common
;; 	  (query-swap-read-args
;; 	   (concat "Swap"
;; 		   (if current-prefix-arg
;; 		       (if (eq current-prefix-arg '-) " backward" " word")
;; 		     "")
;; 		   " string"
;; 		   (if (use-region-p) " in region" ""))
;; 	   nil)))
;;      (list (nth 0 common) (nth 1 common) (nth 2 common) (nth 3 common)
;; 	   (if (use-region-p) (region-beginning))
;; 	   (if (use-region-p) (region-end))
;; 	   (nth 4 common))))
;;   (print "params:") (print A-string) (print B-string) (print placeholder)
;;   (replace-string A-string placeholder delimited start end backward)
;;   (replace-string B-string A-string delimited start end backward)
;;   (replace-string placeholder B-string delimited start end backward))


;;
;; LEAN 4

(defun lean-upcase-module-name ()
  (interactive)
  (replace-current-word
   (lambda (x)
     (print x)
     (print (split-string x "\\."))
     (mapconcat 'capitalize (split-string x "\\.") "." )
                          ))
  ;; (print (current-word)) ;; foo.bar?
  )
;; capitalize-region
;; (lean-upcase-module-name)

;; delete-region
;; (forward-word) (backward-word)

(defun replace-region (x y txt)
  (delete-region x y)
  (save-restriction
    (narrow-to-region x x)
    (insert txt)))

(defun replace-current-word (fn)
  (save-mark-and-excursion
   (forward-word)
   (let ((x (point-marker)))
     (backward-word)
     (let* ((y (point-marker))
            (txt (buffer-substring-no-properties x y)))
       (replace-region x y (funcall fn txt))
       )
     )
   ))

(use-package string-inflection)

(global-set-key (kbd "C-c i") 'string-inflection-cycle)
(global-set-key (kbd "C-c C") 'string-inflection-camelcase)        ;; Force to CamelCase
(global-set-key (kbd "C-c L") 'string-inflection-lower-camelcase)  ;; Force to lowerCamelCase

;; (replace-current-word (lambda (x) (seq-concatenate 'string x "-do?")))

;; (mapconcat 'capitalize (split-string "init.lean.server" "\\.") "." )
;; lean4-mode
;; (forward-word-strictly)init.lean.server
;; (unload-feature 'lean4-mode)
(use-package lsp-mode
  :ensure t)

(quelpa '(lean4-mode :path "~/lean/lean4/lean4-mode" :fetcher file))
(custom-set-variables '(lean4-rootdir "/usr/local/"))
(modify-coding-system-alist 'file "\\.lean\\'" 'utf-8)
(delete (cons "\\.lean$" #'lean4-mode) auto-mode-alist)
(delete (cons "\\.hlean$" #'lean4-mode) auto-mode-alist)
;; (assoc "\\.lean$" auto-mode-alist)
;; (rassoc 'lean4-mode auto-mode-alist)
;; (insert (unbounded-pp auto-mode-alist))
;; (length auto-mode-alist)

;; (require 'lean4-mode)
;; (unload-feature 'lean4-mode t)
;; (lean4-flycheck-init)

;; (use-package lean4-mode
;;   :quelpa
;;   (yasnippet-lean
;;    :fetcher github :repo "leanprover/lean4/lean4-mode"
;;    ;; :fetcher file :path "~/lean/lean4/lean4-mode/"
;;    ;; :fetcher url :url "file:///Users/simon/.emacs.d/yasnippet-lean/yasnippet-lean.el"
;;    :files ("yasnippet-lean.el" "snippets")))
;;   ;; (yasnippet-lean :fetcher file :path "~/.emacs.d/yasnippet-lean/yasnippet-lean.el"))


;; https://github.com/leanprover/lean4/tree/master/lean4-mode

(add-hook 'lean4-mode-hook 'yas-minor-mode)

;;
;; Refactor
;;

(persistent lean-rename-table)

;; (lean-server-restart)

(defun lean-replace-string  (from-string to-string &optional delimited start end backward)
  (interactive
   (let ((common
	  (query-replace-read-args
	   (concat "Replace"
		   (if current-prefix-arg
		       (if (eq current-prefix-arg '-) " backward" " word")
		     "")
		   " string"
		   (if (use-region-p) " in region" ""))
	   nil)))
     (list (nth 0 common) (nth 1 common) (nth 2 common)
	   (if (use-region-p) (region-beginning))
	   (if (use-region-p) (region-end))
	   (nth 3 common))))
  (perform-replace from-string to-string nil nil delimited nil nil start end backward)
  (add-to-list 'lean-rename-table (cons from-string to-string))
  (update-project-list)
  )

(defun lean-redo-replace ()
  (interactive)
  (mapc (lambda (x)
          (perform-replace
           (car x) (cdr x) nil nil nil nil nil (point-min) (point-max) nil))
        lean-rename-table))

(defun leanproject-cmd (&rest cmd)
  (my-lean-leanpkg-run "leanproject"
                       "leanproject"
                       cmd))



(defun lean-mathlib-find (string)
  (interactive
           (let ((string (read-string "Foo: " nil 'my-history)))
             (list string)))
  (my-lean-leanpkg-run "mathlib-find"
                       "/Users/simon/lean/mathlib-clean/scripts/find.sh"
                       (list string)))


(defun leanproject-up ()
  (interactive)
  (leanproject-cmd "up"))

(defun leanproject-new ()
  (interactive)
  (leanproject-cmd "new"))

(defun leanproject-clean ()
  (interactive)
  (leanproject-cmd "clean"))

(defun leanproject-mk-cache ()
  (interactive)
  (leanproject-cmd "mk-cache" "--force"))

(defun leanproject-delete-zombies ()
  (interactive)
  (leanproject-cmd "delete-zombies"))

(defun leanproject-add-mathlib ()
  (interactive)
  (leanproject-cmd "add-mathlib"))

(defun leanproject-get-mathlib-cache ()
  (interactive)
  (leanproject-cmd "get-mathlib-cache"))

(defun leanproject-hooks ()
  (interactive)
  (leanproject-cmd "hooks"))
