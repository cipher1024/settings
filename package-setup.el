(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives
   (quote
    (("melpa-local" . "/Users/simon/melpa/html")
     ("melpa" . "http://melpa.org/packages/")
     ("org" . "http://orgmode.org/elpa/")
     ("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))))
; package-archives
(package-initialize)

(unless (package-installed-p 'use-package)
	(package-refresh-contents)
	(package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq load-path (cons "~/.emacs.d/lisp/" load-path))
(setq load-path (cons "~/.emacs.d/template/lisp/" load-path))
(use-package auto-package-update
  :ensure t)
