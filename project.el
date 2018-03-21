;;; -*- lexical-binding: t -*-

(provide 'project)
(require 'neotree)
(require 'find-file-in-project)

(require 'projectile)
(require 'counsel-projectile)
(require 'helm-projectile)
;; (require 'persp-projectile)

(require 'project-explorer)

;; (project-explorer-open) -- open the sidebar
;; (project-explorer-helm) -- browse the file collection using helm
;; Main key-bindings:

(projectile-global-mode)
(setq pe/omit-gitignore t)
(setq pe/cache-enabled t)
(setq projectile-enable-caching t)
;; (setq projectile-project-root

;; "s"        Change directory
;; "j"        Next line
;; "k"        Previous line
;; "g"        Refresh
;; "+"        Create file or directory (if the name ends with a slash)
;; "-" & "d"  Delete file or directory
;; "c"        Copy file or directory
;; "r"        Rename file or directory
;; "q"        Hide sidebar
;; "u"        Go to parent directory
;; "["        Previous sibling
;; "]"        Next sibling
;; "TAB"      Toggle folding. Unfold descendants with C-U
;; "S-TAB"    Fold all. Unfold with C-U
;; "RET"      Toggle folding of visit file. Specify window with C-U
;; "f"        Visit file or directory. Specify window with C-U
;; "w"        Show the path of file at point, and copy it to clipboard
;; "M-k"      Launch ack-and-a-half, from the closest directory
;; "M-l"      Filter using a regular expression. Call with C-u to disable
;; "M-o"      Toggle omission of hidden and temporary files

;; (defun pe/project-root-function-sample ()
;;   (expand-file-name
;;    (or
;;     ;; A specific directory
;;     (when (string-prefix-p "/path/to/my/project/" default-directory)
;;       "/path/to/my/project/")
;;     ;; A directory containg a file
;;     (locate-dominating-file default-directory "Web.config")
;;     default-directory)))

;; d
;; (setq pe/project-root-function 'pe/project-root-function-sample)

(setq project-list '())

(defun close-other-projects ()
  (when project-list
    (mapc (lambda (p) (funcall (cdr p))) (cdr project-list))
    (setq project-list (list (car project-list)))
    '()))

(defun close-all-projects ()
  (mapc (lambda (p) (funcall (cdr p))) project-list)
  (setq project-list '())
  '())

;; (close-other-projects)

(defun register-project (prj-name dir &optional other-buffers)
  (let ((abs-dir (file-name-as-directory (expand-file-name dir))))
    (setq project-list
	  (cons (cons prj-name
		      (lambda ()
			(dolist (buf (buffer-list))
			  (when-let (fn (buffer-file-name buf))
			    (if (string-prefix-p abs-dir fn)
				(kill-buffer buf))))
			(dolist (buf-name other-buffers)
			  (when-let (buf (get-buffer buf-name))
			    (kill-buffer buf)))))
		project-list))))

(global-set-key (kbd "C-x p") 'project-explorer-helm)
(global-set-key (kbd "C-x C-p") 'project-explorer-open)

;; (when neo-persist-show
;;   (add-hook 'popwin:before-popup-hook
;; 	    (lambda () (setq neo-persist-show nil)))
;;   (add-hook 'popwin:after-popup-hook
;; 	    (lambda () (setq neo-persist-show t))))
(add-to-list 'neo-hidden-regexp-list ".olean")
(add-to-list 'neo-hidden-regexp-list ".path")
(add-to-list 'neo-hidden-regexp-list ".sublime-workspace")

(setq neo-smart-open t)
(setq projectile-switch-project-action 'neotree-projectile-action)
(defun neotree-project-dir ()
  "Open NeoTree using the git root."
  (interactive)
  (let ((project-dir (projectile-project-root))
	(file-name (buffer-file-name)))
    (neotree-toggle)
    (if project-dir
	(if (neo-global--window-exists-p)
	    (progn
	      (neotree-dir project-dir)
	      (neotree-find file-name)))
      (message "Could not find git project root."))))

;; (global-set-key (kbd "C-x C-n") 'neotree-toggle)
(global-set-key (kbd "C-x C-n") 'neotree-project-dir)

(defun switch-to-emacs-config ()
  (register-project "emacs-config" "~/.emacs.d" '())
  (find-file-in "~/.emacs.d/init.el" (get-first-window))
  (close-other-projects))
