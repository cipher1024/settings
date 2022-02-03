;; (defvar )

(defconst to-second-ratio
  `((minute . 60)
    (minutes . 60)
    (hour . ,(* 60 60))
    (hours . ,(* 60 60))
    (day . ,(* 24 60 60))
    (days . ,(* 24 60 60))
    (week . ,(* 7 24 60 60))
    (weeks . ,(* 7 24 60 60))
    ))

(defun to-seconds (time unit)
  (* (alist-get unit to-second-ratio) time))

(defun encode-absolute-time-on-day (time &optional rel-day)
  (require 'diary-lib)
  (let ((hhmm (diary-entry-time time))
        (now (decode-time)))
    (when (>= hhmm 0)
        (encode-time 0 (% hhmm 100) (/ hhmm 100)
                     (+ (decoded-time-day now) (or rel-day 0))
                     (decoded-time-month now)
                     (decoded-time-year now)
                     (decoded-time-zone now)))))

(defvar weekday-code
  '(Sunday Monday Tuesday Wednesday Thursday Friday Saturday))

(defun get-weekday-code (day)
  (seq-position weekday-code day))

(defun decode-weekday (code)
  (nth code weekday-code))

(defun time-next-occurrence (time &optional day-of-week)
  (let* ((now (decode-time))
         (result (encode-absolute-time-on-day time))
         (today (decoded-time-weekday now))
         (day-of-week (when day-of-week
                        (get-weekday-code day-of-week)))
         (delta (if day-of-week
                    (+ (mod (- day-of-week today 1) 7)
                       1)
                  1))
         (same-day (or (not day-of-week)
                       (= day-of-week today))))
    (if (or (not same-day)
            (time-less-p result (apply 'encode-time now)))
        (encode-absolute-time-on-day time delta)
      result)))

;; (decode-weekday
;; (decode-time (time-next-occurrence "7am" 'Friday))

(defun daily-review-setup-timers ()
  (when (and (boundp 'daily-review-new-section-timer)
             daily-review-new-section-timer)
    (cancel-timer daily-review-new-section-timer))
  (when (and (boundp 'daily-review-prompt-form-timer)
             daily-review-prompt-form-timer)
    (cancel-timer daily-review-prompt-form-timer))

  (setq-local daily-review-new-section-timer
              (run-at-time (time-next-occurrence "07am") (to-seconds 1 'day)
                           'daily-review-insert-section (current-buffer)))
  (setq-local daily-review-prompt-form-timer
              (run-at-time (time-next-occurrence "06pm") (to-seconds 1 'day)
                           'daily-review-prompt-form (current-buffer))))

(defun daily-review-disable-timers ()
  (cancel-timer daily-review-new-section-timer)
  (cancel-timer daily-review-prompt-form-timer)
  )

(defun setup-daily-review ()
  (daily-review-setup-timers)
  (add-hook 'kill-buffer-hook 'daily-review-disable-timers nil t)
  )

(defun weekly-prep-form-setup-timers ()
  (when (and (boundp 'weekly-prep-form-timer)
             weekly-prep-form-timer)
    (cancel-timer weekly-prep-form-timer))

  (setq-local weekly-prep-form-timer
              (run-at-time (time-next-occurrence "07am" 'Monday)
                           (to-seconds 1 'week)
                           'weekly-prep-prompt-form (current-buffer))))

(defun weekly-prep-form-disable-timers ()
  (cancel-timer weekly-prep-form-timer)
  )

(defun setup-weekly-prep-form ()
  (weekly-prep-form-setup-timers)
  (add-hook 'kill-buffer-hook 'weekly-prep-form-disable-timers nil t)
  )

(defun weekly-prep-prompt-form (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (unless
        (string-prefix-p (weekly-prep-heading) (first-heading))
      (org-show-all)
      (org-cycle-internal-global)
      (save-excursion
        (goto-char (point-min))
        (insert
         (weekly-prep-heading)
         )
        (insert "\n\n")
        (insert (weekly-prep-body))
        (insert "\n\n"))
      (goto-char (point-min))
      (save-buffer))
    (pop-to-buffer (current-buffer))))

;; (with-current-buffer "daily-review.org"
;;     (remove-hook 'kill-buffer-hook 'daily-review-disable-timers)
;;   )

(defun daily-review-prompt-form (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (pop-to-buffer (current-buffer))
    (goto-char (point-min))
    ))

(defconst daily-review-heading-prefix "** Review: ")

(defun daily-review-heading ()
  (concat daily-review-heading-prefix
          (format-time-string "%a, %b %e %Y")
          " [/]"))

(defun daily-review-body ()
  (mapconcat 'identity
   '( "  * Unstructured thoughts"
      "    *"
      ""
      "  * Self assessment -> choice point -> execute routine"
      "    * [/] when doing something at the an inappropriate time"
      "       * [ ] what am I doing?"
      "       * [ ] what did I plan on doing?"
      "       * [ ] what is the first step toward doing that?"
      ""
      "  * [ ] What I accomplished"
      "    * "
      "  * [ ] What I didn't get to"
      "    * "
      "  * [ ] What went well"
      "    * "
      "  * [ ] What didn't go so well"
      "    * ")
   "\n"
   ))

(defconst weekly-prep-heading-prefix "** Prep form: ")

(defun weekly-prep-heading ()
  (concat weekly-prep-heading-prefix
          (format-time-string "%a, %b %e %Y")
          " [/]"))

(defun weekly-prep-body ()
  (mapconcat
   'identity
   (list
    "  * [ ] Read daily [[file:/Users/simonhudon/daily-review.org][reviews]]"
    "  * [[https://docs.google.com/document/d/1hM2S3CFX8_d7npEa8UZrA1mmq1IOE0z7/edit?usp=sharing&ouid=114066916641452978934&rtpof=true&sd=true][Google Doc]]"
    ""
    "  * [ ] Date/Time of Call:"
    (format-time-string "    * %F")
    "  * [ ] Current Frame of Mind:"
    "    * "
    "  * [ ] Since our last call, my wins, and victories (including"
    "        your fieldwork / action steps from our last call):"
    "    * "
    "  * [ ] Other things I did this week:"
    "    * "
    "  * [ ] Fieldwork that I intended to complete (since the last"
    "        call) but didn’t that I want to explore:"
    "    * "
    "  * [ ] Challenges, Dilemmas and/or Opportunities ahead for me:"
    "    * "
    "  * [ ] I want to use this session to focus on…"
    "    * "
    "  * [ ] What would you like to achieve by the end of the call?"
    "    * ")
   "\n"
   ))

(defun daily-review-insert-section (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (unless
        (or (weekendp)
            (string-prefix-p (daily-review-heading) (first-heading)))
      (org-show-all)
      (org-cycle-internal-global)
      (save-excursion
        (goto-char (point-min))
        (insert
         (daily-review-heading)
         )
        (insert "\n\n")
        (insert (daily-review-body))
        (insert "\n\n"))
      (save-buffer))
    ))

(defun weekendp ()
  (member (format-time-string "%a")
          '("Sat" "Sun")))

(defun first-heading ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward (format "^%s" (regexp-quote daily-review-heading-prefix))
                             nil
                             t)
      (buffer-substring-no-properties (line-beginning-position) (line-end-position)))))
