;; -*- lexical-binding: t; -*-
;;; Code

(when (version< emacs-version "30.2")
  (error "This requires Emacs 30.2 and above!"))

;;
;; Speed up Startup Process
;;

;; Optimize Garbage Collection for Startup
(setq gc-cons-threshold most-positive-fixnum)

;; Optimize `auto-mode-alist`
(setq auto-mode-case-fold nil)

(unless (or (daemonp) noninteractive init-file-debug)
  ;; Temporarily suppress file-handler processing to speed up startup
  (let ((default-handlers file-name-handler-alist))
    (setq file-name-handler-alist nil)
    ;; Recover handlers after startup
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist default-handlers))))
              101)))

;;
;; Configure Load Path
;;

;; Add "lisp" and "site-lisp" to the beginning of `load-path`
(defun update-load-path (&rest _)
  "Update the `load-path` to prioritize personal configurations."
  (dolist (dir '("site-lisp" "lisp"))
    (push (expand-file-name dir user-emacs-directory) load-path)))

;; Initialize load paths explicitly
(update-load-path)

;; Add subdirectories inside "site-lisp" to `load-path`
(defun add-subdirs-to-load-path (&rest _)
  "Recursively add subdirectories in `site-lisp` to `load-path`.

Avoid placing large files like EAF in `site-lisp` to prevent slow startup."
  (let ((default-directory (expand-file-name "site-lisp" user-emacs-directory)))
    (normal-top-level-add-subdirs-to-load-path)))

;; Ensure these functions are called after `package-initialize`
(advice-add #'package-initialize :after #'add-subdirs-to-load-path)

;; 屏蔽原生编译的异步弹窗（必备）
;; (setq native-comp-async-report-warnings-errors 'silent)
;; 只显示错误，忽略警告（推荐）
;; (setq warning-minimum-level :error)

;; requisites
(require 'init-const)
(require 'init-custom)
(require 'init-funcs)

;; package
(require 'init-package)

;; Preferences
(require 'init-hydra)
(require 'init-base)

(require 'init-ui)
(require 'init-highlight)
(require 'init-edit)
(require 'init-completion)
(require 'init-snippet)

(require 'init-bookmark)
(require 'init-dired)
(require 'init-ibuffer)
(require 'init-workspace)
(require 'init-treemacs)
(require 'init-dict)


;; Programming
(require 'init-vcs)
(require 'init-prog)
(require 'init-lsp)
(require 'init-elisp)
(require 'init-go)
(require 'init-rust)
(require 'init-c)
