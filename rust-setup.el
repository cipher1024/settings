
(use-package rust-mode
  :ensure t
  :defer t
  :config
  (use-package cargo
    :ensure t)
  (use-package racer
    :ensure t)
  ;; (use-package emacs-module-rs
  ;;   :ensure t)
  (use-package flycheck-rust
    :ensure t)
  (use-package flycheck-inline
    :ensure t)

  (add-hook 'rust-mode-hook 'flycheck-mode)
  (add-hook 'rust-mode-hook 'flycheck-inline-mode nil t)
  (add-hook 'rust-mode-hook 'toggle-truncate-lines nil t)
  (add-hook 'rust-mode-hook 'cargo-minor-mode)
  (add-hook 'rust-mode-hook 'racer-mode)
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
  (add-hook 'rust-mode-hook 'set-truncate-lines)
  (add-hook 'racer-mode-hook #'eldoc-mode)
  (add-hook 'racer-mode-hook #'company-mode)

  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (setq company-tooltip-align-annotations t)
  (defun cargo-process-current-test ()
    "Run the Cargo test command for the current test.
With the prefix argument, modify the command's invocation.
Cargo: Run the tests."
    (interactive)
    (setq cargo-previous-test-case (cargo-process--get-current-test-fullname))
    (cargo-process--start "Test"
                          (concat cargo-process--command-current-test
                                  " "
                                  cargo-previous-test-case)))


  (defun cargo-process-previous-test ()
    "Run the Cargo test command for the current test.
With the prefix argument, modify the command's invocation.
Cargo: Run the tests."
    (interactive)
    (setq cargo-process--enable-rust-backtrace t)
    ;; (setq cargo-process--enable-rust-backtrace '())
    (cargo-process--start "Test"
                          (concat cargo-process--command-current-test
                                  " "
                                  cargo-previous-test-case)))

  ;; (text-scale-adjust 0)
  )
