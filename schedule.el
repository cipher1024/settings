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

(defun on-day (days items)
  (if (member (format-time-string "%a" (current-time)) days)
      (list items)))

(defconst week-day '("Mon" "Tue" "Wed" "Thu" "Fri"))
(defconst weekend-day '("Sat" "Sun"))

(defun schedule-p (sch)
  (and (listp sch)
       (seq-every-p (lambda (x) (or (stringp x)
				    (and (consp x)
					 (consp (cdr x))
					 (stringp (car x))
					 (schedule-p (cadr x))))) sch)))

(defun schedule ()
  `( ( "morning"
       ("mindfulness (10min)"
	"pills"
	"shower"
	"laundry"
	"dishes"
	("physio (elastic band)"
	 ( "series 1"
	   "series 2"
	   "series 3" ) )
	("physio (lifting arm)"
	 ( "series 1"
	   "series 2"
	   "series 3" ) ) ) )
     ( "evening [/]" () )
    ,@(on-day '("Tue")
	     "Starbucks")
    ,@(on-day '("Mon" "Tue" "Wed")
	      "Weever")
    ,@(on-day '("Thu" "Fri" "Sat")
	      '("writing (2h)"
		 ( "5 min free flow writing"
		   "30 min"
		   "30 min"
		   "30 min"
		   "30 min"
		   "30 min"
		   "30 min"
		   "commit thesis" )))))

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
