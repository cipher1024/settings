
(require 'tla-mode)
(provide 'flycheck-tla)
(add-to-list 'flycheck-checkers 'tla)
(add-hook 'tla-mode-hook 'flycheck-mode)
(add-hook 'tla-mode-hook 'set-truncate-lines)

;; (quelpa '(tla-mode :fetcher github :repo "iamarcel/flycheck-tla"))

(add-hook 'tla-mode-hook 'untabify t t)

;; call-process program &optional infile destination display &rest args

(defun tla-parse ()
  (interactive)
  (let ((buf (get-buffer-create "*tla*"))
	(fp (buffer-file-name)))
    (save-excursion
      (switch-to-buffer-other-window buf)
      (with-current-buffer buf
	(erase-buffer)
	(print (call-process "java" nil buf nil
			     "-cp" (getenv "CLASSPATH")
			     "tla2sany.SANY" fp))
	;; (call-process-shell-command
	;;  (format "java -cp $CLASS_PATH tla2sany.SANY %s" (buffer-file-name))
	;;  nil buf)
	))))

;; setenv
;; initial-environment

;; process-environment
;;   (call-process "java" nil nil nil
;; 		;; "-cl" (getenv "CLASSPATH")
;; 		"tla2sany.SANY"
;; 		(buffer-file-name)))
