

;; DO not disturb explanation:
;; https://apple.stackexchange.com/a/368538
;; https://heyfocus.com/blog/enabling-do-not-disturb-mode/

;; hooks
;; * org-timer-done-hook
;; * org-timer-start-hook
;;
;; Commands:
;; * org-timer-set-timer
;; * org-timer-pause-or-continue
;;
;; Do Not Disturb util:
;; https://github.com/joeyhoer/dnd

(require 'org)

(use-package org-pomodoro)

;; pomodoro
(setq org-timer-default-timer "25")
(setq org-clock-sound nil)
;; (setq org-clock-sound "~/.emacs.d/mixkit-attention-bell-ding-586.wav")
  ;; (play-sound-file  "~/.emacs.d/mixkit-attention-bell-ding-586.wav")
  ;; (sound-wav-play  "~/.emacs.d/mixkit-attention-bell-ding-586.wav")
;; (org-entry-put nil org-effort-property "25")
(setq org-clock-effort "25")
(org-refresh-property '((effort . identity)
                        (effort-minutes . org-duration-to-minutes))
                      "25")

(defvar focus-task nil)
(defvar focus-task-display nil)

(setq org-timer-display 'both)
;; (setq org-timer-display 'frame-title)
;; (setq org-timer-display 'mode-line)

(unless (listp frame-title-format)
  (setq frame-title-format (list frame-title-format)))

(defun dnd-del-display-var (var)
  (when (or (eq org-timer-display 'mode-line)
            (eq org-timer-display 'both))
    (setq global-mode-string
          (delq var global-mode-string)))
  (when (or (eq org-timer-display 'frame-title)
            (eq org-timer-display 'both))
    (setq frame-title-format
          (delq var frame-title-format))))

(defun dnd-add-display-var (var)
  (when (or (eq org-timer-display 'mode-line)
            (eq org-timer-display 'both))
    (or global-mode-string (setq global-mode-string '("")))
    (or (memq var global-mode-string)
        (setq global-mode-string
              (append global-mode-string (list var)))))
  (when (or (eq org-timer-display 'frame-title)
            (eq org-timer-display 'both))
    (or (memq var frame-title-format)
        (setq frame-title-format
              (append frame-title-format (list var))))))

;; todo: fit with git
(defun focus-format-task-display ()
  (if nil
  ;; (if-let ((citc (fig-client-name)))
      (setq focus-task-display
            ;; (propertize (format " task: %s" focus-task) 'face 'bold)))
            (format " [task: %s] {citc: %s}" focus-task (fig-client-name)))
      (setq focus-task-display
            (format " [task: %s]" focus-task))))

(defun focus-set-task (task)
  (interactive
   (list (read-string "New task name: " focus-task 'focus-task-history)))
  (setq focus-task task)
  (focus-format-task-display))

;; focus-task-history
(defun focus-pick-task (&optional task)
  (setq focus-task (or task
                       (read-string "Task: " nil 'focus-task-history)))
  (focus-format-task-display)
  (message "focus on %s" focus-task)
  (setup-citc-root)
  ;; WHAT happens when we pause and resume?
  (focus-create-note-paragraph)
  (dnd-add-display-var 'focus-task-display))

;; (focus-pick-task)
(defun focus-task-hide ()
  (message "done focusing on %s" focus-task)
  (dnd-del-display-var 'focus-task-display)
  (focus-close-note-paragraph)
  )

(setq focus-current-work-log nil)
(setq focus-current-notes-file nil)
(setq focus-start-time nil)
(setq focus-task-history nil)

(defun magit--root ()
  (vc-find-root default-directory ".git"))

;; TODO:
;; uncommit WIP
(defun focus-create-note-paragraph ()
  (update-gcert)
  (let* ((root (magit--root))
         (emacs-dir (concat (getenv "HOME") "/.emacs.d/"))
         (work-log
          (cond (root (concat root "work-log.org"))
                ((string-prefix-p emacs-dir
                                  default-directory)
                 (concat emacs-dir "work-log.org"))
                (t nil)))
         (notes-file
          (cond (root (concat root "notes.org"))
                ((string-prefix-p emacs-dir
                                  default-directory)
                 (concat emacs-dir "notes.org"))
                (t nil))))
    (setq focus-start-time (current-time-string))
    (when notes-file
      ;; (fig--uncommit-wip-commit)
      (setq focus-current-notes-file notes-file)
      (setq focus-current-work-log work-log)
      ;; (with-current-buffer (find-file-noselect notes-file)
      ;;   (save-excursion
      ;;     (goto-char (point-min))
      ;;     (forward-line)
      ;;     (insert (format "\n\n** START: %s (%s)\n\n"
      ;;                     focus-task (current-time-string)))))

      )
      ))

(setq focus-previously-visited-buffers nil)

(defun focus-dump-where-was-I-status (loc &optional absolute)
  (erase-buffer)
  (when (string-prefix-p "blaze " compile-command)
    (recentf-dump-variable 'compile-command)
    (recentf-dump-variable 'compilation-directory)
    (insert "(add-to-list 'compile-history compile-command)\n")
    (when-let ((target (car google3-build-target-history)))
      (insert (format
               "(add-to-list 'google3-build-target-history %s)\n"
               (prin1-to-string target)))))
  (recentf-dump-variable 'google3-target-list)
  (recentf-dump-variable 'focus-task)
  (recentf-dump-variable 'focus-previously-visited-buffers)
  (insert (format "(add-to-list 'focus-task-history focus-task)\n"))
  (recentf-dump-variable 'google3-current-test-output-mode)
  (recentf-dump-variable 'google3-build-default-extra-arguments)
  (recentf-dump-variable
   'google3-build-extra-argument-list)
  (let ((jump-to-fn
         (if absolute "jump-to-location-in-file" "find-google3-file")))
      (insert (format "(setq buffer-where-I-was (%s %s))" jump-to-fn (prin1-to-string loc)))
      (save-buffer)))

(setq focus-current-frame nil)

(defun focus-project-buffer ()
  (let ((root (magit--root)))
    (if root
        (magit-mode-get-buffer 'magit-status-mode)
      nil)))

(defun focus--jump-into-context (status-file &optional no-timer num-buffers-to-restore timer)
  (unless num-buffers-to-restore (setq num-buffers-to-restore 10))
  (setq focus-previously-visited-buffers nil)
  (unless no-timer
    (let ((org-timer-set-hook (remove 'focus-pick-task org-timer-set-hook)))
      (org-timer-set-timer (or timer 25))))
  (load-file status-file)
  (let (root project)

    (with-selected-window (selected-window)
      (with-current-buffer buffer-where-I-was
        (mapc
         (lambda (fn) (find-google3-file fn nil))
         (reverse (seq-take focus-previously-visited-buffers
                            num-buffers-to-restore)))
        (if no-timer
            (focus-format-task-display)
          (focus-pick-task focus-task))
        (setq root (magit--root))
        (when root (save-excursion (magit-status root)))
        (setq project (focus-project-buffer))
        ))
    (if project
        (with-current-buffer project
          (if (boundp 'focus-last-used-frame)
              (let ((layout focus-window-layout))
                (with-selected-frame (or focus-last-used-frame
                                         (selected-frame))
                  (set-window-configuration layout)))
            (delete-other-windows)))
      (delete-other-windows)
      )
    )
  )

        ;; (setq-local focus-last-used-frame
        ;;          (or focus-current-frame (selected-frame)))
        ;; (setq-local focus-window-layout
        ;;          (current-window-configuration
        ;;           focus-last-used-frame))))))


(defun focus-reload-context (&optional arg)
  (interactive (with-universal-argument
                '()
                (list (read-number "How many previously open buffers to open? "))))
  (focus--jump-into-context
   (if-let ((root (magit--root)))
       (concat root "where-was-I.el")
     "~/where-was-I.el")
   t arg))

(defun focus-where-was-I (&optional timer)
  (let ((status-file "~/where-was-I.el"))
    (if (file-exists-p status-file)
        (focus--jump-into-context status-file nil nil timer)
      (error "No \"where-was-I.el\" file found"))))

(defun focus-citc-where-was-I (&optional timer)
  (interactive
   (with-universal-argument
    nil
    (list
     (let ((default-timer
             (if (numberp org-timer-default-timer)
                 (number-to-string org-timer-default-timer)
               org-timer-default-timer)))
     (read-from-minibuffer
           "How much time left? (minutes or h:mm:ss) "
           (and (not (string-equal default-timer "0")) default-timer))))))
  (update-gcert)
  (if-let ((root (magit--root)))
      (let ((status-file (concat root "where-was-I.el")))
        (if (file-exists-p status-file)
            (focus--jump-into-context status-file nil nil timer)
          (focus-where-was-I timer)))
    (focus-where-was-I timer)))

(defun major-mode-ancestry-root (&optional mode)
  (when (null mode) (setq mode major-mode))
  (let ((parent (get mode 'derived-mode-parent)))
    (if parent (major-mode-ancestry-root parent)
      mode)))

(defun major-mode-derived-from (parent)
  (let ((mode major-mode))
    (while (and mode (not (eq mode parent)))
      (setq mode (get mode
                      'derived-mode-parent)))
    (and mode t)))

(defun file-location ()
  (format "%s:%s:%s"
          (buffer-file-name)
          (line-number-at-pos)
          (1+ (current-column))))

(defun focus-save-my-place ()
  (interactive)
  (setq focus-previously-visited-buffers
        (mapcar
         (lambda (b)
           (with-current-buffer b (file-location)))
         (fig-list-citc-code-buffers)))
  (let ((root (fig--root)))
    (when root
      (let ((loc (file-location)))
        (with-current-buffer (find-file-noselect (concat root "where-was-I.el"))
          (focus-dump-where-was-I-status loc)
          )))
    (let ((loc (file-location)))
      (with-current-buffer (find-file-noselect "~/where-was-I.el")
        (focus-dump-where-was-I-status loc t)
        ))
    (when root
      (with-current-buffer
          (fig-mode--buffer #'fig-status-mode (fig--root))
        (setq-local focus-last-used-frame
                    (or focus-current-frame (selected-frame)))
        (setq-local focus-window-layout
                    (current-window-configuration
                     focus-last-used-frame))))))

(defun focus-close-note-paragraph ()
  (when focus-current-notes-file
    (with-current-buffer
        (with-current-buffer
            (find-file-noselect focus-current-notes-file)
          (or (car (fig-list-citc-code-buffers)) (current-buffer)))
      (let* ((time (format-time-string "%R"))
             (root (magit--root))
             (loc (file-location))
             (absolute-loc (file-location))
             (formatted-loc loc)
             ;; (formatted-loc (format "[[%s][location]]" loc))
             (rev
              '(when (fig--root)
                (when (fig--get-modified-files)
                  (focus-make-wip-commit))
                (fig--get-current-revision)))
             (citc '(fig-client-name))
             (cl '(if (magit--root) (format "cl/%s" (fig--change-list))
                   "(no CL)")))
        (focus-save-my-place)
        (with-selected-window
            (selected-window)
          (find-file-other-window focus-current-notes-file)
          (find-file-other-window "~/priority.org"))
        (with-current-buffer (find-file-noselect "~/work-log.org")
          (save-excursion
            (goto-char (point-min))
            (insert (format "** WORK ITEM: %s (%s to %s)\n"
                            focus-task focus-start-time time))
            (insert (concat "last working at:\n"
                            "  (find-google3-file-in-citc \n"
                            "    \"" citc "\"\n"
                            "    \"" formatted-loc "\")\n"
                            (when citc
                              (concat "client:      " citc "\n"))
                            (when (string-prefix-p "blaze " compile-command)
                              (concat "blaze command line:\n  " compile-command "\n"))
                            (when rev
                              (concat "at revision: " rev "\n"))
                            (unless (equal cl "0")
                              (concat "in CL:       " cl "\n"))
                            "\n"))
            (save-buffer)))
        (with-current-buffer (find-file-noselect focus-current-work-log)
          (save-excursion
            (goto-char (point-min))
            (forward-line)
            (insert (format "** WORK ITEM: %s (%s to %s)\n"
                            focus-task focus-start-time time))
            (insert (concat "last working at:\n"
                            "   " formatted-loc "\n"
                            ;; (when rev
                            ;;   (concat "at revision: " rev "\n"))
                            ;; (unless (equal cl "0")
                            ;;   (concat "in CL:       " cl "\n"))
                            ;; (when (string-prefix-p "blaze " compile-command)
                            ;;   (concat "blaze command line:\n  " compile-command "\n"))
                            "\n"))
            (save-buffer)))
        (setq focus-start-time nil)
        (setq focus-current-work-log nil)
        (setq focus-current-notes-file nil)))))


(defun fig--get-modified-files ()
(split-string (fig--hg-string "status" "--modified" "--added" "--removed" "--deleted" "--unknown") "\n" t))

(quote
(with-current-buffer
    (find-file-noselect "/google/src/cloud/simonhudon/poisoning-test/google3/net/bamm2/internal/injectz_test.cc")
  (progn
    ;; (fig--change-list)))
    ;; (focus-create-note-paragraph)
    (fig--get-modified-files)
    ;; (sleep-for 3)
    ;; (focus-close-note-paragraph)))
    ))

)

(defun fig--get-commit-message ()
  (mapconcat (lambda (str) (substring str 1))
             (seq-filter (apply-partially 'string-prefix-p " ")
                         (split-string (fig--hg-string "summary") "\n")) "\n"))

(setq focus-timer nil)
(setq focus-timer-handlers nil)

(defun focus-schedule-task (fn &optional delay)
  (when focus-timer (cancel-timer focus-timer))
  (add-to-list 'focus-timer-handlers
               (list default-directory
                     (current-buffer)
                     fn))
  (setq focus-timer
        (run-with-timer (or delay 5) nil 'focus-run-timer-handlers)))

(defun focus-run-timer-handlers ()
  (mapc (lambda (h)
          (destructuring-bind (dir buf fn) h
            (if (buffer-live-p buf)
                (with-current-buffer buf
                  (let ((default-directory dir))
                    (funcall fn)))
              (message "Dead buffer: %s" buf))))
        focus-timer-handlers)
  (setq focus-timer nil)
  (setq focus-timer-handlers nil))

;; get buffer
(defun fig--uncommit-wip-commit ()
  (when (string-prefix-p "WIP: " (fig--get-commit-message))
    (with-current-buffer
        (fig-mode--buffer #'fig-status-mode (fig--root))
      (focus-schedule-task
       (lambda ()
         (fig-uncommit (list "--no-keep")))))))

(defun focus-start-day ()
  (interactive)
  (when (buffer-live-p proof-shell-buffer)
    (proof-shell-exit))
  (dolist (b (append (list-file-buffers-in-mode 'coq-mode)
                     (list-file-buffers-in-mode 'lean4-mode)))
    (with-current-buffer b
      (save-buffer)
      (kill-buffer)))
  (find-file "~/priority.org")
  (delete-other-windows))

(defun focus-make-wip-commit ()
  (interactive)
  (with-current-buffer
      (fig-mode--buffer #'fig-status-mode (fig--root))
    (focus-schedule-task
     (lambda ()
       (let ((cl (fig--change-list)))
         (fig--hg-run-async "commit"
                            (append
                             (list
                              "-s"
                              "-m" (format "WIP: %s at %s"
                                           focus-task (current-time-string)))
                             (when (not (= cl 0)) (list "--same-cl")))))))))

;; (with-current-buffer
;;     (find-file-noselect "/google/src/cloud/simonhudon/poisoning-test/google3/net/bamm2/internal/injectz_test.cc")
;;   ;; (fig--get-current-revision)
;;   (fig--uncommit-wip-commit)
;;   )

(defun do-not-disturb-on ()
  (interactive)
  (message "org-timer: start do not disturb mode")
  (shell-command "dnd on"))

(defun do-not-disturb-off ()
  (interactive)
  (message "org-timer: disable do not disturb mode")
  (shell-command "dnd off"))

(defun do-not-disturb-ring ()
  (message "org-timer done!: %s" (current-time-string))
  (sound-wav-play  "~/.emacs.d/mixkit-attention-bell-ding-586.wav"))

(add-hook 'org-timer-start-hook 'do-not-disturb-on)
(add-hook 'org-timer-set-hook 'do-not-disturb-on)
(add-hook 'org-timer-set-hook 'focus-pick-task)

(add-hook 'org-timer-done-hook 'do-not-disturb-off)
(add-hook 'org-timer-done-hook 'do-not-disturb-ring)
(add-hook 'org-timer-done-hook 'focus-task-hide)

(add-hook 'org-timer-stop-hook 'do-not-disturb-off)
(add-hook 'org-timer-stop-hook 'focus-task-hide)
