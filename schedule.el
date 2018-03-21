
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

(setq schedule '(("mindfulness (15min)"
		  ( "7 days of calm" ))
		 ("writing (1h)"
		  ( "5 min free flow writing"
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

(defun header (sch &optional time)
  (concat "** " (format-time-string "%B %e, %Y" time) " [0/" (number-to-string sch) "]"))

(defun daily-schedule (time)
  (let* ((check-list (cons (header (length schedule) time) (seq-mapcat 'check-box schedule nil))))
    (insert (concat "\n" (string-join check-list "\n") "\n"))))

(defun today-schedule () (daily-schedule (current-time)))
(defun tomorrow-schedule () (daily-schedule (tomorrow)))

;; (tomorrow-schedule)

(defun show-today-schedule ()
  (interactive)
  (in-top-right-panel "~/org-mode/today.org")
  (select-window (get-top-right-panel)))

(global-set-key (kbd "C-x t") 'show-today-schedule)
