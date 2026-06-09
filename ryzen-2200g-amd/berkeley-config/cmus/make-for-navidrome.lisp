#!/usr/local/bin/lispscript

(defvar /all-playlists/ (ls "/home/tony/cmus/playlists/"))

(defvar /dest-base/ "/home/tony/music/_PLAYLISTS/")


(for-each /all-playlists/
  ; (progress-bar index! (length /all-playlists/))
  (let* ((tmp (-path value! #P"/home/tony/cmus/playlists/"))
         (dest (fn "~A~A.m3u" /dest-base/ tmp)))
    (with-a-file dest :w
      (for-each value!
        (let ((xlation (substr value! 6)))
          (format stream! "~A~%" xlation))))))

