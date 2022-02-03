
(autoload 'cvc-mode "cvc-mode" "CVC specifications editing mode." t)
(setq auto-mode-alist
      (append  (list '("\\.cvc$" . cvc-mode)) auto-mode-alist))

(global-font-lock-mode t)
