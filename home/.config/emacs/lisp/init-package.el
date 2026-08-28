;; -*- lexical-binding: t; -*-


(defvar use-package-always-ensure)
(defvar use-package-always-defer)
(defvar use-package-expand-minimally)
(defvar use-package-enable-imenu-support)

(declare-function set-package-archives "init-funcs")
(declare-function xx-test-package-archives "init-funcs")

;; Load `custom-file'
(load custom-file 'noerror)

;; Load `custom-post-file After init
(defun load-custom-post-file ()
  "load custom-post file"
  (and (file-exists-p xx-custom-post-file) (load xx-custom-post-file)))
(add-hook 'after-init-hook #'load-custom-post-file)

;; 重写 Emacs 内置的包列表保存函数，核心目的：
;; 1. 不自动将 package-selected-packages 写入 custom.el，保持配置文件干净
;; 2. 确保包列表按字母排序，提升可维护性
;; 3. 避免初始化阶段覆盖手动配置的包列表
(defun my/package--save-selected-packages (&optional value)
  "Set `package-selected-packages' to VALUE but don't save to custom.el."
  (when (or value after-init-time)
    ;; It is valid to set it to nil, for example when the last package
    ;; is uninstalled.  But it shouldn't be done at init time, to
    ;; avoid overwriting configurations that haven't yet been loaded.
    (setq package-selected-packages (sort value #'string<)))
  (unless after-init-time
    (add-hook 'after-init-hook #'my/package--save-selected-packages)))
(advice-add 'package--save-selected-packages :override #'my/package--save-selected-packages)

;; Set ELPA packages
(customize-set-variable 'xx-package-archives xx-package-archives)

;; Initialize packages
(package-initialize)

;; Prettify package list
(set-face-attribute 'package-status-available nil :inherit 'font-lock-string-face)
(set-face-attribute 'package-description nil :inherit 'font-lock-comment-face)

;; Setup `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Should set before loading `use-package'
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-expand-minimally t
      use-package-enable-imenu-support t)

;; Required by `use-package'
(use-package diminish :ensure t)

;; Update GPG keyring for GNU ELPA
(use-package gnu-elpa-keyring-update)

;; Update packages
(unless (fboundp 'package-upgrade-all)
  (use-package auto-package-update
    :autoload auto-package-update-now
    :custom
    (auto-package-update-delete-old-versions t)
    (auto-package-update-hide-results t)
    :init (defalias 'package-upgrade-all #'auto-package-update-now)))

(provide 'init-package)
