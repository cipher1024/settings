
(require 'helm-multi-match)

(defun vlc-setup ()
  (interactive)
  (local-set-key (kbd "C-c C-c") 'vlc-open)
  (local-set-key (kbd "C-c C-k") 'vlc-play)
  (auto-revert-mode t)
  (setq-local vlc-dirty t)
  (setq-local vlc-buff (get-buffer-create "*vlc*"))
  (setq-local vlc-current-file nil)
  (when (buffer-file-name)
      (setq-local vlc-timer (run-with-idle-timer 10 t 'vlc-cleanup-references-2 (current-buffer)))
      (add-hook 'kill-buffer-hook (lambda () (cancel-timer vlc-timer)) t t))
  (collect-lines)
  (add-to-list 'revert-without-query (buffer-file-name))
  (save-selected-window
    (switch-to-buffer-other-window vlc-buff))
  (setq-local vlc-last-point (point))
  (add-hook 'pre-command-hook (lambda () (setq-local vlc-last-point (point))) t t)
  (add-hook 'post-command-hook 'vlc-on-command t t))

(defmacro let-buffer (buf init &rest body)
  (let ((var-name (car buf))
        (buf-name (cadr buf)))
    `(let ((,var-name
            (if-let (,var-name (get-buffer ,buf-name))
                ,var-name
              (let ((,var-name (get-buffer-create ,buf-name)))
                (with-current-buffer ,var-name
                  ,init)
                ,var-name))))
       ,@body)))

(defun vlc-playlist ()
  (interactive)
  (let-buffer (buf "*vlc-playlist*")
              (progn
                (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
                (yaml-mode)
                (vlc-update-playlist buf)
                (vlc-setup)
                (local-unset-key (kbd "C-c C-k"))
                (local-set-key (kbd "C-c C-k") 'vlc-select-in-playlist)
                (local-unset-key (kbd "C-c C-c"))
                (local-set-key (kbd "C-c C-c") 'vlc-enqueue)
                (setq-local vlc-playlist-timer
                            (run-with-idle-timer 1 t 'vlc-update-playlist (current-buffer)))
                (add-hook 'pre-command-hook 'vlc-playlist-delete-line t t)
                (add-hook 'kill-buffer-hook (lambda () (cancel-timer vlc-playlist-timer)) t t))
              (switch-to-buffer buf)))

(defun vlc-playlist-delete-line ()
  (if (eq this-command 'kill-whole-visual-line)
      (let ((line (buffer-substring-no-properties (line-beginning-position)
                                                  (line-end-position))))
        (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
        (process-lines
                "vlc-playlist"
                "delete"
                (yaml-drop-bullet line))
        (collect-lines))))

;; (add-hook 'pre-command-hook 'vlc-playlist-delete-line t t)

(defun vlc-update-playlist (buf)
  (with-current-buffer buf
    (save-excursion
      (let ((lst (mapconcat 'identity (process-lines "vlc-playlist")
                            "\n")))
        (unless (equal lst (buffer-substring-no-properties (point-min) (point-max)))
          (erase-buffer)
          (insert lst)
          (not-modified)
          (collect-lines)) ))))

(defun vlc-query ()
  (interactive)
  (let ((buf2 (get-buffer "*vlc-query*"))
        (buf (get-buffer-create "*vlc-query*")))
    (unless buf2
      (with-current-buffer buf
        (yaml-mode)
        (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
        (insert (mapconcat 'identity
                           '( "matching: All # or Any"
                              "options:"
                              "- Tag # or Pornstar"
                              "keywords:"
                              "- kw")
                           "\n"))
        (local-set-key (kbd "C-c C-i") 'vlc-insert-tag)
        (local-set-key (kbd "C-c C-c") 'vlc-run-query)))
    (switch-to-buffer buf)))

(defun vlc-run-query ()
  (interactive)
  (let ((buf2 (get-buffer "*vlc-query-results*"))
        (buf (get-buffer-create "*vlc-query-results*")))
    (when buf2
      (with-current-buffer buf
        (erase-buffer)
        (kill-all-local-variables)))
    (with-current-buffer (get-buffer "*vlc-query*")
      (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
      (call-process-region (point-min) (point-max) "vlc-query" nil buf nil))
    (with-current-buffer buf
      (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
      (vlc-setup))
    (switch-to-buffer buf)))

(defun vlc-insert-tag ()
  (interactive)
  (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
  (let ((kws (process-lines "vlc-query" "tags")))
    (goto-char (line-end-position))
    (insert (format "\n- %s" (helm
                              :sources (helm-build-sync-source "Tag: "
                                         :candidates kws)
                              :buffer "*tag*")))))

(defun vlc-insert-pornstar ()
  (interactive)
  (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
  (let ((kws (process-lines "vlc-query" "pornstars")))
    (goto-char (line-end-position))
    (insert (format "\n- %s" (helm
                              :sources (helm-build-sync-source "Tag: "
                                         :candidates kws)
                              :buffer "*tag*")))))

;; (defmacro for-each-line (line &rest body)
;;   `(save-excursion
;;      (goto-char (point-min))
;;      (while (equal (point-max) (point))
;;        (let ((,line (buffer-substring-no-properties
;;                      (line-beginning-position) (line-end-position))))
;;          ,@body)
;;        (forward-line))))

(defun collect-lines ()
  (setq-local vlc-lines
              (apply 'vector
                     (split-string (buffer-substring-no-properties
                                    (point-min) (point-max)) "\n"))))

(defun vlc-cleanup-references (buf)
  (with-current-buffer (get-buffer-create "*vlc-tags*")
    (let ((pcs (start-process "list-tags" (current-buffer)
                              "list-tags")))
      (setq-local target buf)
      (set-process-sentinel
       pcs
       (lambda (pcs event)
         (with-current-buffer (process-buffer pcs)
           (with-current-buffer target
             (if (= 0 (buffer-size (process-buffer pcs)))
                 (vlc-cleanup-references-2)
               (revert-buffer)
               (collect-lines))))
  )))))
(defun vlc-cleanup-references-2 (buf)
  (interactive)
  ;; (let ((line (buffer-substring-no-properties
  ;;              (line-beginning-position) (line-end-position))))
  ;;   (if (string-prefix-p "- " line)
  ;;       (print (file-exists-p (seq-drop line 2))))))
  (save-excursion
    (with-current-buffer buf
      (goto-char (point-min))
      (while (not (equal (point-max) (point)))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position) (line-end-position))))
          (if (and (string-prefix-p "- " line)
                   (not (file-exists-p (seq-drop line 2))))
              (progn
                (filter-buffer-substring
                 (line-beginning-position) (+ (line-end-position) 1)
                 t))
            (forward-line))))
      (collect-lines)
      (save-buffer))))

(defun vlc-on-command ()
  (interactive)
  (unless (equal vlc-last-point (point))
    (let ((file (vlc-get-current-file))
          (thumb nil)
          (buf vlc-buff))
      (setq-local vlc-dirty (not (equal vlc-current-file file)))
      (setq-local vlc-current-file file)
      ;; (set-buffer-modified-p t)
      (with-current-buffer vlc-buff
        (erase-buffer)
        (setq default-directory (concat (getenv "HOME") "/untitled folder/"))
        (call-process "vlc-get-meta"
                      nil buf nil
                      file)
        (save-excursion
          (goto-char (point-min))
          (add-face-text-property
           (line-beginning-position)
           (line-end-position) 'italic)
          (forward-line)
          (setq thumb (buffer-substring-no-properties
                       (line-beginning-position)
                       (line-end-position)))
          (filter-buffer-substring
           (line-beginning-position)
           (line-end-position)
           t)
          (goto-char (point-max))
          (insert "\n")
          (when (and (not (equal "" thumb))
                     (file-exists-p thumb))
            (insert-image (create-image thumb))))
        (redisplay)
        (save-selected-window
          (switch-to-buffer-other-window buf))
        ))))

(defun yaml-drop-bullet (ln)
  (seq-take-while
   (lambda (x) (not (equal x ":")))
   (seq-drop-while
    (lambda (x) (member x (string-to-list " ->_")))
    ln)))

(defun vlc-get-current-file ()
   (yaml-drop-bullet
    (aref vlc-lines (1- (line-number-at-pos)))))


(defun vlc-open ()
  (interactive)
  (call-process "vlc-enqueue" nil nil nil
                vlc-current-file )
  (filter-buffer-substring
   (line-beginning-position) (+ (line-end-position) 1)
   t)
  (not-modified)
  (collect-lines)
  (setq vlc-last-point (point-min))
  (vlc-on-command))

(defun vlc-play ()
  (interactive)
  (call-process "vlc-enqueue" nil nil nil
                vlc-current-file "-p")
  (filter-buffer-substring
   (line-beginning-position) (+ (line-end-position) 1)
   t)
  (not-modified)
  (collect-lines)
  (setq vlc-last-point (point-min))
  (vlc-on-command))

(defun vlc-select-in-playlist ()
  (interactive)
  (call-process "vlc-playlist" nil nil nil
                "play" (vlc-get-current-file))
  (forward-line)
  (vlc-update-playlist (current-buffer)))

(defun vlc-enqueue ()
  (interactive)
  (save-excursion
    (call-process "vlc-playlist" nil nil nil
                  "delete" (vlc-get-current-file))
    (call-process "vlc-enqueue" nil nil nil
                  vlc-current-file )
    (filter-buffer-substring
     (line-beginning-position) (+ (line-end-position) 1)
     t)
    (not-modified)
    (collect-lines)
    (setq vlc-last-point (point-min))
    (vlc-on-command)))
