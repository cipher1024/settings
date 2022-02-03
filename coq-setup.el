;; (load "~/.emacs.d/lisp/PG/generic/proof-site")

(use-package proof-general
  :mode ("\\.v\\'" . coq-mode)
  :ensure t
  ;; :config
  ;; (setq coq-prog-args '(
  ;;                       "-R" "/Users/simon/lean/VST/compcert" "-as" "compcert"
  ;;                       "-R" "/Users/simon/lean/VST/msl" "-as" "msl"
  ;;                       "-R" "/Users/simon/lean/VST/veric" "-as" "veric"
  ;;                       "-R" "/Users/simon/lean/VST/floyd" "-as" "floyd"
  ;;                       "-R" "/Users/simon/lean/VST/progs" "-as" "progs"
  ;;                       "-R" "/Users/simon/lean/VST/sepcomp" "-as" "sepcomp"
  ;;                       "-emacs"
  ;;                       )))
  :init (call-process "sh" nil nil "~/.opam/opam-init/init.sh"))
;; (coq-autodetect-version)
;; (call-process "opam" nil nil "switch coq-8.10")
;; (call-process "eval" nil nil "$(opam env)")

(use-package fill-column-indicator
  :ensure t)
;; (unload-feature 'company-coq t)
;; (unload-feature 'coq-mode t)
(use-package company-coq
  :ensure t
  :after proof-general
  :config
  (add-hook
    'coq-mode-hook
    (lambda ()
      ;; (fci-mode)
      ;; (company-mode)
      ;; (company-coq-mode)
      ;; (company-coq-initialize)
      ;; (set-fill-column 120)
      ;; (company-coq-features/prettify-symbols 0)
      (prettify-symbols-mode)
      ;; (setq coq-compile-before-require t)
      (setq coq-one-command-per-line nil)
      ;; (when (bound-and-true-p whitespace-mode)
      ;;   ;; (whitespace-mode)
      ;;   (whitespace-turn-off)
      ;;   )
      (whitespace-turn-off)
      ))
  (add-hook 'coq-mode-hook
          (lambda ()
            (setq-local prettify-symbols-alist
                        '((":=" . ?≜)
                          ;; ("Proof." . ?∵) ("Qed." . ?■)
                          ;; ("Defined." . ?□) ("Time" . ?⏱) ("Admitted." . ?😱)
                          ("Alpha" . ?Α) ("Beta" . ?Β) ("Gamma" . ?Γ)
                          ("Delta" . ?Δ) ("Epsilon" . ?Ε) ("Zeta" . ?Ζ)
                          ("Eta" . ?Η) ("Theta" . ?Θ) ("Iota" . ?Ι)
                          ("Kappa" . ?Κ) ("Lambda" . ?Λ) ("Mu" . ?Μ)
                          ("Nu" . ?Ν) ("Xi" . ?Ξ) ("Omicron" . ?Ο)
                          ("Pi" . ?Π) ("Rho" . ?Ρ) ("Sigma" . ?Σ)
                          ("Tau" . ?Τ) ("Upsilon" . ?Υ) ("Phi" . ?Φ)
                          ("Chi" . ?Χ) ("Psi" . ?Ψ) ("Omega" . ?Ω)
                          ("alpha" . ?α) ("beta" . ?β) ("gamma" . ?γ)
                          ("delta" . ?δ) ("epsilon" . ?ε) ("zeta" . ?ζ)
                          ("eta" . ?η) ("theta" . ?θ) ("iota" . ?ι)
                          ("kappa" . ?κ) ("lambda" . ?λ) ("mu" . ?μ)
                          ("nu" . ?ν) ("xi" . ?ξ) ("omicron" . ?ο)
                          ("pi" . ?π) ("rho" . ?ρ) ("sigma" . ?σ)
                          ("tau" . ?τ) ("upsilon" . ?υ) ("phi" . ?φ)
                          ("chi" . ?χ) ("psi" . ?ψ) ("omega" . ?ω)))))
)

;; project-eshell
(setq proof-three-window-mode-policy 'hybrid)

;VST coqpaths
;; (custom-set-variables '(coq-prog-args '(
;; "-R" "/Users/simon/lean/VST/compcert" "-as" "compcert"
;; "-R" "/Users/simon/lean/VST/msl" "-as" "msl"
;; "-R" "/Users/simon/lean/VST/veric" "-as" "veric"
;; "-R" "/Users/simon/lean/VST/floyd" "-as" "floyd"
;; "-R" "/Users/simon/lean/VST/progs" "-as" "progs"
;; "-R" "/Users/simon/lean/VST/sepcomp" "-as" "sepcomp"
;; "-emacs"
;; )))

;; (setq coq-load-path '(("/Users/simon/lean/VST/compcert" "compcert")
;;                   ("/Users/simon/lean/VST/msl" "msl")
;;                   ("/Users/simon/lean/VST/veric" "veric")
;;                   ("/Users/simon/lean/VST/floyd" "floyd")
;;                   ("/Users/simon/lean/VST/progs" "progs")
;;                   ("/Users/simon/lean/VST/sepcomp" "sepcomp") ))

;; Iris
;; Input of unicode symbols
(require 'math-symbol-lists)
; Automatically use math input method for Coq files
(add-hook 'coq-mode-hook (lambda () (set-input-method "math")))
(add-hook 'coq-mode-hook (yas-minor-mode))
(add-hook 'coq-mode-hook (company-coq-mode))
; Input method for the minibuffer
(defun my-inherit-input-method ()
  "Inherit input method from `minibuffer-selected-window'."
  (let* ((win (minibuffer-selected-window))
         (buf (and win (window-buffer win))))
    (when buf
      (activate-input-method (buffer-local-value 'current-input-method buf)))))
(add-hook 'minibuffer-setup-hook #'my-inherit-input-method)
; Define the actual input method
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
 ("\\latert" ?▶)
 ("\\update" ?⇝)

 ;; accents (for iLöb)
 ("\\\"o" ?ö)

 ;; subscripts and superscripts
 ("^^+" ?⁺) ("__+" ?₊) ("^^-" ?⁻)
 ("__0" ?₀) ("__1" ?₁) ("__2" ?₂) ("__3" ?₃) ("__4" ?₄)
 ("__5" ?₅) ("__6" ?₆) ("__7" ?₇) ("__8" ?₈) ("__9" ?₉)

 ("__a" ?ₐ) ("__e" ?ₑ) ("__h" ?ₕ) ("__i" ?ᵢ) ("__k" ?ₖ)
 ("__l" ?ₗ) ("__m" ?ₘ) ("__n" ?ₙ) ("__o" ?ₒ) ("__p" ?ₚ)
 ("__r" ?ᵣ) ("__s" ?ₛ) ("__t" ?ₜ) ("__u" ?ᵤ) ("__v" ?ᵥ) ("__x" ?ₓ)
)
(mapc (lambda (x)
        (if (cddr x)
            (quail-defrule (cadr x) (car (cddr x)))))
      (append math-symbol-list-basic math-symbol-list-extended))
