(require 'ido)
(require 'helm-multi-match)

(defconst buf-name "*project list*")

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

(defun thesis-menu ()
  (select-project "~/org-mode/thesis/" "\\.org\\|\\.sty\\|\\.hs" "/.stack-work/" t)
  ;; (find-file "~/org-mode/thesis/chapters/soundness.org")
  ;; (register-project "thesis" "~/org-mode/thesis/")
  ;; (kill-lean-sources)
  ;; (close-other-projects)
  )

(defun find-root-dir-in (dir root-file)
  (when dir
    (or (find-root-dir-in (f-parent dir) root-file)
        (when (f-exists? (f-join dir root-file)) dir))))

(defun find-root-dir (root-file)
  (and (buffer-file-name)
       (find-root-dir-in (f-dirname (buffer-file-name)) root-file)))

(defun find-root-dir-safe (root-file)
  (or (find-root-dir root-file)
      (error (format "cannot find %s for %s" root-file (buffer-file-name)))))

(defun select-project (path ext lib-pat &optional show-todo)
  (let* ((ls (last-accessed-sources path ext lib-pat))
	 (fs (mapcar (lambda (x) (cons (file-relative-name x path) x)) ls)))
    (with-menu
     fn ("Select file:" fs)
     (when show-todo
       (save-selected-window
	 (find-file-other-window (concat path "/todo.org"))))
     (find-file fn))))

(defun lean-menu ()
  (with-menu dir ("select Lean project:"
		   (sort-on
		    (list (cons "lean-core" (lean-core-lib-path))
			  ;; (cons "lean-core" "/usr/local/lib/lean/library")
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
			  (cons "massot-scratch-pad" "~/lean/lean-scratchpad/"))
		    (lambda (x) (access-time (cdr x)))
		    'compare-mod-time)
		   )
	     (select-project dir "\\.lean" "/_target/" t)))

(defun emacs-menu ()
  (select-project "~/.emacs.d/" "\\.el" '("/.cask/" "/lisp/" "/cask/" "/elpa/")))

(defun haskell-menu ()
  (with-menu dir ("select Haskell project:"
		  (sort-on
		   (list (cons "VLC" "~/Documents/Haskell/VLC/")
			 (cons "Toggl" "~/Documents/Haskell/TogglAPI")
			 (cons "reactive-pipes" "~/Documents/Haskell/reactive-pipes/"))
		   (lambda (x) (access-time (cdr x)))
		   'compare-mod-time)
		  )
	     (select-project dir "\\.hs" "/.stack-work/" t)))

(defun notes-menu ()
  (with-menu note ("select note:"
		   (list '("daily schedule" . "daily-schedule.org")
			 '("more" . "more.org")
			 '("thoughts" . "thoughts.org")
			 '("tasks" . "tasks.org")
			 '("today" . "today4.org")
			 '("writing routine" . "writing-routine.org")))
	     (find-file
	      (concat "~/org-mode/" note))))

(defun weever-menu ()
  (with-menu dir ("select Weever project:"
		  (sort-on
		   (list (cons "ProcessServer" "~/weever/ProcessServer/"))
		   (lambda (x) (access-time (cdr x)))
		   'compare-mod-time)
		  )
	     (select-project dir "\\.hs\\|\\.yml\\|\\.yaml\\|\\.cabal\\|\\.travis" "/.stack-work/" t)))

(setq this-project-list
      '(("thesis" . thesis-menu)
	("weever" . weever-menu)
	("lean" . lean-menu)
	("haskell" . haskell-menu)
	("emacs" . emacs-menu)
	("notes" . notes-menu)))

(defun my-project-list ()
  "Prompt user to pick a choice from a list."
  (interactive)
  (if (null this-project-list)
      (message "<no projects; register projects with 'this-project-list>")
    (with-menu prj ("select project:" this-project-list)
	       (funcall prj))))

(defun project-notes ()
  (interactive)
  (save-selected-window
    (find-file-other-window (concat (find-root-dir-safe ".git") "/todo.org"))))

(global-set-key (kbd "C-c C-p l") 'my-project-list)
