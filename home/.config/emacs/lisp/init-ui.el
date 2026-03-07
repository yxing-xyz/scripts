;; -*- lexical-binding: t; -*-


;; --- 性能与显示优化 (Optimization) ---
(setq-default cursor-in-non-selected-windows nil) ; 非当前选中的窗口不显示光标（减少视觉干扰和渲染消耗）
(setq highlight-nonselected-windows nil)          ; 即使窗口未选中，也不高亮其选区（进一步优化渲染性能）

(setq fast-but-imprecise-scrolling t)            ; 开启快速滚动模式：滚动时跳过复杂的中间渲染，虽然不够精确但极其流畅
(setq redisplay-skip-fontification-on-input t)    ; 输入时暂停语法高亮渲染：确保打字时不会因为大文件的语法着色而感到卡顿

;; --- 窗口尺寸控制 (Inhibit resizing frame) ---
(setq frame-inhibit-implied-resize t              ; 禁止某些操作（如字体改变）导致的窗口自动调整大小，防止界面闪烁
      frame-resize-pixelwise t)                   ; 允许以“像素”为单位调整窗口大小，而不是以“字符行列”为单位（实现真正的平滑缩放）

;; --- 启动窗口布局 (Initial frame) ---
;; 设置 Emacs 第一次启动时的窗口参数（alist）
(setq initial-frame-alist '((top . 0.5)           ; 窗口顶部位于屏幕垂直方向 50% 的位置
                            (left . 0.5)          ; 窗口左侧位于屏幕水平方向 50% 的位置
                            (width . 0.7)         ; 窗口宽度占屏幕的 70%
                            (height . 0.85)       ; 窗口高度占屏幕的 85%
                            (fullscreen)))        ; 尝试全屏启动（如果环境支持）


(if (theme-solaire-p xx-theme)
    (progn
      ;; Make certain buffers grossly incandescent
      (use-package solaire-mode
        :functions (theme-solaire-p refresh-ns-appearance)
        :commands solaire-global-mode
        :init (solaire-global-mode 1))

      ;; Excellent themes
      (use-package doom-themes
        :functions xx-apply-theme-logic doom-themes-visual-bell-config
        :init
        (xx-apply-theme-logic xx-theme)
        :config (doom-themes-visual-bell-config)))
  (progn
    (warn "The current theme may be incompatible!")
    (xx-apply-theme-logic xx-theme)))

