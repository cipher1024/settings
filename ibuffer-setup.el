(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)
(require 'ibuf-ext)
;; (add-to-list 'ibuffer-never-show-predicates "^\\*")
;; (setq ibuffer-never-show-predicates (delete "^\\*" ibuffer-never-show-predicates))
(add-hook 'ibuffer-mode-hook (lambda () (ibuffer-auto-mode 1)))
