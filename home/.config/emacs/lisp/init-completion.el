;; -*- lexical-binding: t; -*-

;;; Code:
(eval-when-compile
  (require 'init-const))

(use-package orderless
  :custom
  ;; --- 核心搜索逻辑设定 ---
  ;; 设置补全风格：优先使用 orderless，如果匹配不到则回退到 basic（基本搜索）
  (completion-styles '(orderless basic))

  ;; --- 默认行为设定 ---
  ;; 清空默认的分类补全规则，确保全局尽可能统一使用 orderless 风格
  (completion-category-defaults nil)

  ;; --- 特殊场景覆盖 ---
  ;; 针对特定类型的补全进行“微调”
  ;; 这里指定：在搜索【文件】(file) 时，不使用无序匹配，而是使用：
  ;; 1. basic: 基础前缀匹配
  ;; 2. partial-completion: 部分补全（例如输入 /u/s/b 补全为 /usr/share/bin）
  ;; 理由：文件路径通常有严格的层级结构，乱序搜索反而容易干扰判断。
  (completion-category-overrides '((file (styles basic partial-completion))))

  ;; --- 分隔符设定 ---
  ;; 定义如何拆分你的搜索词。这里使用的是“空格拆分”：
  ;; 即你输入的每个空格都会把搜索词切分成一个独立的匹配因子。
  ;; 同时也支持“转义”，即如果你真想搜空格，可以用反斜杠转义。
  (orderless-component-separator #'orderless-escapable-split-on-space))

(use-package pinyinlib
  ;; 确保在 orderless 插件加载之后再执行，因为我们要扩展 orderless 的功能
  :after orderless

  ;; 声明外部函数，防止字节编译时报 "function not known" 的警告
  :functions orderless-regexp

  ;; 延迟加载：只有在调用这个函数时才真正加载 pinyinlib 库，加快启动速度
  :autoload pinyinlib-build-regexp-string

  :init
  ;; 定义一个新的匹配器：将输入的字符串转换为拼音正则表达式
  (defun orderless-regexp-pinyin (str)
    "将输入的字符串 STR 视为拼音，并构建对应的正则表达式进行匹配。"
    ;; 调用 pinyinlib 将 "nh" 变成 "[你拟泥...][好耗浩...]" 这种正则
    ;; 然后交给 orderless 的正则匹配引擎处理
    (orderless-regexp (pinyinlib-build-regexp-string str)))

  ;; 将上面定义的“拼音匹配法”添加到 orderless 的匹配样式列表中
  ;; 这样当你搜索时，Emacs 会自动尝试用拼音去匹配结果
  (add-to-list 'orderless-matching-styles 'orderless-regexp-pinyin))

;; 垂直列表
(use-package vertico
  ;; ---------------------------------------------------------
  ;; 自定义变量配置
  ;; ---------------------------------------------------------
  :custom
  (vertico-count 15)           ;; 设置补全列表显示的最大行数为 15 行

  ;; ---------------------------------------------------------
  ;; 按键绑定（主要针对 Minibuffer 内部的操作）
  ;; ---------------------------------------------------------
  :bind (:map vertico-map
         ;; 在文件路径补全时，按回车进入目录而非直接确认选定
         ("RET" . vertico-directory-enter)
         ;; 删除字符时，如果是路径分隔符（/），则智能删除整级目录
         ("DEL" . vertico-directory-delete-char)
         ;; 一次性删除一级目录名（比如将 /home/user/ 删至 /home/）
         ("M-DEL" . vertico-directory-delete-word))

  ;; ---------------------------------------------------------
  ;; 钩子函数（在特定时机自动执行）
  ;; ---------------------------------------------------------
  :hook (
         ;; Emacs 初始化完成后自动开启 vertico 模式
         (after-init . vertico-mode)

         ;; 路径清理钩子：当你通过输入绝对路径（如 / 或 ~/）来切换目录时，
         ;; 自动隐藏（Tidy）之前输入框中失效的路径部分，保持界面整洁
         (rfn-eshadow-update-overlay . vertico-directory-tidy)))


;; Enrich existing commands with completion annotations
(use-package marginalia
  :hook (after-init . marginalia-mode))

;; Add icons to completion candidates
(use-package nerd-icons-completion
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup))


;; Consulting completing-read
(use-package consult
  :defines (xref-show-xrefs-function xref-show-definitions-function)
  :defines shr-color-html-colors-alist
  :autoload (consult-register-format consult-register-window consult-xref)
  :autoload (consult--read consult--customize-put)
  :commands (consult-narrow-help)
  :functions (list-colors-duplicates consult-colors--web-list)
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h"   . consult-history)
         ("C-c k"   . consult-kmacro)
         ("C-c i"   . consult-info)
         ("C-c r"   . consult-ripgrep)
         ("C-c T"   . consult-theme)
         ("C-."     . consult-imenu)

         ("C-c c e" . consult-colors-emacs)
         ("C-c c w" . consult-colors-web)
         ("C-c c f" . describe-face)
         ("C-c c l" . find-library)
         ("C-c c t" . consult-theme)

         ([remap Info-search]        . consult-info)
         ([remap isearch-forward]    . consult-line)
         ([remap recentf-open-files] . consult-recent-file)

         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"   . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#"     . consult-register-load)
         ("M-'"     . consult-register-store)      ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#"   . consult-register)
         ;; Other custom bindings
         ("M-y"     . consult-yank-pop)            ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e"   . consult-compile-error)
         ("M-g f"   . consult-flymake)
         ("M-g g"   . consult-goto-line)           ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o"   . consult-outline)             ;; Alternative: consult-org-heading
         ("M-g m"   . consult-mark)
         ("M-g k"   . consult-global-mark)
         ("M-g i"   . consult-imenu)
         ("M-g I"   . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d"   . consult-find)
         ("M-s D"   . consult-locate)
         ("M-s g"   . consult-grep)
         ("M-s G"   . consult-git-grep)
         ("M-s r"   . consult-ripgrep)
         ("M-s l"   . consult-line)
         ("M-s L"   . consult-line-multi)
         ("M-s k"   . consult-keep-lines)
         ("M-s u"   . consult-focus-lines)
         ;; Isearch integration
         ("M-s e"   . consult-isearch-history)
         :map isearch-mode-map
         ("M-e"     . consult-isearch-history)      ;; orig. isearch-edit-string
         ("M-s e"   . consult-isearch-history)      ;; orig. isearch-edit-string
         ("M-s l"   . consult-line)                 ;; needed by consult-line to detect isearch
         ("M-s L"   . consult-line-multi)           ;; needed by consult-line to detect isearch

         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                  ;; orig. next-matching-history-element
         ("M-r" . consult-history))                 ;; orig. previous-matching-history-element
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (with-eval-after-load 'xref
    (setq xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref))

  ;; More utils
  (defvar consult-colors-history nil
    "History for `consult-colors-emacs' and `consult-colors-web'.")

  ;; No longer preloaded in Emacs 28.
  (autoload 'list-colors-duplicates "facemenu")
  ;; No preloaded in consult.el
  (autoload 'consult--read "consult")

  (defun consult-colors-emacs (color)
    "Show a list of all supported colors for a particular frame.

You can insert the name (default), or insert or kill the hexadecimal or RGB
value of the selected COLOR."
    (interactive
     (list (consult--read (list-colors-duplicates (defined-colors))
                          :prompt "Emacs color: "
                          :require-match t
                          :category 'color
                          :history '(:input consult-colors-history))))
    (insert color))

  ;; Adapted from counsel.el to get web colors.
  (defun consult-colors--web-list nil
    "Return list of CSS colors for `counsult-colors-web'."
    (require 'shr-color)
    (sort (mapcar #'downcase (mapcar #'car shr-color-html-colors-alist)) #'string-lessp))

  (defun consult-colors-web (color)
    "Show a list of all CSS colors.\

You can insert the name (default), or insert or kill the hexadecimal or RGB
value of the selected COLOR."
    (interactive
     (list (consult--read (consult-colors--web-list)
                          :prompt "Color: "
                          :require-match t
                          :category 'color
                          :history '(:input consult-colors-history))))
    (insert color))
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  (setq consult-preview-key nil)
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-line consult-line-multi :preview-key 'any
   consult-buffer consult-recent-file consult-theme :preview-key '(:debounce 1.0 any)
   consult-goto-line :preview-key '(:debounce 0.5 any)
   consult-ripgrep consult-git-grep consult-grep
   :initial (selected-region-or-symbol-at-point)
   :preview-key '(:debounce 0.5 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help))

(use-package consult-dir
  :ensure t
  :bind (
         ;; 1. 全局绑定：在任何地方按 C-x C-d 都会调用 consult-dir
         ("C-x C-d" . consult-dir)

         ;; 2. 切换作用域：接下来的绑定只在“小缓冲区的补全状态”下生效
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)
         ))


(use-package consult-yasnippet
  :ensure t
  :after (yasnippet consult)
  :bind ("M-g y" . consult-yasnippet))

(use-package embark
  :after (embark-consult)
  :commands embark-prefix-help-command
  :bind (("s-."   . embark-act)
         ("C-s-." . embark-act)
         ("M-."   . embark-dwim)        ; overrides `xref-find-definitions'
         ([remap describe-bindings] . embark-bindings)
         :map minibuffer-local-map
         ("M-." . my/embark-preview))
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Manual preview for non-Consult commands using Embark
  (defun my/embark-preview ()
    "Previews candidate in vertico buffer, unless it's a consult command."
    (interactive)
    (unless (bound-and-true-p consult--preview-function)
      (save-selected-window
        (let ((embark-quit-after-action nil))
          (embark-dwim)))))

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  (with-no-warnings
    (with-eval-after-load 'which-key
      (defun embark-which-key-indicator ()
        "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
        (lambda (&optional keymap targets prefix)
          (if (null keymap)
              (which-key--hide-popup-ignore-command)
            (which-key--show-keymap
             (if (eq (plist-get (car targets) :type) 'embark-become)
                 "Become"
               (format "Act on %s '%s'%s"
                       (plist-get (car targets) :type)
                       (embark--truncate-target (plist-get (car targets) :target))
                       (if (cdr targets) "…" "")))
             (if prefix
                 (pcase (lookup-key keymap prefix 'accept-default)
                   ((and (pred keymapp) km) km)
                   (_ (key-binding prefix 'accept-default)))
               keymap)
             nil nil t (lambda (binding)
                         (not (string-suffix-p "-argument" (cdr binding))))))))

      (setq embark-indicators
            '(embark-which-key-indicator
              embark-highlight-indicator
              embark-isearch-highlight-indicator))

      (defun embark-hide-which-key-indicator (fn &rest args)
        "Hide the which-key indicator immediately when using the completing-read prompter."
        (which-key--hide-popup-ignore-command)
        (let ((embark-indicators
               (remq #'embark-which-key-indicator embark-indicators)))
          (apply fn args)))

      (advice-add #'embark-completing-read-prompter
                  :around #'embark-hide-which-key-indicator))))

(use-package embark-consult
  :bind (:map minibuffer-mode-map
         ("C-c C-o" . embark-export)))



(use-package corfu
  :autoload (corfu-quit consult-completion-in-region)
  :functions (persistent-scratch-save corfu-move-to-minibuffer)
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-count 12)
  (corfu-preview-current nil)
  (corfu-on-exact-match nil)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.1 . 0.1))
  (global-corfu-modes '((not erc-mode
                             circe-mode
                             help-mode
                             gud-mode
                             vterm-mode)
                        t))
  :custom-face
  (corfu-border ((t (:inherit region :background unspecified))))
  :bind ("M-/" . completion-at-point)
  :hook ((after-init . global-corfu-mode)
         (global-corfu-mode . corfu-popupinfo-mode)
         (global-corfu-mode . corfu-history-mode))
  :config
  ;;Quit completion before saving
  (add-hook 'before-save-hook #'corfu-quit)
  (advice-add #'persistent-scratch-save :before #'corfu-quit)

  ;; Move completions to minibuffer
  (defun corfu-move-to-minibuffer ()
    (interactive)
    (pcase completion-in-region--data
      (`(,beg ,end ,table ,pred ,extras)
       (let ((completion-extra-properties extras)
             completion-cycle-threshold completion-cycling)
         (consult-completion-in-region beg end table pred)))))
  (keymap-set corfu-map "M-m" #'corfu-move-to-minibuffer)
  (add-to-list 'corfu-continue-commands #'corfu-move-to-minibuffer))

(unless (or (display-graphic-p)
            (featurep 'tty-child-frames))
  (use-package corfu-terminal
    :hook (global-corfu-mode . corfu-terminal-mode)))

(use-package nerd-icons-corfu
  :autoload nerd-icons-corfu-formatter
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Add extensions
(use-package cape
  :commands (cape-file cape-elisp-block cape-keyword)
  :autoload (cape-wrap-noninterruptible cape-wrap-nonexclusive cape-wrap-buster)
  :autoload (cape-wrap-silent)
  :init
  ;; (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;; (add-to-list 'completion-at-point-functions #'cape-abbrev)

  ;; Make these capfs composable.
  (advice-add 'lsp-completion-at-point :around #'cape-wrap-noninterruptible)
  (advice-add 'lsp-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add 'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-nonexclusive))

(provide 'init-completion)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-completion.el ends here
