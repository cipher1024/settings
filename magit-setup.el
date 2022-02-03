(use-package git-gutter :ensure t)
(setq git-gutter:handled-backends '(git hg))

(use-package counsel
  :ensure t)
(use-package ghub
  :ensure t)
(use-package magit
  :ensure t
  :commands (magit-get-top-dir magit-get-current-branch)
  ;; :config
  ;; (magit-define-popup-switch 'magit-log-popup ?f "Follow renames" "--follow")
  :bind (("C-c g" . magit-status)
         ("C-c C-g l" . magit-file-log)
         ("C-c f" . magit-grep)
         ))
;; (unload-feature 'magit t)
;; (use-package git-gutter
;;   :ensure t)
;; ;; (magit-get-top-dir)
;; (magit-get-current-branch)
(add-hook 'after-init-hook
          (lambda ()
           (delete-window (get-buffer-window (magit "~/lean/lean-master")))))

(global-set-key (kbd "C-c g") 'magit-status)

;; (use-package magithub
;;   :after magit
;;   :config
;;   (magithub-feature-autoinject t)
;;   (setq magithub-clone-default-directory "~/github"))

;; (require 'magit-gh-pulls)
;; (add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)

;; (unload-feature 'magithub t)
(setq magit-gh-pulls-pull-detail-limit 1000)
;; magit-gh-pulls-guess-repo

;; (global-git-gutter-mode +1)
;;   :commands magit-get-top-dir
;;   :bind (("C-c g" . magit-status)
;;          ("C-c C-g l" . magit-file-log)
;;          ("C-c f" . magit-grep)))

;; magit-status

;; magit-status-headers-hook
;; magit-status-sections-hook

(defun init-custom-magit-section ()
  ;; (magit-add-section-hook
  ;;  'magit-status-headers-hook
  ;;  'magit-insert-wip-branches-header
  ;;  'magit-insert-upstream-branch-header
  ;;  'after )
  (magit-add-section-hook
   'magit-status-sections-hook
   'magit-insert-wip-branches
   'magit-insert-stashes
   'after
   ))
(init-custom-magit-section)

;; (add-to-list magit-status-headers-hook
;;              magit-insert-head-branch-header
;;              )
;; magit-insert-stashes

;; (defun magit-insert-wip-branches-header ()
;;   (magit-insert-section (wip-branches)
;;     (insert "BAR bar\n")))

(defun is-main-branch (name)
  (or (equal name "master")
      (equal name "main")
      ))

(defun is-wip-branch (name)
  (string-prefix-p "wip-" name))

(defun test-result-symbol (res)
  (cond ((eq res 'PASSED) "✔")
        ((eq res 'FAILED) "❌")
        (t "?"))
  )

(defun magit-format-wip-branch (b)
  (let* ((hash (magit-git-string "show-ref" "--hash" b))
         (result (lean4-lake-get-test-results b hash)))
    (list
     (propertize b 'font-lock-face
                 'magit-branch-local)
     (destructuring-bind (ahead behind)
         (magit-rev-diff-count
          b (magit-main-branch))
        (string-join
         (append (unless (= ahead 0)
                   (list (format "%s ahead" ahead)))
                 (unless (= behind 0)
                   (list (format "%s behind" behind))))
         " / "))
     (let ((nfiles (length (magit-changed-files b "main"))))
       (if (not (= nfiles 0))
           (format "(%s files changed)" nfiles)
         ""))
     (test-result-symbol result))))


(defun magit-insert-wip-branches ()
  (let* ((branches (magit-list-local-branch-names))
         (main-branches
          (-filter 'is-main-branch branches))
         (wip-branches
          (-filter 'is-wip-branch branches))
         (my-branches (append main-branches wip-branches))
         (heading (format "WIP branches (%s)"
                          (length my-branches))))
    (let ((lines (mapcar 'magit-format-wip-branch
                         my-branches)))
    (magit-insert-section (wip-branches)
     (magit-insert-heading heading)
     (mapcar*
      (lambda (b ln)
        (magit-insert-section (wip-branch b t)
          (magit-insert-heading ln)
          ;; (magit-insert-files (magit-changed-files b "main") nil)
          (dolist (fn (magit-changed-files b "main"))
            (magit-insert-section (file fn)
              (insert (propertize fn
                                  'font-lock-face
                                  ;; 'magit-diff-file-heading-selection
                                  ;; 'magit-diff-file-heading
                                  ;; 'magit-diff-file-heading-highlight
                                  'magit-filename
                                  'file
                                  'magit-filename
                                  )
                      ?\n))
            ;; (magit-insert-heading)
            ;; (insert "\n")
            )
          ))
      my-branches (columns 3 lines)))
       ;; (let ((hash (propertize
       ;;              "36bde9f"
       ;;              'font-lock-face
       ;;              'magit-hash)))
         ;; (insert hash) (insert " ")
       ;; (insert b)
     (insert "\n"))))
