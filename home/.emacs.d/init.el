;;; init.el --- init.el -*- lexical-binding: t no-byte-compile: t -*-
;;; Code

(when (version< emacs-version "28.2")
  (error "This requires Emacs 28.2 and above!"))

(setq gc-cons-threshold most-positive-fixnum)

(setq-default mode-line-format nil)

(setq auto-mode-case-fold nil)


(unless (or (daemonp) noninteractive init-file-debug)
  ;; Suppress file handlers operations at startup
  ;; `file-name-handler-alist' is consulted on each call to `require' and `load'
  (let ((old-value file-name-handler-alist))
    (setq file-name-handler-alist nil)
    (set-default-toplevel-value 'file-name-handler-alist file-name-handler-alist)
    (add-hook 'emacs-startup-hook
              (lambda ()
                "Recover file name handlers."
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist old-value))))
              101)))

;; Load path
;; Optimize: Force "lisp"" and "site-lisp" at the head to reduce the startup time.
(defun update-load-path (&rest _)
  "Update `load-path'."
  (dolist (dir '("site-lisp" "lisp"))
    (push (expand-file-name dir user-emacs-directory) load-path)))

(defun add-subdirs-to-load-path (&rest _)
  "Add subdirectories to `load-path'.

Don't put large files in `site-lisp' directory, e.g. EAF.
Otherwise the startup will be very slow."
  (let ((default-directory (expand-file-name "site-lisp" user-emacs-directory)))
    (normal-top-level-add-subdirs-to-load-path)))

(advice-add #'package-initialize :after #'update-load-path)
(advice-add #'package-initialize :after #'add-subdirs-to-load-path)

(update-load-path)

(defun add-binary-path (path)
  "Add a binary PATH to `exec-path' and the PATH environment variable."
  (let ((full-path (format ":%s/%s" (getenv "HOME") path)))
    ;; Add to `exec-path'
    (add-to-list 'exec-path full-path t) ;; Use `t' for appending, to avoid duplicates
    ;; Add to PATH environment variable
    (setenv "PATH" (concat (file-name-as-directory (getenv "PATH")) full-path))))

;; Add Cargo bin path
(add-binary-path ".cargo/bin")
;; Add Go bin path
(add-binary-path "go/bin")

;; requisites
(require 'init-const)
(require 'init-custom)
(require 'init-funcs)

(require 'init-package)
;;
(require 'init-base)
(require 'init-hydra)

(require 'init-ui)
(require 'init-edit)
(require 'init-completion)
(require 'init-snippet)


(require 'init-highlight)
(require 'init-dired)
(require 'init-ibuffer)
(require 'init-window)
(require 'init-treemacs)
(require 'init-kill-ring)
(require 'init-workspace)
(require 'init-calendar)
(require 'init-dict)
(require 'init-bookmark)

(require 'init-eshell)
(require 'init-shell)

(require 'init-utils)


;; program
(require 'init-vcs)
(require 'init-check)
(require 'init-lsp)
(require 'init-dap)

(require 'init-prog)
(require 'init-elisp)
(require 'init-c)
(require 'init-go)
(require 'init-rust)
(require 'init-web)
