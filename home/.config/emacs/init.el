;; -*- lexical-binding: t; -*-
;;; Code

(when (version< emacs-version "30.2")
  (error "This requires Emacs 30.2 and above!"))

;;
;; Speed up Startup Process
;;
(setq auto-mode-case-fold nil)

;; Configure Load Path
;;

;; Add "lisp" and "site-lisp" to the beginning of `load-path`
(defun update-load-path (&rest _)
  "Update the `load-path` to prioritize personal configurations."
  (dolist (dir '("site-lisp" "lisp"))
    (let ((site-lisp-dir (expand-file-name dir user-emacs-directory)))
      (when (file-directory-p site-lisp-dir)
        (add-to-list 'load-path site-lisp-dir)))))

;; Initialize load paths explicitly
(update-load-path)

;; Rescan site-lisp subdirectories after package initialization
(defun add-subdirs-to-load-path (&rest _)
  "Recursively add subdirectories in `site-lisp' to `load-path'.

This runs as :after advice on `package-initialize' so that any
subdirectories added to `site-lisp' during package installation are
picked up automatically. Uses `&rest _' to absorb and ignore the
arguments passed by the advised function.

Avoid placing large projects (e.g., EAF) directly in `site-lisp',
as recursive scanning slows down startup."
  (let ((default-directory (locate-user-emacs-file "site-lisp")))
    (normal-top-level-add-subdirs-to-load-path)))

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
(require 'init-check)

(require 'init-bookmark)
(require 'init-dired)
(require 'init-ibuffer)
(require 'init-workspace)
(require 'init-window)
(require 'init-treemacs)
(require 'init-dict)
(require 'init-utils)
(require 'init-markdown)
(require 'init-shell)
(require 'init-ai)

;; Programming
(require 'init-vc)
(require 'init-prog)
(require 'init-web)
(require 'init-lsp)
(require 'init-elisp)
(require 'init-go)
(require 'init-rust)
(require 'init-c)
(require 'init-nix)
