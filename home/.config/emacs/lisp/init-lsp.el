;; -*- lexical-binding: t -*-


;;; Code:

(eval-when-compile
  (require 'init-const)
  (require 'init-custom))

(use-package eglot
  :hook ((prog-mode . (lambda ()
                        (unless (derived-mode-p
                                 'emacs-lisp-mode 'lisp-mode
                                 'makefile-mode 'snippet-mode
                                 'ron-mode)
                          (eglot-ensure))))
         ((markdown-mode yaml-mode yaml-ts-mode) . eglot-ensure))
  :init (setq eglot-autoshutdown t
              eglot-events-buffer-config '(:size 0 :format 'short)
              eglot-send-changes-idle-time 0.5)
  :config  (add-to-list 'eglot-server-programs
                        '(nix-ts-mode . ("nixd"))))


(use-package consult-eglot
  :after consult eglot
  :bind (:map eglot-mode-map
         ("C-M-." . consult-eglot-symbols)))

(use-package flymake
  :diminish
  :functions my/elisp-flymake-byte-compile
  :bind ("C-c f" . flymake-show-buffer-diagnostics)
  :hook prog-mode
  :custom
  (flymake-no-changes-timeout nil)
  (flymake-fringe-indicator-position 'right-fringe)
  (flymake-margin-indicator-position 'right-margin)
  :config
  ;; Check elisp with `load-path'
  (defun my/elisp-flymake-byte-compile (fn &rest args)
    "Wrapper for `elisp-flymake-byte-compile'."
    (let ((elisp-flymake-byte-compile-load-path
           (append elisp-flymake-byte-compile-load-path load-path)))
      (apply fn args)))
  (advice-add 'elisp-flymake-byte-compile :around #'my/elisp-flymake-byte-compile))

;; Display Flymake errors with overlays
;; (use-package flyover
;;   :diminish
;;   :custom
;;   (flyover-checkers '(flymake))
;;   (flyover-background-lightness 60)
;;   (flyover-icon-background-tint-percent 50)
;;   (flyover-display-mode 'hide-on-same-line)
;;   :hook flymake-mode)

(provide 'init-lsp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-lsp.el ends here
