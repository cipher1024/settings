
(text-scale-adjust 0)

(setq global-text-scale 3)

(defadvice tlc-widget-start (after tlc-widget-start-resize first activate)
  (text-scale-set global-text-scale))

(defadvice text-scale-increase (around all-buffers (arg) activate)
  (text-scale-set global-text-scale)
  ad-do-it
  (setq global-text-scale text-scale-mode-amount)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (text-scale-set global-text-scale))))

(defadvice text-scale-decrease (around all-buffers (arg) activate)
  ad-do-it
  (setq global-text-scale text-scale-mode-amount)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (text-scale-set global-text-scale))))
;; (get-buffer "*Minibuf*")

(defun my-minibuffer-setup ()
  (text-scale-set global-text-scale))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup)

;; (use-package default-text-scale :ensure t)

;; (global-set-key (kbd "C-x =") 'default-text-scale-increase)
;; (global-set-key (kbd "C-x -") 'default-text-scale-decrease)

(add-hook 'after-change-major-mode-hook
          (lambda () (text-scale-set global-text-scale)))

;; (window-header-line-height)

(after-init (dolist (buffer (buffer-list))
              (with-current-buffer buffer
                (text-scale-set global-text-scale)))
            )

(add-hook 'minibuffer-setup-hook
          (lambda ()
            (text-scale-set global-text-scale)))

(add-hook 'buffer-list-update-hook
          (lambda () (text-scale-set global-text-scale)))

;; #insert date#

(defun insert-current-date ()
  (interactive)
  (insert (shell-command-to-string "echo -n $(date +%Y-%m-%d)")))
