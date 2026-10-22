;; init-web.el --- Initialize web configurations.	-*- lexical-binding: t -*-

;;; Commentary:
;;
;; Web configurations.
;;

;;; Code:

(eval-when-compile
  (require 'init-custom))

;; eww
(use-package eww
  :init
  ;; Install: npm install -g readability-cli
  (when (executable-find "readable")
    (setq eww-retrieve-command '("readable"))))

;; Webkit browser
(use-package xwidget
  :ensure nil
  :if (featurep 'xwidget-internal)
  :bind (("C-c C-z w" . xwidget-webkit-browse-url)
         :map xwidget-webkit-mode-map
         ("h"         . xwidget-hydra/body))
  :pretty-hydra
  ((:title (pretty-hydra-title "Webkit" 'faicon "nf-fa-chrome" :face 'nerd-icons-blue)
    :color amaranth :quit-key ("q" "C-g"))
   ("Navigate"
    (("b" xwidget-webkit-back "back")
     ("f" xwidget-webkit-forward "forward")
     ("r" xwidget-webkit-reload "refresh")
     ("SPC" xwidget-webkit-scroll-up "scroll up")
     ("DEL" xwidget-webkit-scroll-down "scroll down")
     ("S-SPC" xwidget-webkit-scroll-down "scroll down"))
    "Zoom"
    (("+" xwidget-webkit-zoom-in "zoom in")
     ("=" xwidget-webkit-zoom-in "zoom in")
     ("-" xwidget-webkit-zoom-out "zoom out"))
    "Misc"
    (("g" xwidget-webkit-browse-url "browse url" :exit t)
     ("u" xwidget-webkit-current-url "show url" :exit t)
     ("v" xwwp-follow-link "follow link" :exit t)
     ("w" xwidget-webkit-current-url-message-kill "copy url" :exit t)
     ("?" describe-mode "help" :exit t)
     ("Q" quit-window "quit" :exit t)))))

;; CSS
(use-package css-mode
  :init (setq css-indent-offset 2))

;; SCSS
(use-package scss-mode
  :init (setq scss-compile-at-save nil))

;; LESS
(unless (fboundp 'less-css-mode)
  (use-package less-css-mode))

;; JavaScript
(use-package js
  :init (setq js-indent-level 2))

;; JSON
(unless (fboundp 'js-json-mode)
  (use-package json-mode))

;; Major mode for CoffeeScript code
(use-package coffee-mode
  :config (setq coffee-tab-width 2))

;; Major mode for editing web templates
(use-package web-mode
  :mode "\\.\\(phtml\\|php\\|[gj]sp\\|as[cp]x\\|erb\\|djhtml\\|html?\\|\
hbs\\|ejs\\|jade\\|swig\\|tm?pl\\|vue\\)$"
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

;; Adds node_modules/.bin directory to `exec_path'
(use-package add-node-modules-path
  :hook ((web-mode js-base-mode) . add-node-modules-path))

(use-package haml-mode)
(use-package php-mode)

;; REST
(use-package restclient
  :mode ("\\.http\\'" . restclient-mode))

(provide 'init-web)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-web.el ends here
