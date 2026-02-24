;; init-go.el --- Initialize Golang configurations.	-*- lexical-binding: t -*-
;;; Commentary:
;;
;; Golang configurations.
;;

;;; Code:

(eval-when-compile
  (require 'init-custom))

;; Install tools
(defvar go-tools
  '("golang.org/x/tools/gopls"
    "golang.org/x/tools/cmd/goimports"
    "honnef.co/go/tools/cmd/staticcheck"
    "github.com/go-delve/delve/cmd/dlv"
    "github.com/zmb3/gogetdoc"
    "github.com/josharian/impl"
    "github.com/cweill/gotests/..."
    "github.com/fatih/gomodifytags"
    "github.com/davidrjenni/reftools/cmd/fillstruct")
  "All necessary go tools.")

(defun go-install-tools ()
  "Install or update go tools."
  (interactive)
  (unless (executable-find "go")
    (user-error "Unable to find `go' in `exec-path'!"))

  (message "Installing go tools...")
  (dolist (pkg go-tools)
    (set-process-sentinel
     (start-process "go-tools" "*Go Tools*" "go" "install" "-v" "-x" (concat pkg "@latest"))
     (lambda (proc _)
       (let ((status (process-exit-status proc)))
         (if (= 0 status)
             (message "Installed %s" pkg)
           (message "Failed to install %s: %d" pkg status)))))))

;; Configure Golang automatically
(defvar go-keymap  'go-ts-mode-map "The keymap for Golang.")

(defun go-auto-config ()
  "Configure Golang automatically."
  ;; Env vars
  (with-eval-after-load 'exec-path-from-shell
    (exec-path-from-shell-copy-envs '("GOPATH" "GO111MODULE" "GOPROXY")))

  ;; Try to install go tools if `gopls' is not found
  (when (and (executable-find "go")
             (not (executable-find "gopls")))
    (go-install-tools))

  ;; Misc. tools
  (use-package go-fill-struct)

  (use-package go-gen-test
    :bind (:map go-keymap
           ("C-c t g" . go-gen-test-dwim)))

  (use-package gotest
    :bind (:map go-keymap
           ("C-c t f" . go-test-current-file)
           ("C-c t t" . go-test-current-test)
           ("C-c t j" . go-test-current-project)
           ("C-c t b" . go-test-current-benchmark)
           ("C-c t c" . go-test-current-coverage)
           ("C-c t x" . go-run))))

;; Golang
(use-package go-ts-mode
  :functions (exec-path-from-shell-copy-envs)
  :mode (("\\.go\\'" . go-ts-mode)
         ("/go\\.mod\\'" . go-mod-ts-mode))
  :custom (go-ts-mode-indent-offset 4)
  :config
  (go-auto-config)

  (use-package gotest-ts
    :hook (go-ts-mode . gotest-ts-setup)))

(provide 'init-go)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-go.el ends here
