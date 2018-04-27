(defmacro with-file-as-current-buffer (fname &rest body)
  `(let ((already-open (find-buffer-visiting ,fname))
	 (buf (find-file-noselect ,fname))
	 )
     (let ((res (with-current-buffer buf ,@body)))
       (unless already-open (kill-buffer buf))
       res)
     )
  )

(defun get-comments-in-buffer (&optional buf)
  (let ((comments '()))
    (traverse-comments-in-buffer
     (lambda (x)
       (let* ((next1 (seq-filter 'is-todo x))
	      (next2 (if (eq major-mode 'org-mode)
			 (cons next1 (nth 4 (org-heading-components)))
		       next1)))
	 (unless (null next1)
	   (setq comments (cons next2 comments)))))
     buf)
    (reverse comments)))


(defun traverse-comments-in-buffer (ff &optional buf)
  (let (start)
    (unless buf
      (setq buf (current-buffer)))
    (save-excursion
      (with-current-buffer buf
	(goto-char (point-min))
	(while (setq start (text-property-any
			    (point) (point-max)
			    'face 'font-lock-comment-face))
	  (goto-char start)
	  (goto-char (next-single-char-property-change (point) 'face))
	  (let* ((next0 (split-string (buffer-substring-no-properties start (point))
				      "\n")))
	    (funcall ff next0)))))))

(defun is-todo (comment)
  (string-match-p "TODO" comment))

(defun get-todo-list (&optional buf)
  (get-comments-in-buffer buf))

(defun my-todo-item (x)
  (let ((items (if (consp x) (car x) x))
	(parent (if (consp x) (cdr x))))
    (mapcar (lambda (x)
	      (unless (org-find-exact-headline-in-buffer x)
		(if (null parent)
		    (progn
		      (goto-char (point-min))
		      (org-insert-todo-heading x)
		      (org-edit-headline x))
		  (progn
		    (org-insert-todo-under-heading parent x) ))))
	    items)))

(defun get-status (item)
  (print (mapcar (lambda (x)
		   (goto-char (org-find-exact-headline-in-buffer x))
		   (org-heading-components))
		 (car item))))

(defun update-todo-list (buf)
  (with-current-buffer buf
    (when (boundp 'my-todo-list)
      (let ((todo (get-todo-list)))
	(unless (eq todo my-todo-list)
	  (with-current-buffer todo-buffer
	    (mapcar 'my-todo-item todo)
	    (print (mapcar 'get-status todo))
	    nil)
	  (setq my-todo-list todo)
	  nil
	  )))))


;; (setq-local my-file "/Users/simon/lean/draft/showdown.lean")
;; (setq-local my-file "/Users/simon/org-mode/thesis/chapters/soundness.org")
  ;; (find-file my-file)
;; '(
;;  (let ((buf (get-file-buffer my-file)))
;;    (with-current-buffer buf
;;      (setq-local my-todo-list '())))
;;  (setup-comment-todo)
;;  )
;; (let ((buf (get-file-buffer my-file)))
;;   (with-current-buffer buf
;;     (setq my-todo-list nil)))

(defun org-insert-todo-under-heading (heading new)
  (if-let ((h (org-find-exact-headline-in-buffer heading nil t)))
      (goto-char h)
    (progn
      (goto-char (point-min))
      (org-insert-heading nil nil t)
      (org-edit-headline (format "%s [/]" heading))
      (org-back-to-heading)
      ))
  (org-insert-todo-heading new)
  (org-edit-headline new)
  (org-move-subtree-down)
  (org-demote-subtree)
  )
;; (with-current-buffer todo-buffer
;;   ;;   (org-demote-subtree)
;;   (org-insert-todo-under-heading "new heading" "entry 1")
;;   (org-insert-todo-under-heading "new heading" "entry 2")
;;   (org-insert-todo-under-heading "new heading" "entry 3")
;;   ;; (goto-char (org-find-exact-headline-in-buffer "allo " nil t))
;;   ;;   (org-move-subtree-down)
;;   )

;; (make-local-variable 'after-change-functions)
;; (add-to-list 'after-change-functions 'update-tod-list t)

;; run-with-idle-timer

;; other todo
 ;; with text between
;; TODO allo
(defun setup-comment-todo ()
  (setq-local my-todo-list nil)
  (when (boundp 'my-timer)
    (cancel-timer my-timer))
  (setq-local todo-buffer (get-buffer-create "*todo buffer*"))
  (save-excursion
    (with-current-buffer (switch-to-buffer-other-window todo-buffer)
      (org-mode)))
  (setq-local my-timer (run-with-idle-timer 3 t 'update-todo-list (current-buffer)))
  (add-hook 'kill-buffer-hook (lambda () (cancel-timer my-timer)) t t))
