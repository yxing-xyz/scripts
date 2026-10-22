;; -*- lexical-binding: t; -*-


;;; Code:
(eval-when-compile
  (require 'init-const))

(setq user-full-name xx-full-name
      user-mail-address xx-mail-address)

;; Compatibility
;; 允许你在旧版本的 Emacs 上使用新版本才有的函数和宏
(use-package compat :demand t)

;; 禁止linux X参数
(setq command-line-x-option-alist nil)
;; 彻底禁用 FFAP 对 “远程机器路径” 的识别和处理
(setq ffap-machine-p-known 'reject)

;; gc
(use-package gcmh
  :hook (emacs-startup . gcmh-mode)
  :init (setq gcmh-idle-delay 'auto
              gcmh-auto-idle-delay-factor 10
              gcmh-high-cons-threshold #x4000000)) ; 64MB

;; utf-8
;; Set UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-next-selection-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(setq system-time-locale "C")

;; Environment
(use-package exec-path-from-shell
  :commands exec-path-from-shell-initialize
  :custom (exec-path-from-shell-arguments '("-l"))
  :init (exec-path-from-shell-initialize))

(use-package server
  :hook (emacs-startup . (lambda ()
			               (unless server-mode
                             (server-mode 1)))))

;; Save place
(use-package saveplace
  :hook (after-init . save-place-mode))

;; History
(use-package recentf
  :bind (("C-x C-r" . recentf-open-files))
  :hook (after-init . recentf-mode)
  :init (setq recentf-max-saved-items 300
              recentf-exclude
              '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                "^/tmp/" "^/var/folders/.+$" "^/ssh:" "/persp-confs/"
                (lambda (file) (file-in-directory-p file package-user-dir))))
  :config
  (push (expand-file-name recentf-save-file) recentf-exclude)
  (add-to-list 'recentf-filename-handlers #'abbreviate-file-name))

(use-package savehist
  :hook (after-init . savehist-mode)
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300))

(use-package simple
  :ensure nil
  :hook ((after-init . size-indication-mode)
         ;; (text-mode . visual-line-mode) 取消自动换行显示
         ((prog-mode markdown-mode markdown-ts-mode conf-mode) . enable-trailing-whitespace))
  :init
  (setq column-number-mode t
        line-number-mode t
        kill-whole-line t               ; Kill line including '\n'
        line-move-visual nil
        track-eol t                     ; Keep cursor at end of lines. Require line-move-visual is nil.
        set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

  ;; Visualize TAB, (HARD) SPACE, NEWLINE
  (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
  (defun enable-trailing-whitespace ()
    "Show trailing spaces and delete on saving."
    (setq show-trailing-whitespace t)
    (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

  ;; Prettify the process list
  (with-no-warnings
    (defun my/list-processes--prettify ()
      "Prettify process list."
      (when-let* ((entries tabulated-list-entries))
        (setq tabulated-list-entries nil)
        (dolist (p (process-list))
          (when-let* ((val (cadr (assoc p entries)))
                      (name (aref val 0))
                      (pid (aref val 1))
                      (status (aref val 2))
                      (status (list status
                                    'face
                                    (if (memq status '(stop exit closed failed))
                                        'error
                                      'success)))
                      (buf-label (aref val 3))
                      (tty (list (aref val 4) 'face 'font-lock-doc-face))
                      (thread (list (aref val 5) 'face 'font-lock-doc-face))
                      (cmd (list (aref val 6) 'face 'completions-annotations)))
            (push (list p (vector name pid status buf-label tty thread cmd))
		          tabulated-list-entries)))))
    (advice-add #'list-processes--refresh :after #'my/list-processes--prettify)))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  (text-mode-ispell-word-completion nil)

  ;; Emacs 28 and newer: Hide commands in M-x which do not apply to the current
  ;; mode.  Corfu commands are hidden, since they are not used via M-x. This
  ;; setting is useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p)
  (vc-follow-symlinks t))


(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))
(setq-default major-mode 'text-mode
              fill-column 100
              tab-width 4
              truncate-lines t ;; 禁止自动换行
              cursor-type 'box ;; 实心光标
              indent-tabs-mode nil)     ; Permanently indent with spaces, never with TABs
(blink-cursor-mode 1) ;; 光标闪烁
(setq blink-cursor-interval 0.5) ; 闪烁频率
(setq blink-cursor-delay 0.2)    ; 停止输入后多久开始闪烁

(setq visible-bell t
      inhibit-compacting-font-caches t  ; Don’t compact font caches during GC
      delete-by-moving-to-trash t       ; Deleting files go to OS's trash folder
      make-backup-files nil             ; Forbide to make backup files
      auto-save-default nil             ; Disable auto save

      uniquify-buffer-name-style 'post-forward-angle-brackets ; Show path if names are same
      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
      sentence-end-double-space nil
      word-wrap-by-category t)

;; (defface posframe-border
;;   `((t (:inherit region)))
;;   "Face used by the `posframe' border."
;;   :group 'posframe)
;; (defvar posframe-border-width 2
;;   "Default posframe border width.")


;; =============================================================================
;; Frame 窗口（框架）相关配置
;; =============================================================================

;; 窗口全屏快捷键绑定
;; S-s-<return>：Shift + s + 回车 切换全屏
(bind-key "S-s-<return>" #'toggle-frame-fullscreen)
;; Mac 平台额外绑定 C-s-f（Command+Shift+F，贴合Mac原生全屏习惯）
(when sys/macp
  (bind-key "C-s-f" #'toggle-frame-fullscreen))


;; 窗口透明度配置，使用 transwin 包
(use-package transwin
  :bind (("C-M-9" . transwin-inc)   ; Ctrl+Alt+9：增加透明度（更透明）
         ("C-M-8" . transwin-dec)   ; Ctrl+Alt+8：降低透明度（更实）
         ("C-M-7" . transwin-toggle)) ; Ctrl+Alt+7：切换透明/不透明
  :init
  ;; Linux 平台使用 alpha-background 参数控制透明度（X11/Wayland 下标准参数）
  (when sys/linuxp
    (setq transwin-parameter-alpha 'alpha-background)))

;; Child frame 子悬浮窗口配置（posframe，用于提示、弹窗、预览等悬浮窗）
(use-package posframe
  :custom-face
  ;; 子窗口边框 face，继承 posframe-border 自定义面
  (child-frame-border ((t (:inherit posframe-border))))
  :hook (after-load-theme . posframe-delete-all) ; 切换主题时关闭所有悬浮窗，防止样式错乱
  :init
  ;; 自定义 posframe 边框的颜色，继承 region（选中区域）的样式
  (defface posframe-border
    `((t (:inherit region)))
    "Face used by the `posframe' border."
    :group 'posframe)
  ;; posframe 默认边框宽度
  (defvar posframe-border-width 2
    "Default posframe border width.")
  :config
  (with-no-warnings
    ;; 给 posframe 创建窗口后加建议：清除侧边 fringe（竖条）背景，悬浮窗更干净
    (defun my/posframe--prettify-frame (&rest _)
      (set-face-background 'fringe nil posframe--frame))
    ;; 给 posframe--create-posframe 函数追加后置钩子，美化悬浮窗
    (advice-add #'posframe--create-posframe :after #'my/posframe--prettify-frame)

    ;; 自定义悬浮窗位置处理器：水平居中，垂直靠下一点（居中偏下）
    ;; info 是 posframe 传入的位置信息 plist，包含父窗口宽高、悬浮窗宽高、字体高度等
    (defun posframe-poshandler-frame-center-near-bottom (info)
      (cons (/ (- (plist-get info :parent-frame-width)
                  (plist-get info :posframe-width))
               2)
            (/ (+ (plist-get info :parent-frame-height)
                  (* 2 (plist-get info :font-height)))
               2)))))


;; Global keybindings
(bind-keys ("s-r"     . revert-buffer-quick)
           ("C-x K"   . delete-this-file)
           ("C-c C-l" . reload-init-file))

;; 重放
(use-package repeat
  :ensure nil
  :hook (after-init . repeat-mode))


;; kill-ring

(setq kill-ring-max 200)

;; Save clipboard contents into kill-ring before replace them
(setq save-interprogram-paste-before-kill t)

;; Kill & Mark things easily
(use-package easy-kill
  :bind (([remap kill-ring-save] . easy-kill)
         ([remap mark-sexp] . easy-mark)))

;; Interactively insert and edit items from kill-ring
(use-package browse-kill-ring
  :bind ("C-c k" . browse-kill-ring)
  :hook (after-init . browse-kill-ring-default-keybindings)
  :init (setq browse-kill-ring-separator "────────────────"
              browse-kill-ring-separator-face 'shadow))
(provide 'init-base)
;;; init-base.el ends here
