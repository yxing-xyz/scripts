;; init-shell.el --- 初始化 Shell 配置。 -*- lexical-binding: t -*-

;; ... (此处省略版权声明信息)

;;; Code:

(eval-when-compile
  (require 'init-const)) ; 仅在编译阶段加载常量定义，减少运行负担

(use-package shell
  :ensure nil ; 确保不从包管理器下载，因为 shell 是 Emacs 内置的
  :hook ((shell-mode . my/shell-mode-hook) ; 当进入 shell-mode 时运行自定义钩子
         (comint-output-filter-functions . comint-strip-ctrl-m)) ; 过滤输出中烦人的 ^M (Windows 换行符)
  :init
  (setq system-uses-terminfo nil) ; 告诉 Emacs 不要使用系统的 terminfo，有助于解决某些显示乱码

  (with-no-warnings
    (defun my/shell-simple-send (proc command)
      "在将 COMMAND 发送给 shell 进程 PROC 之前的预处理。"
      (cond
       ;; 如果输入的是 "clear" 命令
       ((string-match "^[ \t]*clear[ \t]*$" command)
        (comint-send-string proc "\n") ; 先发个回车
        (erase-buffer)) ; 然后清空当前的 Emacs Buffer（实现真正的清屏效果）
       ;; 如果输入的是 "man " 命令
       ((string-match "^[ \t]*man[ \t]*" command)
        (comint-send-string proc "\n") ; 发送回车
        (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command)) ; 提取 man 之后的参数
        (setq command (replace-regexp-in-string "[ \t]+$" "" command)) ; 去除末尾空格
        (funcall 'man command)) ; 调用 Emacs 内部的阅读器显示 man page，而不是在终端里看
       ;; 其他命令正常发送
       (t (comint-simple-send proc command))))

    (defun my/shell-mode-hook ()
      "Shell 模式的个性化设置。"
      (local-set-key '[up] 'comint-previous-input) ; 方向键上：调用上一条历史命令
      (local-set-key '[down] 'comint-next-input)   ; 方向键下：调用下一条历史命令
      (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input) ; Shift-Tab：根据当前输入匹配历史

      (ansi-color-for-comint-mode-on) ; 开启基本 ANSI 颜色支持
      (setq comint-input-sender 'my/shell-simple-send)))) ; 指定发送命令的函数为上面自定义的那个

;; ANSI & XTERM 256 颜色深度支持
(use-package xterm-color
  :defines (compilation-environment
            eshell-preoutput-filter-functions
            eshell-output-filter-functions)
  :functions (compilation-filter my/advice-compilation-filter xterm-color-filter)
  :init
  ;; 为普通 Shell 和解释器设置
  (setenv "TERM" "xterm-256color") ; 设置环境变量，告诉程序我支持 256 色
  (setq comint-output-filter-functions
        (remove 'ansi-color-process-output comint-output-filter-functions)) ; 移除默认颜色过滤，改用 xterm-color
  (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter) ; 使用更强大的 xterm-color 处理器
  (add-hook 'shell-mode-hook
            (lambda ()
              (font-lock-mode -1) ; 关闭语法高亮以提升性能，因为 shell 输出通常不需要它
              (make-local-variable 'font-lock-function) ; 准备局部化变量
              (setq font-lock-function #'ignore))) ; 彻底禁止重新开启语法高亮

  ;; 为 Eshell（Emacs 内部实现的 Shell）设置
  (with-eval-after-load 'esh-mode
    (add-hook 'eshell-before-prompt-hook
              (lambda ()
                (setq xterm-color-preserve-properties t))) ; 在 prompt 之前保留颜色属性
    (add-to-list 'eshell-preoutput-filter-functions 'xterm-color-filter) ; eshell 也用 xterm-color 渲染
    (setq eshell-output-filter-functions
          (remove 'eshell-handle-ansi-color eshell-output-filter-functions))) ; 移除默认处理函数

  ;; 为编译 (compilation) 缓冲区设置（让 compile 结果带颜色）
  (setq compilation-environment '("TERM=xterm-256color"))
  (defun my/advice-compilation-filter (fn proc string)
    (funcall fn proc
             (if (eq major-mode 'rg-mode) ; 如果是 rg (ripgrep) 模式，保持原样（兼容性）
                 string
               (xterm-color-filter string)))) ; 其他编译输出通过 xterm-color 过滤颜色码
  (advice-add 'compilation-filter :around #'my/advice-compilation-filter) ; 拦截编译过滤函数
  (advice-add 'gud-filter :around #'my/advice-compilation-filter)) ; 拦截 GDB 调试过滤函数

;; 更强的终端模拟器 (Eat)
(unless sys/win32p ; 仅在非 Windows 下使用（eat 对类 Unix 支持更好）
  (use-package eat
    :hook ((eshell-load . eat-eshell-mode) ; 在 eshell 加载时启用 eat 集成
           (eshell-load . eat-eshell-visual-command-mode)))) ; 像 top 这种视觉命令会自动处理
(provide 'init-shell) ; 声明包名

;;; init-shell.el 到此结束
