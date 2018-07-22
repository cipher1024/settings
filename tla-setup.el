
;; (unload-feature 'tla-mode t)
(require 'rx)
(require 'tla-mode)
(require 'flycheck-tla)
(add-to-list 'flycheck-checkers 'tla)
(add-hook 'tla-mode-hook 'flycheck-mode)
(add-hook 'tla-mode-hook 'set-truncate-lines)

;; (quelpa '(tla-mode :fetcher github :repo "iamarcel/flycheck-tla"))

;; (add-hook 'tla-mode-hook 'untabify)

;; call-process program &optional infile destination display &rest args

;; alias tlc="java tlc2.TLC"
;; alias tla2sany="java tla2sany.SANY"
;; alias pcal="java pcal.trans"
;; alias tla2tex="java tla2tex.TLA"

(defmacro tla-command (fp buf &rest cmd)
  `(let ((,buf (get-buffer-create "*tla*"))
	(,fp (set-extension (file-relative-name (buffer-file-name)) ".tla")))
    (save-buffer)
    (save-selected-window
    (save-excursion
      (switch-to-buffer-other-window ,buf)
      (with-current-buffer ,buf
        ;; (let ((buffer-read-only nil))
          (erase-buffer)
          ,@cmd))))
	;; (call-process-shell-command
	;;  (format "java -cp $CLASS_PATH tla2sany.SANY %s" (buffer-file-name))
	;;  nil buf)
	)

(define-key tla-mode-map (kbd "C-c C-c") 'tla-check)

(defun tla-parse ()
  (interactive)
  (tla-command
   fp buf
   (call-process "java" nil buf nil
		 "tla2sany.SANY" fp)
   (redisplay)
   (insert "done")))
   ;; (make-process :name "sany"
   ;; 		 :buffer buf
   ;; 		 ;; :stderr buf
   ;; 		 :command (list "java" "tla2sany.SANY" fp))))

(defun tla-check-current ()
  (interactive)
  (let ((current-spec (buffer-file-name)))
    (tla-check)))

(defun tla-get-config ()
  (interactive)
  (find-file (concat (file-name-sans-extension (buffer-file-name)) ".cfg")))

(defun tla-check ()
  (interactive)
  (let ((file (if (boundp 'current-spec)
                  current-spec
                (buffer-file-name)))
        (recover (if (and (boundp 'latest-checkpoint)
                          (not (eq latest-checkpoint '())))
                     (list "-recover" latest-checkpoint)
                   '())))
    (with-current-buffer (find-file-noselect file)
      (let ((vars watch-vars))
        (tla-command
         fp buf
         (tla-info-mode)
         (setq-local source file)
         (setq-local state 'pre)
         (setq-local contents (format "== %s ==\n\n" fp))
         (redisplay)
         (insert contents)
         (setq-local watch-vars vars)
         (make-process :name "tlc"
                       :buffer buf
                       :stderr buf
                       :filter 'keep-output
                       :command `("java" "tlc2.TLC" ,fp
                                  "-checkpoint" "5"
                                  "-workers" "10"
                                  ,@recover )))))))
;; "18-06-24-14-07-27"
;; "18-06-24-13-44-13"
;; "18-06-24-14-06-55"

;; states = '(pre mask keep)
(defvar-local watch-vars nil)

