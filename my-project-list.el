(require 'ido)
(require 'helm-multi-match)
;; helm-make-source
;; 'lean-mode
;; helm-lean
;; helm-lean-definition
;; helm

;; (insert (prin1-to-string  '(1 2 3)))

;; (defun helm-project-candidates (buf)
;;   (with-helm-current-buffer
;;     (let ((ls (list :query helm-pattern))
;; 	  (c (plist-get c :source)))
;;       (with-current-buffer buf
;; 	(insert "a")
;; 	;; (insert (prin1-to-string  ls))
;; 	;; (insert (prin1-to-string  c))
;; 	))))

;;     ;; (let* ((response (lean-server-send-synchronous-command 'search (list :query helm-pattern)))
;;     ;;        (results (plist-get response :results))
;;     ;;        (results (-filter (lambda (c) (plist-get c :source)) results))
;;     ;;        (candidates (-map 'helm-lean-definitions-format-candidate results)))
;;     ;;   candidates)))

;; (defun helm-project-action (c buf)
;;   (with-helm-current-buffer
;;     (let ((src (plist-get c :source)))
;;       (with-current-buffer buf
;; 	(insert "action\n")
;; 	(insert (prin1-to-string src))))))

;; (helm-project)

;; (stringp (helm
;; 	  :sources (helm-build-sync-source "test"
;; 		     :candidates '(a b c d e))
;; 	  :buffer "*helm sync source*"))

;; (defun helm-project ()
;;   "Open a 'helm' interface for searching Lean definitions."
;;   (interactive)
;;   (require 'helm)
;;   (let ((buf (get-buffer-create "*leanpkg*")))
;;     (switch-to-buffer-other-window buf)
;;     (helm :sources (helm-make-source "helm-source-lean-definitions"
;; 		     :requires-pattern t
;; 		     :candidates (lambda () helm-project-candidates buf)
;; 		     :volatile t
;; 		     :match 'identity
;; 		     :action '(("Go to" . (-cut helm-project-action <> buf))))
;; 	  :buffer "*helm Lean definitions*")))


(defun thesis-menu ()
  (find-file "~/org-mode/thesis/chapters/soundness.org")
  ;; (register-project "thesis" "~/org-mode/thesis/")
  ;; (kill-lean-sources)
  ;; (close-other-projects)
  )

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
			  (cons "differential-topology" "~/lean/lean-differential-topology/"))
		    (lambda (x) (access-time (cdr x)))
		    'compare-mod-time)
		   )))
    (when dir
      (select-project dir "\\.lean" "/_target/"))))

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
  (let ((note (menu "select Note:"
		    (list '("more" . "more.org")
			  '("thoughts" . "thoughts.org")
			  '("today" . "today4.org")
			  '("writing routine" . "writing-routine.org")))))
    (when note
      (find-file
       (concat "~/org-mode/" note)))))

(setq this-project-list
      '(("thesis" . thesis-menu)
	("lean" . lean-menu)
	("haskell" . haskell-menu)
	("notes" . notes-menu)))

(defun menu (label alist)
  (let ((selection (helm
		    :sources (helm-build-sync-source label
			       :candidates (mapcar 'car alist))
		    :buffer buf-name)))
    (when selection
      (cdr (assoc selection
		  alist)))))
;; (defun menu (label alist)
;;   (cdr (assoc (ido-completing-read label (mapcar 'car alist))
;; 			      alist)))

(defun my-project-list ()
  "Prompt user to pick a choice from a list."
  (interactive)
  (if (null this-project-list)
      (message "<no projects; register projects with 'this-project-list>")
    (let ((prj (menu "select project:" this-project-list)))
      (when prj
	(funcall prj)))))
