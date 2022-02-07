

;; The following works with OPAM 2.0.x
;; Put this piece of code into your .emacs and use it interactively as
;; M-x coq-change-compiler
;; If you change your OPAM installation by e.g. adding more switches, then
;; run M-x coq-update-opam-switches and coq-change-compiler will show the updated set of switches.

(defun opam-ask-var (switch package var)
  (ignore-errors (car (process-lines
                       "opam" "var" "--safe" "--switch" switch (concat package ":" var)))))

(defun opam-installed-switches ()
  "Get a list of all installed OPAM switches."
  (process-lines "opam" "switch" "--safe" "list" "--short"))

(defun opam-current-switch ()
  "Get the current OPAM switch."
  (ignore-errors (car (process-lines "opam" "switch" "--safe" "show"))))

;; filter out all OPAM switches not containing Coq installations
(defun coq-opam-switches-with-coq-to-bindir ()
  "Returns alist of (<OPAM switch> / <Coq version> . <Coq's binary directory>."
  (seq-filter
   (lambda (sw.bin) (stringp (cdr sw.bin)))
   ;; (cons ("Local . Coq.dev" . "~/prj/coq/bin/")
   (mapcar
    (lambda (sw)
      (cons
       (concat
                                        ; mark the current OPAM switch
                                        ; this is all ugly, put I don't want to put more effort in it :(
        (if (string= sw opam-current-switch) "-> " "   ")
        sw " / coq-" (opam-ask-var sw "coq" "version"))
       (opam-ask-var sw "coq" "bin")))
    opam-switches)))

(defun coq-configure-env ()
  (when (and (boundp 'coq-env-timer)
             coq-env-timer
             (timerp coq-env-timer))
    (cancel-timer coq-env-timer)
    (setq coq-env-timer nil)
    (setq opam-current-switch (opam-current-switch))
    (setq opam-switches (opam-installed-switches))
    (setq coq-bin-dirs-alist (coq-opam-switches-with-coq-to-bindir))
    (opam-switch "coq-8.13")))

(setq coq-env-timer
      (run-with-idle-timer
       30 nil 'coq-configure-env))

(after-init (coq-configure-env))

(add-hook 'coq-mode-hook 'coq-configure-env)

(defun coq-update-opam-switches ()
  "Update the alist of OPAM switches with Coq installed"
  (interactive)
  (setq opam-switches (opam-installed-switches))
  (setq coq-bin-dirs-alist (coq-opam-switches-with-coq-to-bindir))
  (message "OPAM switches updated."))

(defun coq-change-compiler (coq-bin-dir)
  "Change Coq executables to use those in COQ-BIN-DIR."
  (interactive
   (list (cdr (assoc (completing-read "Compiler: " coq-bin-dirs-alist)
                     coq-bin-dirs-alist))))
  (when (stringp coq-bin-dir)
    (let ((v (coq-version nil)))
      (setq coq-compiler (concat coq-bin-dir "/coqc"))
      (setq coq-prog-name (concat coq-bin-dir "/coqtop"))
      (setq proof-prog-name coq-prog-name)
      (setq coq-dependency-analyzer (concat coq-bin-dir "/coqdep"))
      (setq coq-autodetected-version nil)
      (coq-autodetect-version)
      (message "Using Coq binaries from %s." coq-bin-dir)
      (let ((v2 (coq-version nil)))
        (unless (equal v v2)
          (when (proof-shell-available-p)
            (proof-shell-exit)))))))
