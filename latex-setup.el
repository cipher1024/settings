
(use-package auctex
  :ensure t
  :defer t
  :config
  (add-hook 'LaTeX-mode-hook #'LaTeX-preview-setup)
  ;; (add-hook 'LaTeX-mode-hook 'yas-minor-mode)
  ;; (remove-hook 'LaTeX-mode-hook 'yas-minor-mode)
  (add-hook 'LaTeX-mode-hook 'auto-fill-mode)
  (use-package company-auctex
    :ensure t)

  (use-package auctex-latexmk
    :ensure t))



;; (use-package preview-latex
;;   :ensure t)

;; (use-package yasnippets-latex
;;   :ensure t)
;; (use-package preview-latex
;;   :ensure t)
(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb)
         ("C-c C-w" . org-refile)
         ("C-c j" . org-clock-goto)
         ("C-c C-x C-o" . org-clock-out)))

(require 'ox-latex)

(setq latex-run-command "xelatex")

(add-hook 'pdf-view 'my-inhibit-global-linum-mode)

(defun my-inhibit-global-linum-mode ()
  "Counter-act `global-linum-mode'."
  (add-hook 'after-change-major-mode-hook
            (lambda () (linum-mode 0))
            :append :local))

(defun translate-org-to-tex ()
  (interactive)
  (goto-char (point-min))
  (replace-regexp "^\\*\\{2\\} \\(.*\\)" "\\\\section{\\1}")
  (goto-char (point-min))
  (replace-regexp "^\\*\\{3\\} \\(.*\\)" "\\\\subsection{\\1}")
  (goto-char (point-min))
  (replace-regexp "^\\*\\{4\\} \\(.*\\)" "\\\\subsubsection{\\1}")
  (replace-regexp "^\\*\\{5,\\} \\(.*\\)" "\\\\paragraph{\\1}")
  (goto-char (point-min))
  (replace-regexp "^<<\\(.*\\)>>$" "\\\\label{\\1}")
  (goto-char (point-min))
  (replace-regexp "^\\*\\{15,\\} TODO \\(.*\\)" "\\\\todo{\\1}")
  (goto-char (point-min))
  (replace-regexp "^\\*\\{15,\\} END\n" "")
  (goto-char (point-min))
  (replace-regexp "#" "%")
  (goto-char (point-min))
  (replace-regexp "cite:\\(\\(\\w\\|-\\|,\\w\\)+\\)" "\\\\cite{\\1}")
  (goto-char (point-min))
  (replace-regexp "ref:\\(\\w+\\)" "\\\\ref{\\1}")
  )

(defun compile-timesheet ()
  (let ((default-directory "/Users/simon/Documents/Haskell/activity-watch/"))
    (start-process "timesheet" nil "stack" "run")))

;; (setq TeX-save-query nil)

;; (use-package helm-bibtex
;;   :ensure t)
;; (use-package bibtex-mode
;;   :ensure t)
;; (use-package ebib
;;   :ensure t)
;; (global-set-key "\C-ce" 'ebib)
