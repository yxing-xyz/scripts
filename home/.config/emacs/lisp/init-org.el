;;; init-org.el --- 初始化 Org 模式配置。  -*- lexical-binding: t -*-
;; 启用词法绑定（lexical-binding），能提升性能并减少变量作用域冲突

;; 版权声明及协议部分 (略...)

;;; Commentary:
;; Org 模式的具体配置。

;;; Code:

(eval-when-compile
  (require 'init-const)      ;; 编译时加载常量定义（如文件路径）
  (require 'init-custom))     ;; 编译时加载用户自定义设置

(setq org-directory (expand-file-name "org" user-emacs-directory))
(use-package org
  :ensure nil                 ;; 使用内置的 Org 模式，无需另外安装
  :custom-face (org-ellipsis ((t (:foreground unspecified)))) ;; 设置标题折叠符号的样式，不指定特定颜色
  :pretty-hydra               ;; 定义一个漂亮的图形化快捷菜单（Hydra）
  ;; 以下是 Hydra 菜单的具体内容，用于快速插入 Org 结构模板
  ((:title (pretty-hydra-title "Org Template" 'sucicon "nf-custom-orgmode" :face 'nerd-icons-green)
    :color blue :quit-key ("q" "C-g"))
   ("Basic" ;; 基础模板组
    (("a" (hot-expand "<a") "ascii")    ;; 插入 ASCII 导出块
     ("c" (hot-expand "<c") "center")   ;; 插入居中块
     ("C" (hot-expand "<C") "comment")  ;; 插入注释块
     ("x" (hot-expand "<e") "example")  ;; 插入示例代码块
     ("E" (hot-expand "<E") "export")   ;; 插入导出选项
     ("h" (hot-expand "<h") "html")     ;; 插入 HTML 导出块
     ("l" (hot-expand "<l") "latex")    ;; 插入 LaTeX 导出块
     ("n" (hot-expand "<n") "note")     ;; 插入笔记块
     ("o" (hot-expand "<q") "quote")    ;; 插入引用块
     ("v" (hot-expand "<v") "verse"))   ;; 插入诗歌/韵文块
    "Head" ;; 文档头部信息组
    (("i" (hot-expand "<i") "index")    ;; 插入索引
     ("A" (hot-expand "<A") "ASCII")    ;; 插入大写 ASCII
     ("I" (hot-expand "<I") "INCLUDE")  ;; 插入文件包含指令
     ("H" (hot-expand "<H") "HTML")     ;; 插入大写 HTML
     ("L" (hot-expand "<L") "LaTeX"))   ;; 插入大写 LaTeX
    "Source" ;; 编程语言源码块组
    (("s" (hot-expand "<s") "src")        ;; 基础源码块
     ("e" (hot-expand "<s" "emacs-lisp") "emacs-lisp") ;; Elisp 块
     ("y" (hot-expand "<s" "python :results output") "python") ;; Python 块
     ("p" (hot-expand "<s" "perl") "perl") ;; Perl 块
     ("w" (hot-expand "<s" "powershell") "powershell") ;; PowerShell 块
     ("r" (hot-expand "<s" "ruby") "ruby") ;; Ruby 块
     ("S" (hot-expand "<s" "sh") "sh")     ;; Shell 脚本块
     ("g" (hot-expand "<s" "go :imports '\(\"fmt\"\)") "golang")) ;; Go 块
    "Misc" ;; 其他工具组
    (("m" (hot-expand "<s" "mermaid :file chart.png") "mermaid") ;; 流程图块
     ("u" (hot-expand "<s" "plantuml :file chart.png") "plantuml") ;; UML 图块
     ("Y" (hot-expand "<s" "ipython :session :exports both :results raw drawer\n$0") "ipython") ;; IPython 交互块
     ("P" (progn ;; 复杂的 Perl 缠绕（tangled）模板
            (insert "#+HEADERS: :results output :exports both :shebang \"#!/usr/bin/env perl\"\n")
            (hot-expand "<s" "perl")) "Perl tangled")
     ("<" self-insert-command "ins")))) ;; 输入原生的 < 符号
  :bind (("C-c o a" . org-agenda)  ;; 绑定 C-c o a 到日程表
         ("C-c o b" . org-switchb) ;; 绑定 C-c o b 到 Org Buffer 快速切换
         ("C-c o x" . org-capture) ;; 绑定 C-c o x 到内容捕获
         :map org-mode-map
         ("<" . (lambda () ;; 魔法键：如果在行首输入 < 则弹出 Hydra 菜单
                  "Insert org template."
                  (interactive)
                  (if (or (region-active-p) (looking-back "^\s*" 1))
                      (org-hydra/body)
                    (self-insert-command 1)))))
  :hook (((org-babel-after-execute org-mode) . org-redisplay-inline-images) ;; 代码运行后刷新图片显示
         (org-indent-mode . (lambda() ;; 在缩进模式下的特殊处理
                              (diminish 'org-indent-mode) ;; 隐藏模式栏里的缩进图标
                              ;; 解决括号匹配导致文字跳动的一个 Hack 方案
                              (make-variable-buffer-local 'show-paren-mode)
                              (setq show-paren-mode nil))))
  :config
  ;; 定义 hot-expand 函数，用于支持新旧版本的 Org 模板补全
  (defun hot-expand (str &optional mod)
    "扩展 Org 结构模板。"
    (let (text)
      (when (region-active-p) ;; 如果有选中区域，先保存并删除它
        (setq text (buffer-substring (region-beginning) (region-end)))
        (delete-region (region-beginning) (region-end)))
      (insert str) ;; 插入模板标识符（如 <s）
      (if (fboundp 'org-try-structure-completion)
          (org-try-structure-completion) ;; 旧版 Org 补全
        (progn
          (require 'org-tempo nil t) ;; 加载新版 Org 补全库
          (org-tempo-complete-tag)))
      (when mod (insert mod) (forward-line)) ;; 插入语言参数
      (when text (insert text)))) ;; 把刚才选中的文本塞进模板中间

  ;; 基础设置，移到 :config 部分以加快 Emacs 启动速度
  (setq org-modules nil                 ;; 禁用默认模块以提升加载速度
        org-capture-templates           ;; 设置捕获模板（灵感、待办、笔记等）
        `(("i" "Idea" entry (file ,(concat org-directory "/idea.org"))
           "* %^{Title} %?\n%U\n%a\n")
          ("t" "Todo" entry (file ,(concat org-directory "/gtd.org"))
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
          ("n" "Note" entry (file ,(concat org-directory "/note.org"))
           "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
          ("j" "Journal" entry (file+olp+datetree
                                ,(concat org-directory "/journal.org"))
           "* %^{Title} %?\n%U\n%a\n" :clock-in t :clock-resume t)
	      ("b" "Book" entry (file+olp+datetree
                             ,(concat org-directory "/book.org"))
	       "* Topic: %^{Description}  %^g %? Added: %U"))

        org-todo-keywords ;; 设置待办状态关键词及其对应图标
        '((sequence "TODO(t)" "DOING(i)" "HANGUP(h)" "|" "DONE(d)" "CANCEL(c)")
          (sequence "⚑(T)" "🏴(I)" "❓(H)" "|" "✔(D)" "✘(C)"))
        org-todo-keyword-faces '(("HANGUP" . warning) ;; 给特定状态设置颜色
                                 ("❓" . warning))
        org-priority-faces '((?A . error)   ;; 设置优先级 A 的颜色（红色）
                             (?B . warning) ;; 设置优先级 B 的颜色（黄色）
                             (?C . success)) ;; 设置优先级 C 的颜色（绿色）

        ;; 日程表（Agenda）的美化设置
        org-agenda-files (list org-directory) ;; 扫描哪些文件生成日程
        org-agenda-block-separator ?─  ;; 使用实线分隔不同板块
        org-agenda-time-grid           ;; 设置时间轴样式
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "⭠ now ─────────────────────────────────────────────────"

        org-tags-column -80            ;; 标签向右对齐的位置
        org-log-done 'time             ;; 完成任务时记录时间
        org-catch-invisible-edits 'smart ;; 防止误删隐藏区域的内容
        org-startup-indented t         ;; 启动时自动启用缩进视图
        org-ellipsis (if (char-displayable-p ?⏷) "\t⏷" nil) ;; 设置折叠符号为下箭头
        org-pretty-entities nil        ;; 是否美化 LaTeX 字符
        org-hide-emphasis-markers t)   ;; 隐藏加粗/斜体等标记符号

  (add-to-list 'org-structure-template-alist '("n" . "note")) ;; 添加 note 快捷模板

  ;; 设置特定文件类型的打开方式，优先使用内置 Webkit 浏览器
  (add-to-list 'org-file-apps
               '("\\.\\(x?html?\\|pdf\\)\\'"
                 .
                 (lambda (file _link)
                   (centaur-browse-url-of-file (browse-url-file-url file)))))

  ;; 导出增强：添加 Markdown 和 GitHub Markdown 支持
  (add-to-list 'org-export-backends 'md)
  (use-package ox-gfm
    :init (add-to-list 'org-export-backends 'gfm))

  ;; Babel：代码执行设置
  (setq org-confirm-babel-evaluate nil ;; 执行代码前不询问，直接运行
        org-src-fontify-natively t    ;; 源码块根据语言高亮
        org-src-tab-acts-natively t)  ;; 在源码块里按 Tab 键使用该语言的缩进规则

  ;; 定义要加载的代码块执行语言列表
  (defconst load-language-alist
    '((emacs-lisp . t)
      (perl       . t)
      (python     . t)
      (ruby       . t)
      (js         . t)
      (css        . t)
      (sass       . t)
      (C          . t)
      (java       . t)
      (shell      . t)
      (plantuml   . t))
    "Org Babel 支持的语言列表。")

  ;; 额外加载第三方 Babel 扩展包并加入列表
  (use-package ob-go :init (cl-pushnew '(go . t) load-language-alist))
  (use-package ob-powershell :init (cl-pushnew '(powershell . t) load-language-alist))
  (use-package ob-rust :init (cl-pushnew '(rust . t) load-language-alist))
  (use-package ob-mermaid :init (cl-pushnew '(mermaid . t) load-language-alist))

  ;; 激活所有选定的编程语言
  (org-babel-do-load-languages 'org-babel-load-languages load-language-alist))

;; UI 美化：将 Org 界面变得现代化（复选框、进度条、美化标签等）
(use-package org-modern
  :after org
  :diminish
  :autoload global-org-modern-mode
  :init (global-org-modern-mode 1))

;; 功能增强：粘贴时自动带上源码块标记和原始链接
(use-package org-rich-yank
  :after org
  :diminish
  :bind (:map org-mode-map ("C-M-y" . org-rich-yank)))

;; 自动显示/隐藏隐藏标记（如光标靠近时显示加粗符号，离开后隐藏）
(use-package org-appear
  :diminish
  :hook org-mode
  :custom
  (org-appear-autoentities t)
  (org-appear-autokeywords t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-inside-latex t)
  (org-appear-manual-linger t)
  (org-appear-delay 0.5))

;; 自动生成并更新目录
(use-package toc-org
  :diminish
  :hook org-mode)

;; HTML 实时预览功能
(use-package org-preview-html
  :after org
  :diminish
  :functions xwidget-workable-p
  :bind (:map org-mode-map ("C-c C-h" . org-preview-html-mode))
  :init (when (xwidget-workable-p)
          (setq org-preview-html-viewer 'xwidget))) ;; 优先使用内核浏览器预览

;; 演示模式设置
(use-package dslide ;; Emacs 29.2+ 使用新的 dslide 进行幻灯片展示
  :after org
  :diminish
  :bind (:map org-mode-map ("s-<f7>" . dslide-deck-start)))


;; 番茄钟功能
(use-package org-pomodoro
  :after org
  :diminish
  :custom-face ;; 根据不同状态改变模式栏颜色（进行中、超时、休息）
  (org-pomodoro-mode-line ((t (:inherit warning))))
  (org-pomodoro-mode-line-overtime ((t (:inherit error))))
  (org-pomodoro-mode-line-break ((t (:inherit success))))
  :bind (:map org-mode-map ("C-c C-x m" . org-pomodoro))
  :init (with-eval-after-load 'org-agenda
          (bind-keys :map org-agenda-mode-map
            ("K" . org-pomodoro)
            ("C-c C-x m" . org-pomodoro))))

;; Org Roam：个人知识库/双向链接笔记
(when (and (fboundp 'sqlite-available-p) (sqlite-available-p)) ;; 需 SQLite 支持
  (use-package org-roam
    :diminish
    :functions centaur-browse-url org-roam-db-autosync-mode
    :defines org-roam-graph-viewer
    :bind (("C-c n l" . org-roam-buffer-toggle) ;; 切换笔记列表面板
           ("C-c n f" . org-roam-node-find)     ;; 查找/新建笔记
           ("C-c n g" . org-roam-graph)         ;; 查看关系图谱
           ("C-c n i" . org-roam-node-insert)    ;; 插入笔记链接
           ("C-c n c" . org-roam-capture)        ;; 捕获新笔记
           ("C-c n j" . org-roam-dailies-capture-today)) ;; 记录日记
    :init
    (setq org-roam-directory org-directory ;; 设置笔记根目录
          org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))
          org-roam-graph-viewer #'centaur-browse-url)
    :config
    (unless (file-exists-p org-roam-directory)
      (make-directory org-roam-directory))
    (add-to-list 'org-agenda-files org-roam-directory) ;; 将笔记目录也加入日程表扫描
    (org-roam-db-autosync-mode)) ;; 自动同步数据库

  ;; Roam 的浏览器图形化界面
  (use-package org-roam-ui
    :bind ("C-c n u" . org-roam-ui-mode)
    :init (setq org-roam-ui-browser-function #'centaur-browse-url)))

(provide 'init-org) ;; 提供模块标识符，方便其他文件 require

;;; init-org.el 结束
