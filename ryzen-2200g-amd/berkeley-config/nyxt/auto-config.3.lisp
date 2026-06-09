(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/no-script:no-script-mode %slot-value%))))

(define-configuration (web-buffer)
  ((default-modes
    (remove-if
     (lambda (nyxt::m) (string= (symbol-name nyxt::m) "NO-SCRIPT-MODE"))
     %slot-value%))))

(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/no-script:no-script-mode %slot-value%))))

(define-configuration (web-buffer)
  ((default-modes
    (pushnew 'nyxt/mode/reduce-tracking:reduce-tracking-mode %slot-value%))))

(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/blocker:blocker-mode %slot-value%))))

(define-configuration browser
  ((theme theme:+dark-theme+)))

(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/style:dark-mode %slot-value%))))

(define-configuration browser
  ((theme (make-instance 'theme:theme
                         :dark-p t
                         :background-color "black"
                         :on-background-color "white"
                         :primary-color "rgb(170, 170, 170)"
                         :on-primary-color "black"
                         :secondary-color "rgb(100, 100, 100)"
                         :on-secondary-color "white"
                         :accent-color "#37A8E4"
                         :on-accent-color "black"))))
(define-configuration status-buffer
  ((style (str:concat %slot-value%
                      (theme:themed-css (theme *browser*)
                        ;; See the `describe-class' of `status-buffer' to
                        ;; understand what to customize
                        '("#controls"
                          :display "none"))))))
(define-mode my-mode ()
  "A mode with its own style, that ideally should pick the user-chosen theme."
  ...
  ((style (lass:compile-and-write
           '("h1"
             :color "black"
             :background-color "white")
           ...)))
  ...)
(define-mode my-mode ()
  "A dynamically themable mode."
  ...
  ;; theme:themed-css uses the current theme for colors.
  ((style (theme:themed-css (theme *browser*)
            ;; Notice that you need less parentheses here.
            ("h1"
             ;; The colors like theme:(on-)background,
             ;; theme:(on-)accent, theme:(on-)primary are provided by
             ;; theme:themed-css.
             :color theme:on-background
             :background-color theme:background))))
  ...)
(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/style:dark-mode %slot-value%))))
