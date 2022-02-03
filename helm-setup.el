(use-package helm
  :ensure t
  :diminish helm-mode
  :commands (helm-bookmarks
             helm-buffers-list
             helm-colors
             helm-find-files
             helm-for-files
             helm-google-suggest
             helm-mini
             helm-help
             helm-show-kill-ring
             helm-org-keywords
             helm-org-headlines
             helm-projectile
             helm-M-x
             helm-occur)
  :bind (("C-c h"     . helm-mini)
         ("C-h a"     . helm-apropos)
         ;; ("C-x C-b"   . helm-buffers-list)
         ("M-y"       . helm-show-kill-ring)
         ("M-x"       . helm-M-x)
         ("C-x c o"   . helm-occur)
         ("C-x c y"   . helm-yas-complete)
         ("C-x c Y"   . helm-yas-create-snippet-on-region)
         ("C-x c b"   . my/helm-do-grep-book-notes)
         ("C-x c SPC" . helm-all-mark-rings)
         ("C-x l"     . helm-bookmarks)))

;; (defun helm-buffers-list ()
;;   "Preconfigured `helm' to list buffers."
;;   (interactive)
;;   (unless helm-source-buffers-list
;;     (setq helm-source-buffers-list
;;           (helm-make-source "Buffers" 'helm-source-buffers)))
;;   (helm :sources '(helm-source-buffers-list
;;                    helm-source-ido-virtual-buffers
;;                    helm-source-buffer-not-found)
;;         :buffer "*helm buffers*"
;;         :keymap helm-buffer-map
;;         :truncate-lines helm-buffers-truncate-lines))

;; (helm-buffers-list)