(use-package doom-modeline
  :custom
  (doom-modeline-minor-modes t)              ;; 默认显示副模式（Minor Modes）
  :hook after-init                            ;; 在 Emacs 初始化完成后启用
  :bind (:map doom-modeline-mode-map          ;; 绑定快捷键到 doom-modeline 映射表中
         ("C-<f6>" . doom-modeline-hydra/body)) ;; 按 Ctrl + F6 呼出 Hydra 配置菜单
  :pretty-hydra
  ((:title (pretty-hydra-title "Mode Line" 'sucicon "nf-custom-emacs" :face 'nerd-icons-purple) ;; 设置 Hydra 标题及图标样式
    :color amaranth :quit-key ("q" "C-g"))    ;; 设置 Hydra 颜色模式（amaranth 表示点击非绑定键不退出）及退出键
   ("Icon" ;; --- 图标相关设置组 ---
    (("i" (setq doom-modeline-icon (not doom-modeline-icon))
      "display icons" :toggle doom-modeline-icon) ;; 切换是否显示所有图标
     ("u" (setq doom-modeline-unicode-fallback (not doom-modeline-unicode-fallback))
      "unicode fallback" :toggle doom-modeline-unicode-fallback) ;; 切换是否使用 Unicode 备选字符
     ("m" (setq doom-modeline-major-mode-icon (not doom-modeline-major-mode-icon))
      "major mode" :toggle doom-modeline-major-mode-icon) ;; 切换是否显示主模式图标
     ("l" (setq doom-modeline-major-mode-color-icon (not doom-modeline-major-mode-color-icon))
      "colorful major mode" :toggle doom-modeline-major-mode-color-icon) ;; 切换主模式图标是否彩色
     ("s" (setq doom-modeline-buffer-state-icon (not doom-modeline-buffer-state-icon))
      "buffer state" :toggle doom-modeline-buffer-state-icon) ;; 切换是否显示缓冲区状态图标（如只读/修改）
     ("o" (setq doom-modeline-buffer-modification-icon (not doom-modeline-buffer-modification-icon))
      "modification" :toggle doom-modeline-buffer-modification-icon) ;; 切换是否显示文件修改标记图标
     ("x" (setq doom-modeline-time-icon (not doom-modeline-time-icon))
      "time" :toggle doom-modeline-time-icon) ;; 切换是否在时间旁边显示图标
     ("v" (setq doom-modeline-modal-icon (not doom-modeline-modal-icon))
      "modal" :toggle doom-modeline-modal-icon)) ;; 切换是否显示模态编辑（如 Evil）状态图标
    "Segment" ;; --- 线段/组件显示设置组 ---
    (("g h" (setq doom-modeline-hud (not doom-modeline-hud))
      "hud" :toggle doom-modeline-hud) ;; 切换是否开启底部 HUD 滚动条效果
     ("g m" (setq doom-modeline-minor-modes (not doom-modeline-minor-modes))
      "minor modes" :toggle doom-modeline-minor-modes) ;; 切换是否显示副模式
     ("g w" (setq doom-modeline-enable-word-count (not doom-modeline-enable-word-count))
      "word count" :toggle doom-modeline-enable-word-count) ;; 切换是否显示字数统计
     ("g e" (setq doom-modeline-buffer-encoding (not doom-modeline-buffer-encoding))
      "encoding" :toggle doom-modeline-buffer-encoding) ;; 切换是否显示文件编码格式（如 UTF-8）
     ("g i" (setq doom-modeline-indent-info (not doom-modeline-indent-info))
      "indent" :toggle doom-modeline-indent-info) ;; 切换是否显示缩进信息（空格/Tab）
     ("g c" (setq doom-modeline-display-misc-in-all-mode-lines (not doom-modeline-display-misc-in-all-mode-lines))
      "misc info" :toggle doom-modeline-display-misc-in-all-mode-lines) ;; 切换是否在所有状态栏显示杂项信息
     ("g l" (setq doom-modeline-lsp (not doom-modeline-lsp))
      "lsp" :toggle doom-modeline-lsp) ;; 切换是否显示 LSP 语言服务器状态
     ("g k" (setq doom-modeline-workspace-name (not doom-modeline-workspace-name))
      "workspace" :toggle doom-modeline-workspace-name) ;; 切换是否显示当前工作区名称
     ("g g" (setq doom-modeline-github (not doom-modeline-github))
      "github" :toggle doom-modeline-github) ;; 切换是否开启 GitHub 通知显示
     ("g n" (setq doom-modeline-gnus (not doom-modeline-gnus))
      "gnus" :toggle doom-modeline-gnus) ;; 切换是否显示 Gnus 邮件通知
     ("g u" (setq doom-modeline-mu4e (not doom-modeline-mu4e))
      "mu4e" :toggle doom-modeline-mu4e) ;; 切换是否显示 mu4e 邮件通知
     ("g r" (setq doom-modeline-irc (not doom-modeline-irc))
      "irc" :toggle doom-modeline-irc) ;; 切换是否显示 IRC 消息通知
     ("g f" (setq doom-modeline-irc-buffers (not doom-modeline-irc-buffers))
      "irc buffers" :toggle doom-modeline-irc-buffers) ;; 切换是否显示 IRC 缓冲区状态
     ("g t" (setq doom-modeline-time (not doom-modeline-time))
      "time" :toggle doom-modeline-time) ;; 切换是否在状态栏显示系统时间
     ("g v" (setq doom-modeline-env-version (not doom-modeline-env-version))
      "version" :toggle doom-modeline-env-version)) ;; 切换是否显示环境版本（如 Python/Node 版本）
    "Style" ;; --- 文件名显示风格设置组 ---
    (("a" (setq doom-modeline-buffer-file-name-style 'auto)
      "auto"
      :toggle (eq doom-modeline-buffer-file-name-style 'auto)) ;; 自动决定文件名显示风格
     ("b" (setq doom-modeline-buffer-file-name-style 'buffer-name)
      "buffer name"
      :toggle (eq doom-modeline-buffer-file-name-style 'buffer-name)) ;; 仅显示缓冲区名称
     ("f" (setq doom-modeline-buffer-file-name-style 'file-name)
      "file name"
      :toggle (eq doom-modeline-buffer-file-name-style 'file-name)) ;; 仅显示文件名
     ("F" (setq doom-modeline-buffer-file-name-style 'file-name-with-project)
      "file name with project"
      :toggle (eq doom-modeline-buffer-file-name-style 'file-name-with-project)) ;; 显示文件名及其所属项目名
     ("t u" (setq doom-modeline-buffer-file-name-style 'truncate-upto-project)
      "truncate upto project"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-upto-project)) ;; 截断至项目根目录
     ("t f" (setq doom-modeline-buffer-file-name-style 'truncate-from-project)
      "truncate from project"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-from-project)) ;; 从项目根目录开始截断
     ("t w" (setq doom-modeline-buffer-file-name-style 'truncate-with-project)
      "truncate with project"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-with-project)) ;; 配合项目缩写的截断
     ("t e" (setq doom-modeline-buffer-file-name-style 'truncate-except-project)
      "truncate except project"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-except-project)) ;; 截断除项目名以外的部分
     ("t r" (setq doom-modeline-buffer-file-name-style 'truncate-upto-root)
      "truncate upto root"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-upto-root)) ;; 截断至磁盘根目录
     ("t a" (setq doom-modeline-buffer-file-name-style 'truncate-all)
      "truncate all"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-all)) ;; 截断中间所有目录层级
     ("t n" (setq doom-modeline-buffer-file-name-style 'truncate-nil)
      "truncate none"
      :toggle (eq doom-modeline-buffer-file-name-style 'truncate-nil)) ;; 不进行任何截断（显示全路径）
     ("r f" (setq doom-modeline-buffer-file-name-style 'relative-from-project)
      "relative from project"
      :toggle (eq doom-modeline-buffer-file-name-style 'relative-from-project)) ;; 显示相对于项目根目录的路径
     ("r t" (setq doom-modeline-buffer-file-name-style 'relative-to-project)
      "relative to project"
      :toggle (eq doom-modeline-buffer-file-name-style 'relative-to-project))) ;; 另一种相对于项目的路径显示
    "Check" ;; --- 语法检查设置组 ---
    (("c a" (setq doom-modeline-check 'auto)
      "auto" :toggle (eq doom-modeline-check 'auto)) ;; 自动显示检查结果
     ("c f" (setq doom-modeline-check 'full)
      "full" :toggle (eq doom-modeline-check 'full)) ;; 显示完整的检查信息
     ("c s" (setq doom-modeline-check 'simple)
      "simple" :toggle (eq doom-modeline-check 'simple)) ;; 显示简化的检查信息
     ("c d" (setq doom-modeline-check nil)
      "disable" :toggle (eq doom-modeline-check nil))) ;; 禁用语法检查状态显示
    "Project" ;; --- 项目检测后端设置组 ---
    (("p a" (setq doom-modeline-project-detection 'auto)
      "auto"
      :toggle (eq doom-modeline-project-detection 'auto)) ;; 自动检测项目类型
     ("p f" (setq doom-modeline-project-detection 'ffip)
      "ffip"
      :toggle (eq doom-modeline-project-detection 'ffip)) ;; 使用 find-file-in-project 检测项目
     ("p i" (setq doom-modeline-project-detection 'projectile)
      "projectile"
      :toggle (eq doom-modeline-project-detection 'projectile)) ;; 使用 Projectile 插件检测项目
     ("p p" (setq doom-modeline-project-detection 'project)
      "project"
      :toggle (eq doom-modeline-project-detection 'project)) ;; 使用 Emacs 内置 project.el 检测项目
     ("p d" (setq doom-modeline-project-detection nil)
      "disable"
      :toggle (eq doom-modeline-project-detection nil))) ;; 禁用项目检测
    "Misc" ;; --- 杂项功能与交互组 ---
    (("n" (progn
            (message "Fetching GitHub notifications...") ;; 在回显区提示获取通知
            (run-with-timer 300 nil #'doom-modeline--github-fetch-notifications) ;; 启动定时器异步获取
            (browse-url "https://github.com/notifications")) ;; 打开浏览器查看 GitHub 通知
      "github notifications" :exit t) ;; 执行后退出菜单
     ("e" (and (bound-and-true-p flymake-mode)
               (flymake-show-diagnostics-buffer)) ;; 若开启了 Flymake 则显示诊断信息列表
      "list errors" :exit t)
     ("w" (if (bound-and-true-p grip-mode)
              (grip-browse-preview) ;; 若开启了 Grip 则在浏览器预览 Markdown
            (message "Not in preview"))
      "browse preview" :exit t)
     ("z h" (set-from-minibuffer 'doom-modeline-height)
      "set height" :exit t) ;; 从 Minibuffer 输入并设置状态栏高度
     ("z w" (set-from-minibuffer 'doom-modeline-bar-width)
      "set bar width" :exit t) ;; 从 Minibuffer 输入并设置左侧边条宽度
     ("z g" (set-from-minibuffer 'doom-modeline-github-interval)
      "set github interval" :exit t) ;; 设置 GitHub 通知刷新的时间间隔
     ("z n" (set-from-minibuffer 'doom-modeline-gnus-timer)
      "set gnus interval" :exit t))))) ;; 设置 Gnus 邮件检测的时间间隔

(use-package minions :hook after-init)

(use-package nerd-icons
  :commands nerd-icons-install-fonts
  :functions font-available-p
  :config
  ;; Install nerd fonts automatically only in GUI
  ;; For macOS, may install via "brew install font-symbols-only-nerd-font"
  (when (and (display-graphic-p)
             (not (font-available-p nerd-icons-font-family)))
    (nerd-icons-install-fonts t)))

(use-package display-line-numbers
  :ensure nil
  :hook ((prog-mode
          conf-mode toml-ts-mode
          yaml-mode yaml-ts-mode)
         . display-line-numbers-mode)
  :init (setq display-line-numbers-width-start t) (setq display-line-numbers-rows-extend t))


(setq use-file-dialog nil                   ; 禁止使用系统图形文件对话框（强制在 Minibuffer 中输入路径）
      use-dialog-box nil                    ; 禁止弹出图形对话框（如确认删除时的鼠标点击弹窗）
      inhibit-startup-screen t              ; 禁用启动时的欢迎界面（GNU Emacs 默认的大 Logo 界面）
      inhibit-startup-echo-area-message user-login-name ; 隐藏回显区的启动消息（通常是版权信息）
      inhibit-default-init t                ; 忽略默认的初始化加载（通常用于更纯净的启动）
      initial-scratch-message nil)          ; 将 *scratch* 缓冲区的初始提示文字设为空（默认是一段注释）

(unless (daemonp)                           ; 如果当前不是以守护进程（Daemon）模式运行
  (advice-add #'display-startup-echo-area-message :override #'ignore)) ; 彻底禁用回显区的启动版权信息显示

;; --- 窗口分割线设置 ---
(setq window-divider-default-places t       ; 设置窗口分割线在右侧和底部同时显示
      window-divider-default-bottom-width 2 ; 设置底部分割线的宽度为 2 像素
      window-divider-default-right-width 2) ; 设置右侧分割线的宽度为 2 像素

(add-hook 'window-setup-hook #'window-divider-mode) ; 在窗口界面初始化完成后，自动开启分割线模式

;; 缩放模式
(use-package default-text-scale
  :hook (after-init . default-text-scale-mode)
  :bind (:map default-text-scale-mode-map
         ("C-=" . default-text-scale-increase)
         ("C--" . default-text-scale-decrease)
         ("C-0" . default-text-scale-reset)))

(use-package time
  :init (setq display-time-default-load-average nil
              display-time-format "%H:%M"))


(setq hscroll-step 1                        ; 水平滚动时，每次只移动 1 个字符
      hscroll-margin 2                      ; 离左右边界还剩 2 个字符时就开始滚动
      scroll-step 1                         ; 垂直滚动时，每次只移动 1 行
      scroll-margin 0                       ; 离上下边界剩 0 行时才滚动（设为 3-5 会更有呼吸感）
      scroll-conservatively 100000          ; 核心设置：只要滚动超过此行数就逐行移动。
                                        ; 设为一个极大的值可避免光标到边界时页面猛跳。
      scroll-preserve-screen-position t     ; 翻页时，光标保持在屏幕中的相对位置（不随翻页乱跳）
      auto-window-vscroll nil               ; 禁止自动调整窗口垂直滚动比例，提升渲染性能

      ;; Mouse - 鼠标滚轮设置
      mouse-wheel-scroll-amount-horizontal 1 ; 鼠标水平滚轮每次滚动 1 个单位
      mouse-wheel-progressive-speed nil)    ; 关闭加速滚动。如果你快速拨动滚轮，
                                        ; 滚动速度保持线性，而不是越来越快。

;; 当你开启 mixed-pitch-mode 时，它会实现以下效果：
;; 正文部分：使用你设置的比例字体（通常更像书本排版，阅读感好）。
;; 特殊部分：自动识别代码块、表格、各种标记符号等，并保持使用等宽字体。
(use-package mixed-pitch :diminish)


;; 分页符美化
(use-package page-break-lines
  :diminish
  :hook (after-init . global-page-break-lines-mode)
  :config (dolist (mode '(dashboard-mode emacs-news-mode))
            (add-to-list 'page-break-lines-modes mode)))

(provide 'init-ui)
