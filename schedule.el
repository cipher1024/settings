(defun insert-standard-date ()
    "Inserts standard date time string."
    (interactive)
    (insert (format-time-string "%B %e, %Y")))

(defconst sec 1)
(defconst minute (* 60 sec))
(defconst hour (* 60 minute))
(defconst day (* 24 hour))

(defun tomorrow ()
  (+ (float-time (current-time)) day))

(defun on-day (days &rest items)
  (if (member (format-time-string "%a") days)
      items))

(defun monthly (day &rest items)
  (if (= (string-to-number (format-time-string "%d")) day)
      items))


(defconst week-day '("Mon" "Tue" "Wed" "Thu" "Fri"))
(defconst weekend-day '("Sat" "Sun"))

(defun schedule-p (sch)
  (and (or (listp sch) (error (format "%s schould be a list" sch)))
       (seq-every-p (lambda (x) (or (stringp x)
				    (and (or (consp x)
                                             (error (format "%s schould be a pair (%s)" x sch)))
					 (or (consp (cdr x))
                                             (error (format "%s schould be a pair (%s)" (cdr x) sch)))
					 (or (stringp (car x))
                                             (error (format "%s schould be a string (%s)" (car x)) sch))
					 (schedule-p (cadr x))))) sch)))

(defmacro def-schedule (body)
  (schedule-p (eval body))
  `(defun schedule () ,body))

(defun display-or-find-file (file)
  (or (when-let (buf (get-file-buffer file))
	(display-buffer-in-previous-window buf nil))
      (find-file file)))

(defun my-daily-schedule ()
  (interactive)
  (display-or-find-file "~/org-mode/daily-schedule.org"))

(defun my-tasks ()
  (interactive)
  (display-or-find-file "~/org-mode/tasks.org"))

;; (defun schedule ()
(def-schedule
  `( ( "morning"
       ( ( "pills"
           ( "med1" ) )
         ;; ( "drain"
         ;;   ( ( "9:00" ( "2" )  ) ) )
         "brush teeth"
         "shower"
         "laundry"
         "dishes"
         "mindfulness (10min)" ) )
     ,@(on-day '("Mon")
	       '( "Choose 3 [[/Users/simon/org-mode/tasks.org][tasks]]"
		  ( "task" ) )
	       "Laundry")
    ;; ,@(on-day '("Tue")
    ;;          "Starbucks")
    ;; ,@(on-day '("Mon" "Tue" "Wed")
    ;;           "Weever"
    ;;           '("writing (2h)"
    ;;     	 ( "5 min free flow writing"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "commit thesis" )))
    ,@(monthly 21
	       '("bills"
		 ("credit card")))
    ;; ,@(on-day '("Thu" "Fri")
    ;;           '("writing (2h)"
    ;;     	 ( "5 min free flow writing"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "30 min"
    ;;     	   "commit thesis" )))
    "tylenols"
    ( "evening"
      ( ( "pills"
        ( "surgery" "welbutrin" "tylenol" ) )
      "brush teeth"
      ;; ( "drain"
      ;;   ( ( "21:00" ( "2" ) ) ) )
      ) )
    ( "tomorrow" () )
    ;; ( "evening"
      ;; ("close office windows"
      ;;  "brush teeth"
      ;;  "floss"
      ;;  ("physio (lifting arm)"
      ;;   ( "series 1"
      ;;     "series 2"
      ;;     "series 3" ) )
      ;;  ("physio (elastic band)"
      ;;   ( "series 1"
      ;;     "series 2"
      ;;     "series 3" )
      ;;   )))
    ))

(defun check-box (arg &optional depth)
  (let* ((depth (if (null depth)
		     0
		  depth))
	 (margin (mapconcat 'identity (make-list depth "  ") ""))
	 (item (cond ((stringp arg) arg)
		     ((listp arg) (car arg))
		     (t (prin1-to-string arg))))
	 (tail (if (listp arg) (cadr arg) nil))
	 (ratio (if (null tail) "" (concat " [0/" (number-to-string (length tail)) "]"))))
    (cons (concat margin " * [ ] " item ratio)
	  (seq-mapcat (lambda (x) (check-box x (+ 1 depth))) tail))
    ))

(defun setup-daily-paragraph ()
  (update-schedule (current-buffer) nil)
  (make-variable-buffer-local 'my-routine-timer)
  (setq my-routine-timer (run-at-time nil minute 'update-schedule (current-buffer) nil))
  (add-hook 'kill-buffer-hook (lambda () (cancel-timer my-routine-timer)) t t))

(defun setup-daily-routine ()
  (update-schedule (current-buffer) t)
  (make-variable-buffer-local 'my-routine-timer)
  (setq my-routine-timer (run-at-time nil minute 'update-schedule (current-buffer) t))
  (add-hook 'kill-buffer-hook (lambda () (cancel-timer my-routine-timer)) t t))

(defun save-this-buffer (buf)
  (with-current-buffer buf
    (save-buffer)))

(defun is-up-to-date ()
  (string=
   (header-date)
   (buffer-substring-no-properties 1 (+ (length (header-date)) 1))))

(defun update-schedule (buf b)
  (save-excursion
    (with-current-buffer buf
      (if (not (is-up-to-date))
	  (progn
	    (goto-char 1)
	    (org-overview)
	    (insert
	     (if b
		 (today-schedule)
	       (today-paragraph))
	     )))
      (save-buffer))))

(defun header-date ()
  (concat "** " (format-time-string "%B %e, %Y" (current-time))))

(defun header (sch &optional time)
  (concat (header-date) " [0/" (number-to-string sch) "]"))

(defun daily-schedule (time)
  (let ((sch (schedule)))
    (cl-assert (schedule-p sch) t "foo %s")
    (let ((check-list (cons (header (length sch) time)
			    (seq-mapcat 'check-box sch nil))))
      (concat (string-join check-list "\n") "\n"))))

(defun today-paragraph ()
  (let* ((check-list (header 0 (current-time))))
    (concat check-list "\n")))

(defun today-schedule () (daily-schedule (current-time)))
(defun tomorrow-schedule () (daily-schedule (tomorrow)))

;; (tomorrow-schedule)

(defun show-today-schedule ()
  (interactive)
  (in-top-right-panel "~/org-mode/daily-schedule.org")
  (select-window (get-top-right-panel)))

(global-set-key (kbd "C-x C-t") 'show-today-schedule)
