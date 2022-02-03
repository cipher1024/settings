
(use-package sphinx-mode
  :ensure t)

(add-hook 'markdown-mode-hook 'sphinx-mode)
(add-hook 'rst-mode-hook 'sphinx-mode)
