(require 'ido)
(require 'helm-multi-match)

(defconst buf-name "*project list*")

(defmacro persistent (name)
  `(progn
     (unless (boundp (quote ,name))
       (setq ,name nil))
     (unless (memq (quote ,name) project-list-file-contents)
       (add-to-list 'project-list-file-contents (quote ,name))
       (update-project-list))))

(defun menu (label alist)
  (let* ((selection (helm
		     :sources (helm-build-sync-source label
				:candidates (mapcar 'car alist))
		     :buffer buf-name)))
    (if selection
	(cdr (assoc selection
		    alist)))))

;; (defun with-menu-fn (label alist body)
;;   (let ((r (menu label alist)))
;;     (funcall body r)
;;     (when (get-buffer buf-name)
;;       (kill-buffer buf-name))))

(defmacro with-menu (var menu-param &rest body)
  `(let* ((,var (menu ,@menu-param))
	  (r (when ,var ,@body)))
     (when (get-buffer buf-name)
       (kill-buffer buf-name))
     r))

;; (with-menu sel ("Select file:" fs) a b)



(defun my-thesis ()
  (interactive)
  (select-project-file "~/org-mode/thesis/" 'thesis)
  ;; (find-file "~/org-mode/thesis/chapters/soundness.org")
  ;; (register-project "thesis" "~/org-mode/thesis/")
  ;; (kill-lean-sources)
  ;; (close-other-projects)
  )

(defun find-root-dir-in (dir root-file)
  (when dir
    (or (when (f-exists? (f-join dir root-file)) dir)
        (find-root-dir-in (f-parent dir) root-file))))

(defun find-root-dir (root-file)
  (and (buffer-file-name)
       (find-root-dir-in (f-dirname (buffer-file-name)) root-file)))

(defun find-root-dir-safe (root-file)
  (or (find-root-dir root-file)
      (error (format "cannot find %s for %s" root-file (buffer-file-name)))))

(defun kill-other-projects ()
  (interactive)
  (let ((dir (find-root-dir-safe ".git")))
    (dolist (b (buffer-list))
      (when-let (prj (with-current-buffer b (find-root-dir ".git")))
	(unless (string= prj dir)
	  (kill-buffer b))))))

(defun close-project ()
  (interactive)
  (let ((dir (file-name-as-directory (find-root-dir-safe ".git"))))
    (dolist (b (buffer-list))
      (when (string= (seq-take (buffer-file-name b) (length dir)) dir)
	(kill-buffer b)))))

(defun select-project-file (path kind)
  (cond ((eq kind 'thesis)
	 (select-project path "\\.org\\|\\.sty\\|\\.hs|\\.tla" "/.stack-work/" t))
	((eq kind 'lean) (select-project path "\\.lean\\|\\.md" "/_target/" t))
	((eq kind 'rust) (select-project path "\\.rs\\|\\.md" "/target/" t))
	((eq kind 'coq) (select-project path "\\.v\\|\\.md" "/target/" t))
	((eq kind 'cpp) (select-project path "\\.cpp\\|\\.hpp\\|\\.c\\|\\.h\\|\\.md" "/build/" t))
	((eq kind 'file) (find-file path))
	((eq kind 'haskell)
	 (select-project path
			 "\\.lhs\\|\\.hs\\|\\.yml\\|\\.yaml\\|\\.cabal\\|\\.travis|\\.tla"
			 "/.stack-work/" t))
        (else (error "wrong project kind"))))

(defun my-todo ()
  (interactive)
  (save-selected-window
    (find-file-other-window (concat (file-name-as-directory (find-root-dir-safe ".git")) "/todo.org"))))

(defun select-project (path ext lib-pat &optional show-todo)
  (let* ((ls (last-accessed-sources path (concat ext "\\|.travis.y") lib-pat))
	 (fs (mapcar (lambda (x) (cons (file-relative-name x path) x)) ls)))
    (with-menu
     fn ("Select file:" fs)
     ;; (when show-todo
     ;;   (save-selected-window
     ;; 	 (find-file-other-window (concat path "/todo.org"))))
     (find-file fn))))

(defconst def-lean-project-list
  (list ;; (cons "lean-core" "/usr/local/lib/lean/library")
	(cons "unit-b" "~/lean/unity/semantics-lean/src")
	(cons "modexp" "~/lean/modexp")
	(cons "refine-tutorial" "~/lean/tutorials/writing a tactic")
	(cons "temporal-logic" "~/lean/temporal-logic")
	(cons "separation-logic" "~/lean/separation-logic")
	(cons "lean-lib" "~/lean/lean-lib")
	(cons "pipes" "~/lean/pipes")
	(cons "unitb-pointers" "~/lean/unitb-pointers")
	(cons "lean-prover" "~/lean/lean-master/")
	(cons "mathlib" "~/lean/mathlib/")
	(cons "regular" "~/lean/regular/")
	(cons "scratch" "~/lean/draft/")
	(cons "differential-topology" "~/lean/lean-differential-topology/")
	(cons "massot-scratch-pad" "~/lean/lean-scratchpad/")))

(defconst project-list-file "~/.emacs.d/project-list-data.el")

(setq project-list-file-contents
      '(lean-project-list
	lean-library-list
	haskell-project-list))

(defun unbounded-pp (x)
  (let ((eval-expression-print-length nil))
    (pp x)))

(defun update-project-list ()
  (with-current-buffer (find-file-noselect project-list-file)
    (erase-buffer)
    (mapcar (lambda (v)
	      (insert (unbounded-pp `(setq ,v (quote ,(symbol-value v)))))
	      (newline))
	    project-list-file-contents)
    (insert (pp `(setq project-list-file-contents (quote ,project-list-file-contents))))
    (save-buffer)))

(defun leanpkg-add-other ()
  (let ((github (read-string "Github Directory: ")))
     (cons (file-name-nondirectory github) github)))

(defun lean-leanpkg-add ()
  "Call leanpkg build (quiet)"
  (interactive)
  (with-menu lib ("Lean Library: "
		  (append
		   lean-library-list
		   (list '("Other ..." . leanpkg-add-other))))
	     (when (symbolp lib)
	       (setq lib (funcall lib))
	       (add-to-list 'lean-library-list lib)
	       (update-project-list)
	       (setq lib (cdr lib)))
	     (my-lean-leanpkg-run "leanpkg"
				  (lean-leanpkg-executable)
				  (list "add" lib))))

(progn
  (mapcar (lambda (v) (set v nil)) project-list-file-contents)
  (if (file-exists-p project-list-file)
      (load project-list-file)
    (progn (setq lean-project-list def-lean-project-list)
	   (update-project-list) )))

;; (read-string "foo")
;; " dal"
;; (concat "~/lean/" "doo")

(defun create-dummy-source-file (pcs evt)
  (with-current-buffer (find-file (concat default-directory "src/" pname ".lean"))
    (save-buffer))
  (start-process "leanpkg" (current-buffer)
		 (lean-leanpkg-executable) "add" "leanprover/mathlib"))

(defun create-new-haskell-project ()
  (let* ((pname (read-string "project name: "))
	 (default-directory "~/Documents/Haskell/")
	 (dir (concat "~/Documents/Haskell/" pname "/")))
    (add-to-list 'haskell-project-list (cons pname dir))
    (update-project-list)
    (with-current-buffer (get-buffer-create "*stack*")
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (call-process "stack"
                    nil (current-buffer) nil
		    "new" pname)
      (magit-init dir)
      (find-file (f-join dir "app" "Main.hs")))))

(defun clone-lean-project ()
  (let* ((url (read-string "project repo: "))
	 (pname (file-name-base
		 (directory-file-name url)))
	 (dir (concat "~/lean/" pname)))
    (magit-clone url dir)
    (add-to-list 'lean-project-list (cons pname dir))
    (update-project-list)))

(defun clone-lean-project ()
  (clone-project "~/lean/" 'lean-project-list))

(defun clone-coq-project ()
  (clone-project "~/Coq/" 'coq-project-list))

(defun clone-rust-project ()
  (clone-project "~/rust/" 'rust-project-list))

(defun clone-cpp-project ()
  (clone-project "~/cpp/" 'cpp-project-list))

(defun clone-project (dir list-name)
  (let* ((url (read-string "project repo: "))
	 (pname (file-name-base
		 (directory-file-name url)))
	 (dir (concat dir pname)))
    (magit-clone url dir)
    (add-to-list list-name (cons pname dir))
    (update-project-list)))

(defun lean-leanpkg-new (pname dir)
  (interactive
   (list (read-string "Project name: ")
         (read-directory-name "Choose directory: ")))
  (print pname)
  (unless (file-exists-p (file-name-as-directory dir))
    (make-directory dir))
  (unless (file-exists-p (concat dir "src/"))
    (make-directory (concat dir "src/")))
  (with-current-buffer (get-buffer-create "*leanpkg*")
      (setq default-directory dir)
      (setq buffer-read-only nil)
      (erase-buffer)
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (insert (format "> leanpkg init %s\n" pname))
      ;; (set-process-sentinel
      ;;  (start-process "leanpkg" (current-buffer)
      ;;   	      (lean-leanpkg-executable) "init" pname)
      ;;  'create-dummy-source-file)
      (call-process (lean-leanpkg-executable) nil t t "init" pname)
      )
)


(defun create-new-lean-project ()
  (let* ((pname (read-string "project name: "))
	 (dir (concat "~/lean/" pname "/")))
    (unless (file-exists-p dir)
      (make-directory dir))
    (unless (file-exists-p (concat dir "src/"))
      (make-directory (concat dir "src/")))
    (add-to-list 'lean-project-list (cons pname dir))
    (update-project-list)
    (copy-file "~/lean/lean-lib/.travis.yml" dir)
    (copy-file "~/lean/lean-lib/.dir-locals.el" dir)
    (with-current-buffer (create-file-buffer (concat dir "README.md"))
      (insert (concat "# " pname))
      (write-file (concat dir "README.md"))
      (kill-buffer))
    (magit-init dir)
    (lean-leanpkg-new pname dir)
    (setq-local pname pname)
    (create-dummy-source-file nil nil)
    (setq current-directory dir)
    (seq-map 'magit-stage-file
             (list "README.md"
                   "leanpkg.toml"
                   ".gitignore"
                   ".travis.yml" ))
    ))

(persistent lean-project-list)
(defun my-lean-projects ()
  (interactive)
  (with-menu dir ("select Lean project:"
		  (append (sort-on
			   (cons (cons "lean-core" (lean-core-lib-path))
				 lean-project-list)
			   (lambda (x) (access-time (cdr x)))
			   'compare-mod-time)
			  ;; '()
			  '( ("Create new Lean project" . create-new-lean-project)
			     ("Clone project" . clone-lean-project) )
			  ) )
	     (if (symbolp dir)
		 (funcall dir)
		 (select-project-file dir 'lean))))

(persistent coq-project-list)
(defun my-coq-projects ()
  (interactive)
  (with-menu dir ("select Rust project:"
		  (append (sort-on
                           coq-project-list
                           (lambda (x) (access-time (cdr x)))
                           'compare-mod-time)
			     '( ("Clone project" . clone-coq-project) )
			  ) )
	     (if (symbolp dir)
		 (funcall dir)
		 (select-project-file dir 'coq))))

(persistent rust-project-list)
(defun my-rust-projects ()
  (interactive)
  (with-menu dir ("select Rust project:"
		  (append (sort-on
                           rust-project-list
                           (lambda (x) (access-time (cdr x)))
                           'compare-mod-time)
			  ;; '()
			  ;; '( ("Create new Lean project" . create-new-lean-project)
			     '( ("Clone project" . clone-rust-project) )
			  ) )
	     (if (symbolp dir)
		 (funcall dir)
		 (select-project-file dir 'rust))))

(persistent cpp-project-list)
(defun my-cpp-projects ()
  (interactive)
  (with-menu dir ("select C++ project:"
		  (append (sort-on
                           cpp-project-list
                           (lambda (x) (access-time (cdr x)))
                           'compare-mod-time)
			  ;; '()
			  ;; '( ("Create new Lean project" . create-new-lean-project)
			     '( ("Clone project" . clone-cpp-project) )
			  ) )
	     (if (symbolp dir)
		 (funcall dir)
		 (select-project-file dir 'cpp))))

(defun my-emacs-projects ()
  (interactive)
  (select-project "~/.emacs.d/" "\\.el" '("/.cask/" "/lisp/" "/cask/" "/elpa/")))

(persistent haskell-project-list)
(defun my-haskell-projects ()
  (interactive)
  (with-menu dir ("select Haskell project:"
		  (append (sort-on
			   haskell-project-list
			   (lambda (x) (access-time (cdr x)))
			   'compare-mod-time)
			  (list '("Create new Haskell project" . create-new-haskell-project)))
		  )
	     (if (symbolp dir)
		 (funcall dir)
	       (select-project-file dir 'haskell))))

(defun my-notes ()
  (interactive)
  (with-menu note ("select note:"
		   (list '("daily schedule" . "daily-schedule.org")
			 '("more" . "more.org")
			 '("thoughts" . "thoughts.org")
			 '("tasks" . "tasks.org")
			 '("today" . "today4.org")
			 '("groceries" . "groceries.org")
			 '("writing routine" . "writing-routine.org")))
	     (find-file
	      (concat "~/org-mode/" note))))

(defun my-weever-projects ()
  (interactive)
  (with-menu dir ("select Weever project:"
		  (sort-on
		   (list (cons "ProcessServer" "~/weever/ProcessServer/")
			 (cons "GraphQL-API"  "~/weever/graphql-api/"))
		   (lambda (x) (access-time (cdr x)))
		   'compare-mod-time)
		  )
	     (select-project-file dir 'haskell)))

(setq this-project-list
      '(("thesis" . my-thesis)
	("weever" . my-weever-projects)
	("lean" . my-lean-projects)
	("rust" . my-rust-projects)
	("haskell" . my-haskell-projects)
	("emacs" . my-emacs-projects)
	("notes" . my-notes)))

(defun my-project-list ()
  "Prompt user to pick a choice from a list."
  (interactive)
  (if (null this-project-list)
      (message "<no projects; register projects with 'this-project-list>")
    (with-menu prj ("select project:" this-project-list)
	       (funcall prj))))

(persistent current-projects)
(defun my-current-projects ()
  (interactive)
  (with-menu
   prj ("Select project"
	(sort-on current-projects
		 (lambda (x) (access-time (cdr x)))
		 'compare-mod-time) )
   (select-project-file (car prj) (cdr prj))))


(defun project-notes ()
  (interactive)
  (save-selected-window
    (find-file-other-window (concat (find-root-dir-safe ".git") "/todo.org"))))

;; (global-set-key (kbd "C-c C-p l") 'my-project-list)
