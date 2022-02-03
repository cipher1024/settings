
(add-hook 'find-file-not-found-functions 'template-use-local-template)

(defun template-use-local-template ()
  (interactive)
  (use-local-template (buffer-file-name)))

(defun use-local-template (file)
  (let ((template-filename
         (format "%sTEMPLATE.%s.tpl"
                 (file-name-directory file)
                 (file-name-extension file)
                 )))
    (when (file-exists-p template-filename)
      (erase-buffer)
      (insert-file-contents template-filename)
      (replace-string "(>>>FILE_SANS<<<)"
                      (file-name-base file)))))

(find-file-other-window "/Users/simon/Google Stuff/lean/sat/Sat/Advent/Day10.lean")
(delete-file "/Users/simon/Google Stuff/lean/sat/Sat/Advent/Day10.lean")