(defun set-watch-vars ()
  (interactive)
  (let ((x (car (read-from-string (read-string "new value: "
                                               (pp watch-vars)
                                               nil
                                               (pp watch-vars))))))
    (setq watch-vars x)
    (when (eq major-mode 'tla-info-mode)
      (with-current-buffer (get-file-buffer source)
        (setq watch-vars x))))
  (tla-info-redisplay))

(defun keep-output (process output)
  (with-current-buffer (process-buffer process)
    ;; (let ((buffer-read-only nil))
    (setq contents (concat contents output))
    (goto-char (point-max))
    (tla-info-redisplay)
    (set-marker (process-mark process) (point))))

(defun tla-run ()
  (interactive)
  (tla-command
   fp buf
   (make-process :name "tlc"
		 :buffer buf
		 :stderr buf
		 :command (list "java" "tlc2.TLC" fp "-simulate" "-depth" "10" "-tool"))))

(defun tla-plus-cal ()
  (interactive)
  (save-buffer)
  (tla-command
   fp buf
   (call-process "java" nil buf nil
		 "pcal.trans" fp)
   (with-current-buffer (get-file-buffer fp)
     (let ((revert-without-query (cons (current-buffer) revert-without-query)))
       (revert-buffer)
     ))))

;; (mapconcat 'identity (list "java" "tlc2.TLC" "model0.tla" "-workers" "7") " ")
;; "java tlc2.TLC model0.tla -workers 7"

(setq revert-without-query nil)

(defun tla-tex ()
  (interactive)
  (tla-command
   fp buf
   (call-process "java" nil buf nil
		 "tla2tex.TLA" fp)
   (when (= 0 (call-process "pdflatex" nil buf nil
			    (set-extension fp ".tex")))
     (let* ((pdf (expand-file-name (set-extension fp ".pdf")))
	    (buf2 (or (get-file-buffer pdf)
		      (find-file pdf))))
       (unless (member pdf revert-without-query)
	 (add-to-list 'revert-without-query pdf))
       (with-current-buffer buf2
	 (switch-to-buffer buf2)
	 (revert-buffer)
	 (redisplay))))
   ))

;; setenv
;; initial-environment

;; process-environment
;;   (call-process "java" nil nil nil
;; 		;; "-cl" (getenv "CLASSPATH")
;; 		"tla2sany.SANY"
;; 		(buffer-file-name)))

(defun ska-untabify ()
   "My untabify function as discussed and described at
 http://www.jwz.org/doc/tabs-vs-spaces.html
 and improved by Claus Brunzema:
 - return nil to get `write-contents-hooks' to work correctly
   (see documentation there)
 - `make-local-hook' instead of `make-local-variable'
 - when instead of if
 Use some lines along the following for getting this to work in the
 modes you want it to:

 \(add-hook 'some-mode-hook
           '(lambda ()
               (make-local-hook 'write-contents-hooks)
                (add-hook 'write-contents-hooks 'ska-untabify nil t)))"
   (save-excursion
     (goto-char (point-min))
     (when (search-forward "\t" nil t)
       (untabify (1- (point)) (point-max)))
     nil))

(add-hook 'tla-mode-hook
           (lambda ()
	     (setq-local indent-tabs-mode nil)))

(add-hook 'tla-mode-hook
           (lambda ()
	     (add-hook 'write-contents-hooks 'ska-untabify nil t)))

(defvar tla-info-mode-hook nil)

(defvar tla-info-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for TLA+ info major mode")

(defun tla-info-mode ()
  "Major mode for displaying results of TLC"
  (interactive)
  (kill-all-local-variables)
  (use-local-map tla-info-mode-map)
  ;; (view-mode)
  (setq-local tla-info-display-expanded nil)
  (setq major-mode 'tla-info-mode)
  (setq mode-name "tla-info")
  (run-hooks 'tla-info-mode-hook))

(require 'mode-local)

;; (define-overload tla-info-redisplay ())
;; (define-overload tla-info-expand ())
;; (define-overload tla-info-fold ())

;; (defun tla-info-redisplay ()
;;   (error "not in tla-info-mode"))

;; (defun tla-info-expand ()
;;   (interactive)
;;   (error "not in tla-info-mode"))

;; (defun tla-info-fold ()
;;   (interactive)
;;   (error "not in tla-info-mode"))

(defun tla-info-expand ()
  (interactive)
;; (define-mode-local-override tla-info-expand tla-info-mode ()
  (setq-local tla-info-display-expanded t)
  (tla-info-redisplay))

(defun tla-info-fold ()
  (interactive)
;; (define-mode-local-override tla-info-fold tla-info-mode ()
  (setq-local tla-info-display-expanded nil)
  (tla-info-redisplay))

(defun tla-info-redisplay ()
;; (define-mode-local-override tla-info-redisplay tla-info-mode ()
  (if tla-info-display-expanded
      (progn (erase-buffer)
             (insert contents))
    (let ((lns (split-string contents "\n")))
      (erase-buffer)
      (mapc (lambda (ln)
              ;; (insert (pp ln)) (newline)
              (if (eq state 'pre)
                  (progn
                    (if (string-prefix-p "State " ln)
                        (setq state 'keep))
                    (insert ln) (newline))
                (cond ((string-prefix-p "/\ " ln)
                       (let* ((ws (split-string (seq-drop ln 3)))
                              (var (car ws)))
                         ;; (insert (pp ws))
                         (if ;; (string-prefix-p "node = " (seq-drop ln 3))
                             (and (or (member var watch-vars)
                                      (null watch-vars))
                                  (equal (cadr ws) "="))
                             (progn (setq state 'keep)
                                    (setq margin (+ 6 (length var)))
                                    (insert ln) (newline))
                           (setq state 'mask))))
                      ((string-prefix-p "State " ln)
                       (newline)
                       (insert ln)
                       (newline))
                      ((eq ln "")
                       (insert "\n"))
                      ((not (string-prefix-p "  " ln))
                       (insert ln)
                       (newline))
                      ((eq state 'keep)
                       (insert (make-string margin (string-to-char " ")))
                       (insert ln) (newline))
                      ((eq state 'filter)
                       nil))))
            lns)
      (goto-char (point-max)))))

(defun tla-not-statep (x)
  (not (string-prefix-p "State " x)))

(defun tla-info-list-states-aux (xs)
  (setq xs (seq-drop-while 'tla-not-statep xs))
  (if (null xs) '()
    (cons (cons (car xs)
                (mapconcat 'identity (seq-take-while 'tla-not-statep (cdr xs)) "\n"))
          (tla-info-list-states-aux (seq-drop-while 'tla-not-statep (cdr xs))))))

(defun tla-info-list-states ()
  (tla-info-list-states-aux (split-string contents "\n")))

(defun tla-state-name (str)
  (seq-take-while (lambda (x) (not (eq x ?:))) str))

(defun tla-insert-init-state ()
  (interactive)
  (insert (with-current-buffer (get-buffer "*tla*")
            (let* ((states (mapcar (lambda (x) (cons (tla-state-name (car x)) (cdr x)))
                                   (tla-info-list-states)))
                   (d (print (seq-take states 4)))
                   (r (ido-completing-read "State: " (reverse (mapcar 'car states)))))
              (concat "MyInit == \n" (cdr (assoc r states)))))))

(provide 'tla-info-mode)
