(load "~/.emacs.d/lisp/PG/generic/proof-site")
(add-hook 'coq-mode-hook #'company-coq-mode)
(setq coq-compile-before-require t)
