(require 'ido)
(require 'helm-multi-match)

(defun thesis-menu ()
  (select-project "~/org-mode/thesis/" "\\.org\\|\\.sty\\|\\.hs" "/.stack-work/")
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

(defun select-project (path ext lib-pat)
  (let* ((buf-name "*project list*")
	 (ls (last-accessed-sources path ext lib-pat))
	 (fs (mapcar (lambda (x) (cons (file-relative-name x path) x)) ls))
	 (fn (menu "Select file:" fs)))
    (kill-buffer buf-name)
    (when fn
      (save-selected-window
	(find-file-other-window (concat path "/todo.org")))
      (find-file fn))))

(defun lean-menu ()
  (let ((dir (menu "select Lean project:"
		   (sort-on
		    (list (cons "lean-core" "~/lean/lean-master/library")
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
		   )))
    (when dir
      (select-project dir "\\.lean" "/_target/"))))


(defun emacs-menu ()
  (select-project "~/.emacs.d/" "\\.el" '("/.cask/" "/lisp/" "/cask/" "/elpa/")))

(defun haskell-menu ()
  (let ((dir (menu "select Haskell project:"
		   (sort-on
		    (list (cons "VLC" "~/Documents/Haskell/VLC/"))
		    (lambda (x) (access-time (cdr x)))
		    'compare-mod-time)
			 )))
    (when dir
      (select-project dir "\\.hs" "/.stack-work/"))))

(defun notes-menu ()
  (let ((note (menu "select note:"
		    (list '("daily schedule" . "daily-schedule.org")
		          '("more" . "more.org")
			  '("thoughts" . "thoughts.org")
			  '("tasks" . "tasks.org")
			  '("today" . "today4.org")
			  '("writing routine" . "writing-routine.org")))))
    (when note
      (find-file
       (concat "~/org-mode/" note)))))

(setq this-project-list
      '(("thesis" . thesis-menu)
	("lean" . lean-menu)
	("haskell" . haskell-menu)
	("emacs" . emacs-menu)
	("notes" . notes-menu)))

(defun menu (label alist)
  (let* ((buf-name "*project list*")
	 (selection (helm
		     :sources (helm-build-sync-source label
				:candidates (mapcar 'car alist))
		     :buffer buf-name)))
    (when selection
      (cdr (assoc selection
		  alist)))))

(defun my-project-list ()
  "Prompt user to pick a choice from a list."
  (interactive)
  (if (null this-project-list)
      (message "<no projects; register projects with 'this-project-list>")
    (let ((prj (menu "select project:" this-project-list)))
      (when prj
	(funcall prj)))))
