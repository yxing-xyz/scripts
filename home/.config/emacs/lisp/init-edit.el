;; -*- lexical-binding: t; -*-

(eval-when-compile
  (require 'init-const))

;; 输入文字覆盖选择区域
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;; 矩形操作
(use-package rect
  ;; rect 是 Emacs 内置的矩形操作库，不需要从外部下载
  :ensure nil

  ;; 定义快捷键绑定
  :bind (:map text-mode-map
         ("<C-return>" . rect-hydra/body) ; 在文本模式下按 Ctrl+Enter 开启
         :map prog-mode-map
         ("<C-return>" . rect-hydra/body)) ; 在编程模式下按 Ctrl+Enter 开启

  :init
  ;; 针对特定模式的特殊处理，确保在这些模式下也能通过快捷键呼出 Hydra
  (with-eval-after-load 'org
    (bind-key "<s-return>" #'rect-hydra/body org-mode-map)) ; Org-mode 用 Super+Enter (通常是 Win/Command 键)
  (with-eval-after-load 'wgrep
    (bind-key "<C-return>" #'rect-hydra/body wgrep-mode-map)) ; 在可编辑的 grep 结果页开启
  (with-eval-after-load 'wdired
    (bind-key "<C-return>" #'rect-hydra/body wdired-mode-map)) ; 在可编辑的 Dired 目录页开启

  ;; 使用 pretty-hydra 插件定义图形化菜单
  :pretty-hydra
  ((:title (pretty-hydra-title "Rectangle" 'mdicon "nf-md-border_all") ; 菜单标题和图标
    :color amaranth      ; 颜色模式：即使按了非 Hydra 键也不会退出，除非按退出键
    :body-pre (rectangle-mark-mode) ; 进入 Hydra 前自动开启矩形选择模式
    :post (deactivate-mark)         ; 退出 Hydra 后自动取消选区
    :quit-key ("q" "C-g"))          ; 退出快捷键

   ;; 菜单分组：移动
   ("Move"
    (("h" backward-char "←")  ; 左移
     ("j" next-line "↓")      ; 下移
     ("k" previous-line "↑")  ; 上移
     ("l" forward-char "→"))  ; 右移

    ;; 菜单分组：核心操作
    "Action"
    (("w" copy-rectangle-as-kill "copy") ; 复制矩形内容
     ("y" yank-rectangle "yank")         ; 粘贴矩形内容
     ("t" string-rectangle "string")     ; 在矩形每行插入相同字符串
     ("d" kill-rectangle "kill")         ; 剪切矩形区域
     ("c" clear-rectangle "clear")       ; 清除矩形内容（变为空格）
     ("o" open-rectangle "open"))        ; 在矩形区域插入空白

    ;; 菜单分组：其他工具
    "Misc"
    (("N" rectangle-number-lines "number lines")        ; 矩形选区内自动编号
     ("e" rectangle-exchange-point-and-mark "exchange") ; 交换光标和标记的位置（切换对角）
     ("u" undo "undo")                                  ; 撤销操作
     ("r" (if (region-active-p)                         ; 重置按钮
              (deactivate-mark)
            (rectangle-mark-mode 1))
      "reset")))))

;; Automatically reload files was modified by external program
(use-package autorevert
  :ensure nil
  :diminish
  :hook (after-init . global-auto-revert-mode))


;; Pass a URL to a WWW browser
(use-package browse-url
  :ensure nil
  :defines dired-mode-map
  :bind (("C-c C-z ." . browse-url-at-point)
         ("C-c C-z b" . browse-url-of-buffer)
         ("C-c C-z r" . browse-url-of-region)
         ("C-c C-z u" . browse-url)
         ("C-c C-z e" . browse-url-emacs)
         ("C-c C-z v" . browse-url-of-file))
  :init
  (with-eval-after-load 'dired
    (bind-key "C-c C-z f" #'browse-url-of-file dired-mode-map))

  ;; For WSL
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic)
      (when (daemonp)
        e(advice-add #'browse-url :override #'browse-url-generic)))))

(use-package goto-addr
  :ensure nil
  :hook ((text-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)))

(use-package avy
  :bind (("C-:"   . avy-goto-char)
         ("C-'"   . avy-goto-char-2)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g e" . avy-goto-word-0))
  :hook (after-init . avy-setup-default)
  :config (setq avy-all-windows nil
                avy-all-windows-alt t
                avy-background t
                avy-style 'pre))

;; Kill text between the point and the character CHAR
(use-package avy-zap
  :bind (("M-z" . avy-zap-to-char-dwim)
         ("M-Z" . avy-zap-up-to-char-dwim)))

;; Jump to Chinese characters
(use-package ace-pinyin
  :diminish
  :hook (after-init . ace-pinyin-global-mode))


;; Quickly follow links
(use-package link-hint
  :defines (Info-mode-map
            compilation-mode-map custom-mode-map
            devdocs-mode-map elfeed-show-mode-map eww-mode-map
            help-mode-map helpful-mode-map nov-mode-map
            woman-mode-map xref--xref-buffer-mode-map)
  :functions embark-dwim
  :bind (("M-o"     . link-hint-open-link)
         ("C-c l o" . link-hint-open-link)
         ("C-c l c" . link-hint-copy-link))
  :init
  (with-eval-after-load 'compile
    (bind-key "o" #'link-hint-open-link compilation-mode-map))
  (with-eval-after-load 'cus-edit
    (bind-key "o" #'link-hint-open-link custom-mode-map))
  (with-eval-after-load 'devdocs
    (bind-key "o" #'link-hint-open-link devdocs-mode-map))
  (with-eval-after-load 'elfeed-show
    (bind-key "o" #'link-hint-open-link elfeed-show-mode-map))
  (with-eval-after-load 'eww
    (bind-key "o" #'link-hint-open-link eww-mode-map))
  (with-eval-after-load 'help
    (bind-key "o" #'link-hint-open-link help-mode-map))
  (with-eval-after-load 'helpful
    (bind-key "o" #'link-hint-open-link helpful-mode-map))
  (with-eval-after-load 'info
    (bind-key "o" #'link-hint-open-link Info-mode-map))
  (with-eval-after-load 'nov
    (bind-key "o" #'link-hint-open-link nov-mode-map))
  (with-eval-after-load 'woman
    (bind-key "o" #'link-hint-open-link woman-mode-map))
  (with-eval-after-load 'xref
    (bind-key "o" #'link-hint-open-link xref--xref-buffer-mode-map))

  (with-eval-after-load 'embark
    (setq link-hint-action-fallback-commands
          (list :open (lambda ()
                        (condition-case _
                            (progn
                              (embark-dwim)
                              t)
                          (error
                           nil)))))))


;; anzu 是一个专门用来增强 Emacs 搜索和替换体验的小工具。
(use-package anzu
  :diminish
  :bind (([remap query-replace] . anzu-query-replace)
         ([remap query-replace-regexp] . anzu-query-replace-regexp)
         :map isearch-mode-map
         ([remap isearch-query-replace] . anzu-isearch-query-replace)
         ([remap isearch-query-replace-regexp] . anzu-isearch-query-replace-regexp))
  :hook (after-init . global-anzu-mode))

;; Redefine M-< and M-> for some modes
(use-package beginend
  :diminish beginend-global-mode
  :functions diminish
  :hook (after-init . beginend-global-mode)
  :config (mapc (lambda (pair)
                  (diminish (cdr pair)))
                beginend-modes))

;; ;; Drag stuff (lines, words, region, etc...) around
(use-package drag-stuff
  :diminish
  :autoload drag-stuff-define-keys
  :hook (after-init . drag-stuff-global-mode)
  :config
  (add-to-list 'drag-stuff-except-modes 'org-mode)
  (drag-stuff-define-keys))


(use-package ediff
  :ensure nil
  :hook(;; show org ediffs unfolded
        (ediff-prepare-buffer . outline-show-all)
        ;; restore window layout when done
        (ediff-quit . tab-bar-history-back))
  :init
  (with-eval-after-load 'ediff (require 'outline))
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain
        ediff-split-window-function 'split-window-horizontally
        ediff-merge-split-window-function 'split-window-horizontally))

(use-package elec-pair
  ;; 钩子：在 Emacs 初始化完成后（after-init）
  ;; 作用：全局开启自动成对补全模式
  :hook (after-init . electric-pair-mode)
  :init
  ;; 变量设置：定义补全的“抑制（禁止）逻辑”
  ;; 'electric-pair-conservative-inhibit 是一个更聪明的判断函数
  ;; 它的作用是：如果你紧接着一个字母输入左括号，它就不会自动补全右括号
  ;; 比如：输入 'f(' 时，它保持原样；只有输入 ' ('（前面有空格）时，才会补全为 ' ()'
  (setq electric-pair-inhibit-predicate 'electric-pair-conservative-inhibit))


;; 实时预览（交互式）对齐。
(use-package ialign)

;; Edit multiple regions in the same way simultaneously
(use-package iedit
  :bind (:map global-map
         ("C-;" . iedit-mode)
         ("C-x r RET" . iedit-rectangle-mode)
         :map isearch-mode-map
         ("C-;" . iedit-mode-from-isearch)
         :map esc-map
         ("C-;" . iedit-execute-last-modification)
         :map help-map
         ("C-;" . iedit-mode-toggle-on-function)))

(use-package expand-region
  :functions treesit-buffer-root-node
  :bind ("C-c =" . er/expand-region)
  :config
  (defun treesit-mark-bigger-node ()
    "Use tree-sitter to mark regions."
    (let* ((root (treesit-buffer-root-node))
           (node (treesit-node-descendant-for-range root (region-beginning) (region-end)))
           (node-start (treesit-node-start node))
           (node-end (treesit-node-end node)))
      ;; Node fits the region exactly. Try its parent node instead.
      (when (and (= (region-beginning) node-start) (= (region-end) node-end))
        (when-let* ((node (treesit-node-parent node)))
          (setq node-start (treesit-node-start node)
                node-end (treesit-node-end node))))
      (set-mark node-end)
      (goto-char node-start)))
  (add-to-list 'er/try-expand-list 'treesit-mark-bigger-node))

;; Multiple cursors
(use-package multiple-cursors
  ;; --- 快捷键绑定 ---
  :bind (("C-c m" . multiple-cursors-hydra/body) ;; 呼出下方定义的 Hydra 直观菜单
         ("C-S-c C-S-c"   . mc/edit-lines)       ;; 将选中的每一行末尾都加上光标
         ("C->"           . mc/mark-next-like-this)      ;; 选中下一个与当前相同的文本
         ("C-<"           . mc/mark-previous-like-this)  ;; 选中上一个与当前相同的文本
         ("C-c C-<"       . mc/mark-all-like-this)       ;; 全选所有与当前相同的文本
         ("C-M->"         . mc/skip-to-next-like-this)   ;; 跳过当前，寻找下一个相同文本
         ("C-M-<"         . mc/skip-to-previous-like-this) ;; 跳过当前，寻找上一个相同文本
         ("s-<mouse-1>"   . mc/add-cursor-on-click)     ;; Super键+左键点击：在点击处添加光标
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)     ;; Ctrl+Shift+左键点击：在点击处添加光标
         :map mc/keymap ;; 当多光标激活时的特定键盘映射
         ("C-|" . mc/vertical-align-with-space))        ;; 对齐所有光标（用空格填充）

  ;; --- 可视化菜单配置 (Pretty-Hydra) ---
  :pretty-hydra
  ((:title (pretty-hydra-title "Multiple Cursors" 'mdicon "nf-md-cursor_move")
    :color amaranth :quit-key ("q" "C-g")) ;; amaranth颜色表示即使按了非绑定键也不会退出菜单
   ("向上标记"
    (("p" mc/mark-previous-like-this "上一个")
     ("P" mc/skip-to-previous-like-this "跳过并找上一个")
     ("M-p" mc/unmark-previous-like-this "取消上一个标记")
     ("|" mc/vertical-align "按输入字符对齐"))
    "向下标记"
    (("n" mc/mark-next-like-this "下一个")
     ("N" mc/skip-to-next-like-this "跳过并找下一个")
     ("M-n" mc/unmark-next-like-this "取消下一个标记"))
    "杂项"
    (("l" mc/edit-lines "编辑选中行" :exit t) ;; :exit t 表示执行后退出菜单
     ("a" mc/mark-all-like-this "全选相同项" :exit t)
     ("s" mc/mark-all-in-region-regexp "正则搜索标记" :exit t)
     ("<mouse-1>" mc/add-cursor-on-click "点击添加"))
    ;; 动态显示当前光标数量
    "% 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")"
    (("0" mc/insert-numbers "插入数字序列" :exit t)
     ("A" mc/insert-letters "插入字母序列" :exit t)))))


;; Smartly select region, rectangle, multi cursors
;; 增强ctrl+space
(use-package smart-region
  :hook (after-init . smart-region-on))


;; On-the-fly spell checker
;; (use-package jinx
;;   :hook (emacs-startup . global-jinx-mode)
;;   :config
;;   ;; 只开启美国英语，不加载其他语言
;;   (setq jinx-languages "en_US")
;;   :bind (("M-$" . jinx-correct)
;;          ("C-M-$" . jinx-languages)))

;; Hungry deletion
(use-package hungry-delete
  :diminish
  :hook (after-init . global-hungry-delete-mode)
  :init (setq hungry-delete-chars-to-skip " \t\f\v"
              hungry-delete-except-modes
              '(help-mode minibuffer-mode minibuffer-inactive-mode calc-mode)))


;; Move to the beginning/end of line or code
;; 增强Ctrl-a (行首) 和 Ctrl-e (行尾)
(use-package mwim
  :bind (([remap move-beginning-of-line] . mwim-beginning)
         ([remap move-end-of-line] . mwim-end)))

                                        ; 回退管理
(use-package vundo
  :bind ("C-x u" . vundo)
  :config (setq vundo-glyph-alist vundo-unicode-symbols))

                                        ; 跳转到上次修改的地方
(use-package goto-chg
  :bind ("C-," . goto-last-change))

;; 支持驼峰前进后退
(use-package subword
  :ensure nil
  :diminish
  :hook (prog-mode minibuffer-setup))

;; 代码折叠
;; Flexible text folding
(use-package treesit-fold
  :vc (:url "https://github.com/emacs-tree-sitter/treesit-fold")
  :ensure t
  :hook (prog-mode . treesit-fold-mode)
  :bind (("C-c f t" . treesit-fold-toggle)
         ("C-c f o" . treesit-fold-open)
         ("C-c f c" . treesit-fold-close)))
;; Copy&paste GUI clipboard from text terminal
(unless sys/win32p
  (use-package sudo-edit)
  (use-package xclip
    :hook (after-init . xclip-mode)
    :config
    ;; HACK: fix bug in xclip-mode on WSL
    (when (eq xclip-method 'powershell)
      (setq xclip-program "powershell.exe"))

    ;; @see https://github.com/microsoft/wslg/issues/15#issuecomment-1796195663
    (when (eq xclip-method 'wl-copy)
      (set-clipboard-coding-system 'gbk) ; for wsl
      (setq interprogram-cut-function
            (lambda (text)
              (start-process "xclip"  nil xclip-program "--trim-newline" "--type" "text/plain;charset=utf-8" text))))))

(use-package so-long
  :hook (after-init . global-so-long-mode))

;; Better performance via tramp
(use-package tramp-hlo
  :hook (after-init . tramp-hlo-setup))

(provide 'init-edit)
