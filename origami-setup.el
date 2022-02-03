;;; origami-parsers.el --- Collection of parsers  -*- lexical-binding: t -*-

;;; contents

;; (defun origami-c-style-parser (create)
;;   (lambda (content)
;;     (let ((positions (->> (origami-get-positions content "[{}]")
;;                           (remove-if (lambda (position)
;;                                        (let ((face (get-text-property 0 'face (car position))))
;;                                          (-any? (lambda (f)
;;                                                   (memq f '(font-lock-doc-face
;;                                                             font-lock-comment-face
;;                                                             font-lock-string-face)))
;;                                                 (if (listp face) face (list face)))))))))
;;       (origami-build-pair-tree create "{" "}" positions))))

;; (defun origami-c-macro-parser (create)
;;   (lambda (content)
;;     (let ((positions (origami-get-positions content "#if\\|#endif")))
;;       (origami-build-pair-tree create "#if" "#endif" positions))))

;; (defun origami-c-parser (create)
;;   (let ((c-style (origami-c-style-parser create))
;;         (macros (origami-c-macro-parser create)))
;;     (lambda (content)
;;       (origami-fold-children
;;        (origami-fold-shallow-merge
;;         (origami-fold-root-node (funcall c-style content))
;;         (origami-fold-root-node (funcall macros content)))))))

;; (defun origami-java-parser (create)
;;   (let ((c-style (origami-c-style-parser create))
;;         (javadoc (origami-javadoc-parser create)))
;;     (lambda (content)
;;       (origami-fold-children
;;        (origami-fold-shallow-merge
;;         (origami-fold-root-node (funcall c-style content))
;;         (origami-fold-root-node (funcall javadoc content)))))))

(defun origami-lean-decl-parser (create)
  (lambda (content)
    (let ((positions (origami-get-positions content "def\\|lemma\\|theorem\\|begin\\|end\\|axiom\\|constant\\|variable\\|variables\\|parameter\\|parameters")))
      (origami-build-pair-tree create "def\\|lemma\\|theorem\\|begin" "def\\|lemma\\|theorem\\|axiom\\|constant\\|variable\\|variables\\|parameter\\|parameters\\|end" positions))))

(defun origami-lean-section-parser (create)
  (lambda (content)
    (let ((positions (origami-get-positions content "section\\|namespace\\|end")))
      (origami-build-pair-tree create "section\\|namespace" "end" positions))))

(defun origami-lean-parser (create)
  (let ((lean-decl (origami-lean-decl-parser create))
        (lean-section (origami-lean-section-parser create)))
    (lambda (content)
      (origami-fold-children
       (origami-fold-shallow-merge
        (origami-fold-root-node (funcall lean-decl content))
        (origami-fold-root-node (funcall lean-section content)))))))

;; (unload-feature 'origami t)
;; (use-package origami
;;   :ensure t
;;   :config
;;   (add-to-list 'origami-parser-alist '(lean-mode . origami-lean-parser)))
