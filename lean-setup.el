
;;; Code:

(require 'project)

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

(setq lean-mode-required-packages
      '(lean-mode helm-lean company-lean company dash dash-functional f
		flycheck let-alist s seq))

(let ((need-to-refresh t))
  (dolist (p lean-mode-required-packages)
    (when (not (package-installed-p p))
      (when need-to-refresh
        (package-refresh-contents)
        (setq need-to-refresh nil))
      (package-install p))))

(require 'unicode-fonts)
(unicode-fonts-setup)
(global-set-key (kbd "S-SPC") #'company-complete)

(if (not (boundp 'lean-version))
    (setq lean-version "master"))

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

;; (setq load-path (cons lean-emacs-path load-path))
(require 'lean-mode)
(add-hook 'lean-mode-hook 'set-truncate-lines)

(defun unload-lean ()
  (unload-feature 'lean-setup)
  (unload-feature 'lean-mode)
  (setenv "PATH" (string-join (delete lean-bin (split-string (getenv "PATH") ":")) ":"))
  (setq load-path (delq lean-rootdir (delete lean-emacs-path load-path))))

(defun reload-lean (&optional version)
  (unload-lean)
  (if version
      (setq lean-version version)
    (setq lean-version "master"))
  (load 'lean-setup))

(defun set-lean-version (version)
  (if (not (equal version lean-version))
      (reload-lean version)))

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

(setenv "LEAN_PATH")

(setq lean-projects
      (list (cons "unit-b" "~/lean/unity/semantics-lean/src")
	    (cons "slim_check" "~/lean/slim_check")
	    (cons "modexp" "~/lean/modexp")
	    (cons "refine-tutorial" "~/lean/tutorials/writing a tactic")
	    (cons "temporal-logic" "~/lean/temporal-logic")
	    (cons "separation-logic" "~/lean/separation-logic")
	    (cons "lean-lib" "~/lean/lean-lib")
	    (cons "lambda-calc" "~/lean/lambda-calc")
	    (cons "pipes" "~/lean/pipes")
	    (cons "unitb-pointers" "~/lean/unitb-pointers")
	    (cons "lean-prover" "~/lean/lean-master/")
	    (cons "mathlib" "~/lean/mathlib/")
	    (cons "differential-topology" "~/lean/lean-differential-topology/")
	    ))

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
;; cmake -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=RELEASE -G Ninja ../../src
;; ninja
;; ninja install
;; lean-leanpkg-build

;; ninja clean-olean

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
                                  "make" "clean")))
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

(defun lean-insert-hash ()
  (interactive)
  (let ((default-directory "~/lean/lean-master"))
    (call-process "git" nil (current-buffer) t "rev-parse" "HEAD")))

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
  (interactive)
  (my-lean-leanpkg-run "lean" (lean-get-executable lean-executable-name)
		       (list (buffer-file-name) "--profile" "--test-suite")))

(defun lean-leanpkg-build-quiet ()
  "Call leanpkg build (quiet)"
  (interactive)
  (lean-leanpkg-run-quiet "build"))

(defun lean-leanpkg-test-quiet ()
  "Call leanpkg build (quiet)"
  (interactive)
  (lean-leanpkg-run-quiet "test"))

(defun lean-leanpkg-upgrade ()
  "Call leanpkg upgrade"
  (interactive)
  (lean-leanpkg-run "upgrade"))

(defun lean-show-goal-and-error-list ()
  (interactive)
  (enable-info-buffer
   lean-show-goal-buffer-name
   (get-top-right-panel)
   (lean-toggle-show-goal))
  (enable-info-buffer
   flycheck-error-list-buffer
   (get-bottom-right-panel)
   (flycheck-mode)
   (flycheck-list-errors)))

(defun lean-jump-to-error-message ()
  (interactive)
  (enable-info-buffer
   lean-next-error-buffer-name
   (get-top-right-panel)
   (lean-toggle-next-error))
  (select-window (get-top-right-panel)))


(global-set-key (kbd "C-x l") 'lean-show-goal-and-error-list)
(global-set-key (kbd "C-x C-l") 'lean-jump-to-error-message)
;; (add-hook 'lean-mode-hook 'lean-show-goal-and-error-list)
