

(use-package direnv)
(let ((package-check-signature nil))
  (package-install
   'gnu-elpa-keyring-update))
