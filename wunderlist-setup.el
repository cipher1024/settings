(require 'org-wunderlist)
(setq org-wunderlist-client-id "c85de2a54d51a21c6a47"
      org-wunderlist-token "dbf39b9c1610962eac31152d833fa69ecb99c65279bf176741af4f9dc21e"
      org-wunderlist-file  "~/.emacs.d/Wunderlist.org"
      org-wunderlist-dir "~/.emacs.d/org-wunderlist/")

; (org-wunderlist-fetch)
; (org-wunderlist-post)
;; Post/edit org block at point to Wunderlist.
;; (org-wunderlist-post-all)
;; Post/edit all tasks to Wunderlist. (this command is unstable)
;; (org-wunderlist-post-pos)

; https://www.wunderlist.com/oauth/authorize?client_id=c85de2a54d51a21c6a47&redirect_uri=http://www.simonhudon.com&state=050420081615448
; Code: f01213e658de161c29bb
;; curl -H "Content-Type: application/json" -X POST -d '{"client_id":"c85de2a54d51a21c6a47","client_secret":"9d371fbd9374a7c054a0e42309e71813b6084e84b19b88dd28a06f717c0b","code":"f01213e658de161c29bb"}' https://www.wunderlist.com/oauth/access_token
; token: dbf39b9c1610962eac31152d833fa69ecb99c65279bf176741af4f9dc21e
