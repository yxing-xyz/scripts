;; init-check.el --- Initialize check configurations.	-*- lexical-binding: t -*-

;;; Code:

(use-package flymake
  :diminish
  :functions my-elisp-flymake-byte-compile
  :bind ("C-c f" . flymake-show-buffer-diagnostics)
  :hook (prog-mode . flymake-mode)
  :init (setq flymake-no-changes-timeout nil
              flymake-fringe-indicator-position 'right-fringe)
  :config
  ;; Check elisp with `load-path'
  (defun my-elisp-flymake-byte-compile (fn &rest args)
    "Wrapper for `elisp-flymake-byte-compile'."
    (let ((elisp-flymake-byte-compile-load-path
           (append elisp-flymake-byte-compile-load-path load-path)))
      (apply fn args)))
  (advice-add 'elisp-flymake-byte-compile :around #'my-elisp-flymake-byte-compile))

(use-package flymake-popon
  :diminish
  :custom-face
  (flymake-popon-posframe-border ((t :foreground ,(face-background 'region))))
  :hook (flymake-mode . flymake-popon-mode)
  :init (setq flymake-popon-width 70
              flymake-popon-posframe-border-width 1
              flymake-popon-method 'popon))


(provide 'init-check)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-check.el ends here
