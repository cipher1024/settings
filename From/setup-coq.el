
;; (require 'proof-general)
;; (require 'company-coq)
(use-package proof-general
  :ensure t)
(use-package company-coq
  :ensure t)
(setq proof-three-window-mode-policy 'hybrid)
;; load-path
(defun set-exec-path-from-shell-PATH (&optional cmd arg)
  (let ((cmd (cond ((eq cmd 'opam-env) "eval $(opam env); env")
                   ((eq cmd 'opam-switch)
                    (format "eval $(opam env --switch %s --set-switch); env" arg))
                   ((not cmd) "echo $PATH")
                   (t (error (format "wrong command %s" cmd))))))
    ;; (let ((path-from-shell (replace-regexp-in-string
    ;;                         "[ \t\n]*$"
    ;;                         ""
    ;;                         (shell-command-to-string (format "$SHELL --login -i -c '%s'" cmd)))))
    (let ((path-from-shell  (shell-command-to-string (format "$SHELL --login -i -c '%s'" cmd))))
      ;; (setenv "PATH" path-from-shell)
      ;; (setq eshell-path-env path-from-shell) ; for eshell users
      (setq process-environment (split-string path-from-shell "\n"))
      ;; path-from-shell
      )))

(setq proof-splash-enable nil)

(defun coq-move-lines-binding ()
  "Sets the default key binding for moving lines. M-p or M-<up> for moving up
and M-n or M-<down> for moving down."
  (define-key coq-mode-map (kbd "M-<up>") 'move-lines-up)
  (define-key coq-mode-map (kbd "M-<down>") 'move-lines-down))

(after-init
 (coq-move-lines-binding))
;; (defun set-exec-path-from-shell ()
;;     (let ((path-from-shell (replace-regexp-in-string
;;                             "[ \t\n]*$"
;;                             ""
;;                             (shell-command-to-string "$SHELL --login -i -c 'env'"))))
;;       (setenv "PATH" path-from-shell)
;;       (setq eshell-path-env path-from-shell) ; for eshell users
;;       (setq exec-path (split-string path-from-shell path-separator))))

;; (unload-feature 'coq-mode t)
;; (require 'coq-mode)
;; (opam-switch 'iris-transfinite)
;; (getenv)
;;
;; (shell-command-to-string "coqc -v")

(defun set-exec-path-from-shell-PATH (&optional cmd arg)
  (let ((cmd (cond ((eq cmd 'opam-env) "eval $(opam env); echo $PATH")
                   ((eq cmd 'opam-switch) (format "eval $(opam env --set-switch --switch=%s); echo $PATH" arg))
                   ((not cmd) "echo $PATH")
                   (t (error (format "wrong command %s" cmd))))))
    (let ((path-from-shell (replace-regexp-in-string
                            "[ \t\n]*$"
                            ""
                            (shell-command-to-string (format "$SHELL --login -i -c '%s'" cmd)))))
      (setenv "PATH" path-from-shell)
      (setq eshell-path-env path-from-shell) ; for eshell users
      (setq exec-path (split-string path-from-shell path-separator)))))

;; (set-exec-path-from-shell-PATH 'opam-switch 'coq-8.11)
(setq coq-switches '("iris-transfinite" "coq-8.11" "coq-8.12" "coq-8.13" "iris-bounded-buffer"))
(defun coq-switches-menu ()
  (helm-comp-read
   "opam switch "
   (map 'list (lambda (x) (cons (if (symbolp x) (symbol-name x) x) x)) coq-switches)))

(defun opam-switch (switch)
  (interactive (list (coq-switches-menu)))
  (require 'proof-general)
  ;; (require 'company-coq)
  ;; (require 'coq)
  (proofgeneral "coq")
  ;; (let ((switch
  ;;     (if (eq switch 'local) "." switch)))
  (set-exec-path-from-shell-PATH 'opam-switch switch)
  (coq-change-compiler
   (opam-ask-var switch "coq" "bin"))
  )

;; (set-exec-path-from-shell-PATH 'opam-switch "coq-8.12")

(load-file "~/.emacs.d/opam-setup.el")

(defun select-local-opam-switch ()
  (interactive)
  (if-let ((dir (locate-dominating-file "." "_opam")))
      (progn
        (print dir)
        (print (opam-current-switch))
        (opam-switch dir)
        (print (opam-current-switch)))))

(after-init
 (require 'proof-shell)
 (require 'proof-general)
 (proofgeneral "coq")
 (add-to-list 'proof-shell-before-process-hook
              #'select-local-opam-switch)
 (add-to-list 'coq-goals-mode-hook
              #'highlight-symbol-mode)
 (add-to-list 'coq-response-mode-hook
              #'highlight-symbol-mode)
 )

;; (defun opam-switch (switch)
;;   (interactive (list (coq-switches-menu)))
;;   ;; (let ((switch
;;       ;; (if (eq switch 'local) "." switch)))
;;   (coq-change-compiler (opam-ask-var switch "coq" "bin")))
;;     ;; (set-exec-path-from-shell-PATH 'opam-switch switch)))

;; (setq coq-switches opam-switches)

(setq coq-compile-before-require t)
(setq coq-use-project-file t)
;; (coq-load-project-file-rehack)

(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'coq-mode-hook 'company-coq-mode)
(add-hook 'coq-mode-hook 'subword-mode)
(add-hook 'coq-mode-hook
          (lambda () (setq-local obj-file-extension ".vio")))

(require 'math-symbol-lists)
; Automatically use math input method for Coq files
(add-hook 'coq-mode-hook (lambda () (set-input-method "math")))
; Input method for the minibuffer
(defun my-inherit-input-method ()
  "Inherit input method from `minibuffer-selected-window'."
  (let* ((win (minibuffer-selected-window))
         (buf (and win (window-buffer win))))
    (when buf
      (activate-input-method (buffer-local-value 'current-input-method buf)))))

(add-hook 'minibuffer-setup-hook #'my-inherit-input-method)


;; (set-fontset-font t 'unicode (font-spec :name "XITS Math") nil 'prepend)
;; (set-fontset-font t 'greek (font-spec :name "DejaVu sans Mono") nil 'prepend)

;; Fonts
(set-face-attribute 'default nil :height 110) ; height is in 1/10pt
(dolist (ft (fontset-list))
  ; Main font
  (set-fontset-font ft 'unicode (font-spec :name "Monospace"))
  ; Fallback font
  ; Appending to the 'unicode list makes emacs unbearably slow.
  ;(set-fontset-font ft 'unicode (font-spec :name "DejaVu Sans Mono") nil 'append)
  (set-fontset-font ft nil (font-spec :name "DejaVu Sans Mono"))
)
; Fallback-fallback font
; If we 'append this to all fontsets, it picks Symbola even for some cases where DejaVu could
; be used. Adding it only to the "t" table makes it Do The Right Thing (TM).
(set-fontset-font t nil (font-spec :name "Symbola"))


(quail-define-package "math" "UTF-8" "Ω" t)
(quail-define-rules ; add whatever extra rules you want to define here...
 ("\\fun"    ?λ)
 ("\\mult"   ?⋅)
 ("\\ent"    ?⊢)
 ("\\valid"  ?✓)
 ("\\diamond" ?◇)
 ("\\box"    ?□)
 ("\\bbox"   ?■)
 ("\\later"  ?▷)
 ("\\pred"   ?φ)
 ("\\and"    ?∧)
 ("\\or"     ?∨)
 ("\\comp"   ?∘)
 ("\\ccomp"  ?◎)
 ("\\all"    ?∀)
 ("\\ex"     ?∃)
 ("\\to"     ?→)
 ("\\sep"    ?∗)
 ("\\lc"     ?⌜)
 ("\\rc"     ?⌝)
 ("\\Lc"     ?⎡)
 ("\\Rc"     ?⎤)
 ("\\lam"    ?λ)
 ("\\empty"  ?∅)
 ("\\Lam"    ?Λ)
 ("\\Sig"    ?Σ)
 ("\\-"      ?∖)
 ("\\aa"     ?●)
 ("\\af"     ?◯)
 ("\\auth"   ?●)
 ("\\frag"   ?◯)
 ("\\iff"    ?↔)
 ("\\gname"  ?γ)
 ("\\incl"   ?≼)
 ("\\Mapsto" ?⤇)
 ("\\latert" ?▶)
 ("\\update" ?⇝)

 ;; accents (for iLöb)
 ("\\\"o" ?ö)

 ;; subscripts and superscripts
 ("^^0" ?⁰) ("^^1" ?¹) ("^^2" ?²) ("^^3" ?³) ("^^4" ?⁴)
 ("^^5" ?⁵) ("^^6" ?⁶) ("^^7" ?⁷) ("^^8" ?⁸) ("^^9" ?⁹)

 ("^^+" ?⁺) ("__+" ?₊) ("^^-" ?⁻)
 ("__0" ?₀) ("__1" ?₁) ("__2" ?₂) ("__3" ?₃) ("__4" ?₄)
 ("__5" ?₅) ("__6" ?₆) ("__7" ?₇) ("__8" ?₈) ("__9" ?₉)

 ("__a" ?ₐ)
 ("__e" ?ₑ) ("__h" ?ₕ) ("__i" ?ᵢ) ("__k" ?ₖ)
 ("__l" ?ₗ) ("__m" ?ₘ) ("__n" ?ₙ) ("__o" ?ₒ) ("__p" ?ₚ)
 ("__r" ?ᵣ) ("__s" ?ₛ) ("__t" ?ₜ) ("__u" ?ᵤ) ("__v" ?ᵥ) ("__x" ?ₓ)
)
(mapc (lambda (x)
        (if (cddr x)
            (quail-defrule (cadr x) (car (cddr x)))))
      (append math-symbol-list-basic math-symbol-list-extended))

(defun find-makefile ()
  (interactive)
  (let ((root (locate-dominating-file "." "Makefile")))
    (find-file (concat root "Makefile"))))

(defun make-gen-ref ()
  (interactive)
  (make "MAKE_REF=1"))

(defun make-builddep ()
  (interactive)
  (make "builddep"))

(defun make (&optional cmd)
  (interactive
   (with-universal-argument
    nil
    (list (read-string "make option: "))))
  (let ((default-directory (locate-dominating-file "." "Makefile")))
    (compile (format "make -j8 %s" (or cmd "")))))

(defun rooted-file-name (filename)
  (file-relative-name
              filename
              (locate-dominating-file "." "Makefile")))

(defun coq-print-deps ()
  (interactive)
  (let ((rel (rooted-file-name (buffer-file-name)))
        (default-directory
          (locate-dominating-file "." "Makefile")))
    (async-shell-command (format "coqdep -f _CoqProject %s" rel))))

(defun make-clean ()
  (interactive)
  (make "clean"))

(defun make-test ()
  (interactive)
  (make "test"))

(defun make-this-file (&optional cmd)
  (interactive
   (with-universal-argument
    nil
    (list (read-string "make option: "))))
  (if (local-variable-p 'obj-file-extension)
      (let* ((rel (file-relative-name
                   (buffer-file-name)
                   (locate-dominating-file "." "Makefile")))
             (obj (concat (file-name-sans-extension rel)
                          obj-file-extension)))
        (make (concat obj " " (or cmd ""))))
    (error "buffer local variable 'obj-file-extension'")))

(defun find-make-file-aux (f acc)
  (if (file-exists-p "Makefile")
      (funcall f default-directory (mapconcat 'identity acc "/"))
    (let* ((dir (directory-file-name default-directory))
           (current (file-name-nondirectory dir))
           (default-directory (file-name-directory dir)))
      (if (not (equalp dir "/"))
          (find-make-file-aux f (cons current acc))
        )
      )
    )
  )

(defun find-make-file (f &optional fn)
  (if fn
      (find-make-file-aux f (list fn))
    (find-make-file-aux f '())))

(defun coq-compile-file ()
  (interactive)
  (find-make-file
   (lambda (dir fn) (compile (format "make -k %s" fn)))
   (file-name-nondirectory (concat (buffer-file-name) "o")))
  )

(defun coq-make ()
  (interactive)
  (find-make-file
   (lambda (dir fn) (compile "make -k")))
  )

(defun coq-make-clean ()
  (interactive)
  (find-make-file
   (lambda (dir fn) (compile "make -k clean")))
  )



'(

;; (opam-switch)

(let ((read-answer-short '()))
  (let ((read-answer-short t))
    (read-answer "Foo "
                 '(("yes"  ?y "perform the action")
                   ("no"   ?n "skip to the next")
                   ("all"  ?! "perform for the rest without more questions")
                   ("help" ?h "show help")
                   ("quit" ?q "exit")))))


  (equal (helm
          :prompt "foo: "
          :sources
          (helm-build-sync-source "test"
            :candidates
            '(foo foa fob bar baz)))
         "foa")


(setq data '(("John" . "john@email.com")
         ("Jim" . 'jim)
         ("Jane" . "jane@email.com")
         ("Jill" . "jill@email.com")))


 (helm-comp-read "name: " data)


  )
