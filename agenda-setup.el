
(require 'org-install)
(require 'org-habit)

(require 'org-capture)

;; (defclass org-projectile-per-complex-project-strategy nil nil)

;; (defmethod occ-get-categories ((_ org-projectile-per-complex-project-strategy))
;;   (org-projectile-get-project-file-categories))

;; (defmethod occ-get-todo-files ((_ org-projectile-per-complex-project-strategy))
;;   (mapcar 'org-projectile-get-project-todo-file projectile-known-projects))

;; (defmethod occ-get-capture-file
;;     ((s org-projectile-per-complex-project-strategy) category)
;;   (let ((project-root
;;          (cdr (assoc category
;;                      (org-projectile-category-to-project-path s)))))
;;     (org-projectile-get-project-todo-file project-root)))

;; (defmethod occ-get-capture-marker
;;     ((strategy org-projectile-per-complex-project-strategy) context)
;;   (with-slots (category) context
;;     (let ((filepath (occ-get-capture-file strategy category)))
;;       (with-current-buffer (find-file-noselect filepath)
;;         (point-max-marker)))))

;; (defmethod occ-target-entry-p
;;     ((_ org-projectile-per-complex-project-strategy) _context)
;;   nil)

;; (defmethod org-projectile-category-to-project-path
;;     ((_ org-projectile-per-complex-project-strategy))
;;   (mapcar (lambda (path)
;;             (cons (org-projectile-category-from-project-root
;;                    path) path)) projectile-known-projects))


;; (defun org-projectile-per-complex-project ()
;;   "Set `org-projectile-strategy' so that captures occur within each project."
;;   (interactive)
;;   (setq org-projectile-strategy
;;         (make-instance 'org-projectile-per-complex-project-strategy)))

(setq org-agenda-files '("~/org-mode/agenda.org" "~/.notes"))
(use-package org-projectile
  :bind (("C-c n p" . org-projectile-project-todo-completing-read)
         ("C-c c" . org-capture))
  :config
  (progn
    (org-projectile-single-file)
    (setq org-projectile-projects-file
    	  "~/org-mode/projects/todos.org")
    (setq org-agenda-files
    	  (append org-agenda-files
    		  (seq-filter 'file-exists-p (org-projectile-todo-files))))
    (push (org-projectile-project-todo-entry) org-capture-templates)
    ;;
    ;; per project
    ;;
    ;; (org-projectile-per-project)
    ;; (setq org-agenda-files
    ;; 	  (append org-agenda-files
    ;; 		  '("~/org-mode/projects/todos.org")
    ;; 		  (seq-filter 'file-exists-p (org-projectile-todo-files))))
    ;; (push (org-projectile-project-todo-entry) org-capture-templates)
    ;; ;; (setq org-projectile-per-project-filepath "todo.org")
    ;; ;; (global-set-key (kbd "C-c c") 'org-capture)
    ;; ;; (global-set-key (kbd "C-c n p") 'org-projectile-project-todo-completing-read)
    )
  :ensure t)
(setq org-confirm-elisp-link-function nil)

(append '(1) '(2 3) '(4 5))

(use-package org-projectile-helm
  :after org-projectile
  :bind (("C-c n p" . org-projectile-helm-template-or-project)))


(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
