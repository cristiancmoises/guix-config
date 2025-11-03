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
       (name 'guix)
       (url "https://codeberg.org/guix/guix.git")
       (branch "master")
       (commit "4fd32c00abb59b0f275a93c3fef35d5193adbe7a")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA"))))
  (channel
   (name 'nonguix)
   (url "https://gitlab.com/nonguix/nonguix")
   (introduction
    (make-channel-introduction
     "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
     (openpgp-fingerprint
      "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
