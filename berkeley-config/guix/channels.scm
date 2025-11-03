(use-modules (guix ci))

;; Define the list of channels
(list
;  (channel-with-substitutes-available
 ;  %default-guix-channel
 ;  "https://ci.guix.gnu.org")
  
 ; (channel
 ;  (name 'guix)
 ;  (url "https://git.savannah.gnu.org/git/guix.git")
 ;  (branch "master")
 ;  (commit "17119f1a35b7bff683f2f8f2b5db09b4634283e6")
 ;  (introduction
 ;   (make-channel-introduction
 ;    "9edb3f66fd807b096b48283debdcddccfea34bad"
 ;    (openpgp-fingerprint
 ;     "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
 ;(channel
 ;      (name 'guix)
 ;      (url "https://codeberg.org/guix/guix.git")
 ;      (branch "master")
 ;      (commit "4fd32c00abb59b0f275a93c3fef35d5193adbe7a")
 ;      (introduction
 ;       (make-channel-introduction
 ;        "9edb3f66fd807b096b48283debdcddccfea34bad"
 ;        (openpgp-fingerprint
 ;         "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA"))))
 
 (channel
    (name 'debdistutils)
    (url "https://gitlab.com/debdistutils/guix/mirror.git")
    (branch "master"))

     (channel
       (name 'guix-north-america)
       (url "https://git.genenetwork.org/guix-north-america/")
       (branch "master")
       (introduction
        (make-channel-introduction
         "c0979ad86fdf0b403c60d5767328cb862ecc00ef"
         (openpgp-fingerprint
          "F8D5 46F3 AF37 EF53 D1B6 48BE 7B4D EB93 212B 3022"))))

  (channel
   (name 'nonguix)
   (url "https://gitlab.com/nonguix/nonguix")
   (introduction
    (make-channel-introduction
     "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
     (openpgp-fingerprint
      "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
  
  (channel
   (name 'rde)
   (url "https://git.sr.ht/~abcdw/rde")
   (introduction
    (make-channel-introduction
     "257cebd587b66e4d865b3537a9a88cccd7107c95"
     (openpgp-fingerprint
      "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))
  
  (channel
   (name 'radix)
   (url "https://codeberg.org/anemofilia/radix.git")
   (branch "main")
   (introduction
    (make-channel-introduction
     "f9130e11e35d2c147c6764ef85542dc58dc09c4f"
     (openpgp-fingerprint
      "F164 709E 5FC7 B32B AEC7  9F37 1F2E 76AC E3F5 31C8"))))
  
  (channel
   (name 'ajattix)
   (url "https://git.ajattix.org/hashirama/ajattix.git")
   (branch "main")
   (introduction
    (make-channel-introduction
     "5f1904f1a514b89b2d614300d8048577aa717617"
     (openpgp-fingerprint
      "F164 709E 5FC7 B32B AEC7  9F37 1F2E 76AC E3F5 31C8"))))
  
  (channel
   (name 'rosenthal)
   (url "https://codeberg.org/hako/rosenthal.git")
   (branch "trunk")
   (introduction
    (make-channel-introduction
     "7677db76330121a901604dfbad19077893865f35"
     (openpgp-fingerprint
      "13E7 6CD6 E649 C28C 3385  4DF5 5E5A A665 6149 17F7"))))
  
  (channel
   (name 'guix-hpc)
   (url "https://gitlab.inria.fr/guix-hpc/guix-hpc.git")
   (branch "master"))
  
(channel
        (name 'small-guix)
        (url "https://codeberg.org/fishinthecalculator/small-guix.git")
        (branch "main")
        ;; Enable signature verification:
        (introduction
         (make-channel-introduction
          "f260da13666cd41ae3202270784e61e062a3999c"
          (openpgp-fingerprint
           "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))  

  (channel
    (name 'guix-xlibre)
    (url "https://gitlab.vulnix.sh/spacecadet/guix-xlibre.git")
    (branch "master"))

  (channel
   (name 'saayix)
   (branch "main")
   (url "https://codeberg.org/look/saayix")
   (introduction
    (make-channel-introduction
     "12540f593092e9a177eb8a974a57bb4892327752"
     (openpgp-fingerprint
      "3FFA 7335 973E 0A49 47FC  0A8C 38D5 96BE 07D3 34AB")))))
 
