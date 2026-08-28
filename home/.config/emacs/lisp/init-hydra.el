;; -*- lexical-binding: t; -*-

;;; Code:

(use-package hydra

  :hook ((emacs-lisp-mode . hydra-add-imenu)          ; 在进入 Emacs Lisp 模式时，将 Hydra 定义添加到 Imenu 索引中
         ((after-init after-load-theme server-after-make-frame) . hydra-set-posframe)) ; 初始化、切换主题或创建新 frame 后配置显示样式
  :init
  (with-eval-after-load 'consult-imenu                ; 确保在 consult-imenu 加载后再执行以下配置
    (setq consult-imenu-config
          '((emacs-lisp-mode :toplevel "Functions"    ; 为 Elisp 模式定制 consult-imenu 的分类展示
                             :types ((?f "Functions" font-lock-function-name-face) ; 函数分类
                                     (?h "Hydras"    font-lock-constant-face)      ; Hydra 定义分类
                                     (?m "Macros"    font-lock-function-name-face) ; 宏分类
                                     (?p "Packages"  font-lock-constant-face)      ; 宏包分类
                                     (?t "Types"     font-lock-type-face)          ; 类型定义分类
                                     (?v "Variables" font-lock-variable-name-face)))))) ; 变量分类

  (defun hydra-set-posframe ()
    "Set display type and appearance of hydra."        ; 定义函数：设置 Hydra 的显示类型（浮窗或底部栏）与外观
    (setq hydra-hint-display-type 'lv)
    ;; Appearance
    (setq hydra-posframe-show-params                  ; 配置 posframe 浮窗的具体参数
          `(:left-fringe 8                            ; 左侧边缘宽度
            :right-fringe 8                           ; 右侧边缘宽度
            :internal-border-width 2 ; 内部边框宽度，取自全局变量
            :internal-border-color ,(face-background 'posframe-border nil t) ; 边框颜色取自主题的 posframe-border 背景色
            :background-color ,(face-background 'tooltip nil t)             ; 浮窗背景色跟随系统的 tooltip（提示框）
            :foreground-color ,(face-foreground 'tooltip nil t)             ; 浮窗前景色跟随系统的 tooltip
            :lines-truncate t                         ; 超过宽度时截断行而不折行
            :poshandler posframe-poshandler-frame-center-near-bottom))))    ; 浮窗显示位置：屏幕底部中央附近
(use-package pretty-hydra
  :functions icons-displayable-p           ; 声明外部函数，避免编译警告
  :bind ("<f6>" . toggles-hydra/body)      ; 将 F6 键绑定到该 Hydra 面板
  :hook (emacs-lisp-mode . pretty-hydra-add-imenu) ; 在 elisp 模式下将 Hydra 定义添加到 Imenu 索引
  :init
  (defun pretty-hydra-add-imenu ()         ; 定义函数：让 Imenu 能识别 pretty-hydra-define
    "Have hydras in `imenu'."
    (add-to-list 'imenu-generic-expression
                 '("Hydras" "^.*(\\(pretty-hydra-define\\) \\([a-zA-Z-]+\\)" 2)))

  (cl-defun pretty-hydra-title (title &optional icon-type icon-name
                                      &key face height v-adjust)
    "Add an icon in the hydra title."          ; 定义函数：为 Hydra 标题添加图标
    (let ((face (or face 'mode-line-emphasis)) ; 设置默认脸谱（样式）
          (height (or height 1.2))             ; 设置默认图标高度
          (v-adjust (or v-adjust 0.0)))        ; 设置垂直偏移量
      (concat
       (when (and (icons-displayable-p) icon-type icon-name) ; 如果支持图标且提供了图标信息
         (let ((f (intern (format "nerd-icons-%s" icon-type)))) ; 构建图标函数名（如 nerd-icons-faicon）
           (when (fboundp f)                   ; 如果该函数存在
             (concat
              (apply f (list icon-name :face face :height height :v-adjust v-adjust)) ; 生成图标
              " "))))                          ; 图标后加空格
       (propertize title 'face face))))        ; 加上带样式的标题文本
  :config
  (with-no-warnings                            ; 抑制配置块内的编译警告
    ;; Define hydra for global toggles
    (pretty-hydra-define toggles-hydra        ; 定义名为 toggles-hydra 的面板
      (:title (pretty-hydra-title "Toggles" 'faicon "nf-fa-toggle_on") ; 设置标题和图标
       :color amaranth :quit-key ("q" "C-g")) ; 设置颜色模式为 amaranth（点击不退出），退出键为 q 或 C-g
      ("Basic"                                 ; 第一栏：基础设置
       (("n" display-line-numbers-mode "line number" :toggle t)       ; n: 行号
        ("a" global-aggressive-indent-mode "aggressive indent *" :toggle t) ; a: 激进缩进
        ("d" global-hungry-delete-mode "hungry delete *" :toggle t)    ; d: 贪婪删除
        ("e" electric-pair-mode "electric pair *" :toggle t)           ; e: 自动括号配对
        ("c" flyspell-mode "spell check" :toggle t)                    ; c: 拼写检查
        ("s" prettify-symbols-mode "pretty symbol" :toggle t)          ; s: 符号美化
        ("l" global-page-break-lines-mode "page break lines *" :toggle t) ; l: 分页符显示
        ("b" display-battery-mode "battery *" :toggle t)               ; b: 电池电量显示
        ("i" display-time-mode "time *" :toggle t)                     ; i: 时间显示
        ("m" doom-modeline-mode "modern mode-line *" :toggle t))       ; m: 现代模式线
       "Highlight"                             ; 第二栏：高亮设置
       (("h l" global-hl-line-mode "line *" :toggle t)                 ; hl: 高亮当前行
        ("h p" show-paren-mode "parenthesis *" :toggle t)              ; hp: 高亮匹配括号
        ("h s" symbol-overlay-mode "symbol" :toggle t)                 ; hs: 高亮光标下符号
        ("h r" global-colorful-mode "color *" :toggle t)               ; hr: 颜色代码预览
        ("h w" (setq-default show-trailing-whitespace (not show-trailing-whitespace))
         "whitespace" :toggle show-trailing-whitespace)                ; hw: 显示行尾空格
        ("h d" rainbow-delimiters-mode "delimiter" :toggle t)          ; hd: 彩虹括号
        ("h i" indent-bars-mode "indent" :toggle t)                    ; hi: 缩进指示线
        ("h t" global-hl-todo-mode "todo *" :toggle t))                ; ht: 高亮 TODO 关键词
       "Program"                               ; 第三栏：编程辅助
       (("f" flymake-mode "flymake" :toggle t)                         ; f: 语法检查
        ("O" hs-minor-mode "hideshow" :toggle t)                       ; O: 代码折叠
        ("u" subword-mode "subword" :toggle t)                         ; u: 子词导航（驼峰命名）
        ("W" which-function-mode "current function *" :toggle t)       ; W: 显示当前函数名
        ("E" toggle-debug-on-error "debug on error" :toggle (default-value 'debug-on-error)) ; E: 错误时进入调试
        ("Q" toggle-debug-on-quit "debug on quit" :toggle (default-value 'debug-on-quit))   ; Q: 退出时进入调试
        ("v" global-diff-hl-mode "gutter *" :toggle t)                 ; v: 侧边栏显示 Git 修改
        ("V" diff-hl-flydiff-mode "live gutter *" :toggle t)           ; V: 实时侧边栏 Git 修改
        ("M" diff-hl-margin-mode "margin gutter *" :toggle t)          ; M: 边距显示 Git 修改
        ("D" diff-hl-dired-mode "dired gutter" :toggle t))             ; D: Dired 模式 Git 修改
        ))))
(provide 'init-hydra)
