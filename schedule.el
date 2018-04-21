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

(setq schedule '("mindfulness (10min)"
		 "pills"
		 ("physio"
		  ( "series 1"
		    "series 2"
		    "series 3" ) )
		 ("writing (2h)"
		  ( "5 min free flow writing"
		    "30 min"
		    "30 min"
		    "30 min"
		    "30 min"
		    "commit thesis" ))))

(defun check-box (arg &optional depth)
  (let* ((depth (if (null depth)
		     0
		  depth))
	 (margin (mapconcat 'identity (make-list depth "  ") ""))
	 (item (if (stringp arg) arg (car arg)))
	 (tail (if (stringp arg) nil (cadr arg)))
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
  (let* ((check-list (cons (header (length schedule) time) (seq-mapcat 'check-box schedule nil))))
    (concat (string-join check-list "\n") "\n")))

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
