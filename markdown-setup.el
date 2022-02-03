(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (progn
	  (setq markdown-command "multimarkdown")
	  (add-hook 'mark-down-mode'auto-fill-mode)))

