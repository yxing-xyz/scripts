;; init-lsp.el --- Initialize LSP configurations.	-*- lexical-binding: t -*-

;;; Code:

(eval-when-compile
  (require 'init-custom))

(use-package eglot
  :hook ((prog-mode . (lambda ()
                        (unless (derived-mode-p 'emacs-lisp-mode 'lisp-mode 'makefile-mode 'snippet-mode)
                          (eglot-ensure))))
         ((markdown-mode yaml-mode yaml-ts-mode) . eglot-ensure))
  :init
  (setq read-process-output-max (* 1024 1024)) ; 1MB
  (setq eglot-autoshutdown t
        eglot-events-buffer-size 0
        eglot-send-changes-idle-time 0.5)
  :config
  (use-package consult-eglot
    :after consult eglot
    :bind (:map eglot-mode-map
           ("C-M-." . consult-eglot-symbols)))


  ;; Emacs LSP booster
  (use-package eglot-booster
    :when (and emacs/>=29p (executable-find "emacs-lsp-booster"))
    :ensure nil
    :init (unless (package-installed-p 'eglot-booster)
            (package-vc-install "https://github.com/jdtsmith/eglot-booster"))
    :hook (after-init . eglot-booster-mode)))

(defun xx-eglot-organize-imports () (interactive)
	   (eglot-code-actions nil nil "source.organizeImports" t))
(add-hook 'before-save-hook 'xx-eglot-organize-imports)
(add-hook 'before-save-hook 'eglot-format-buffer)


(provide 'init-lsp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-lsp.el ends here
