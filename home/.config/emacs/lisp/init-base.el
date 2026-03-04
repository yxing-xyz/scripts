;; -*- lexical-binding: t; -*-


;;; Code:
(eval-when-compile
  (require 'init-const))

(setq user-full-name xx-full-name
      user-mail-address xx-mail-address)

;; Compatibility
(use-package compat :demand t)

;; 禁止linux X参数
(setq command-line-x-option-alist nil)
;; 控制 Emacs 单次从子进程（subprocess） 读取输出的最大字节数
(setq read-process-output-max #x100000)
;; 彻底禁用 FFAP 对 “远程机器路径” 的识别和处理
(setq ffap-machine-p-known 'reject)

;; gc
(use-package gcmh
  :diminish
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

;; Misc.
(use-package simple
  :diminish visual-line-mode
  :ensure nil
  :hook ((after-init . size-indication-mode)
         ;; (text-mode . visual-line-mode) 取消自动换行显示
         ((prog-mode markdown-mode conf-mode) . enable-trailing-whitespace))
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
(blink-cursor-mode -1) ;; 光标禁止闪烁

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


(defface posframe-border
  `((t (:inherit region)))
  "Face used by the `posframe' border."
  :group 'posframe)
(defvar posframe-border-width 2
  "Default posframe border width.")


(use-package posframe
  :custom-face
  (child-frame-border ((t (:inherit posframe-border))))
  :hook (after-load-theme . posframe-delete-all)
  :init
  (defface posframe-border
    `((t (:inherit region)))
    "Face used by the `posframe' border."
    :group 'posframe)
  (defvar posframe-border-width 2
    "Default posframe border width.")
  :config
  (with-no-warnings
    (defun my/posframe--prettify-frame (&rest _)
      (set-face-background 'fringe nil posframe--frame))
    (advice-add #'posframe--create-posframe :after #'my/posframe--prettify-frame)

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

;; window

;; Directional window-selection routines
(use-package windmove
  :ensure nil
  :bind (("M-h" . windmove-left)   ; Alt + h 向左
         ("M-j" . windmove-down)   ; Alt + j 向下
         ("M-k" . windmove-up)     ; Alt + k 向上
         ("M-l" . windmove-right)) ; Alt + l 向右
  ;; 保持你之前的 window-setup hook 以确保布局加载后生效（可选）
  :hook (window-setup . windmove-mode))

;; Quickly switch windows
(use-package ace-window
  :pretty-hydra
  ((:title (pretty-hydra-title "Window Management" 'faicon "nf-fa-th")
    :foreign-keys warn :quit-key ("q" "C-g"))
   ("Actions"
    (("TAB" other-window "switch")
     ("x" ace-delete-window "delete")
     ("X" ace-delete-other-windows "delete other" :exit t)
     ("s" ace-swap-window "swap")
     ("a" ace-select-window "select" :exit t)
     ("m" toggle-frame-maximized "maximize" :exit t)
     ("u" toggle-frame-fullscreen "fullscreen" :exit t))
    "Resize"
    (("h" shrink-window-horizontally "←")
     ("j" enlarge-window "↓")
     ("k" shrink-window "↑")
     ("l" enlarge-window-horizontally "→")
     ("n" balance-windows "balance"))
    "Split"
    (("r" split-window-right "horizontally")
     ("R" split-window-horizontally-instead "horizontally instead")
     ("v" split-window-below "vertically")
     ("V" split-window-vertically-instead "vertically instead")
     ("t" toggle-window-split "toggle"))
    "Zoom"
    (("+" text-scale-increase "in")
     ("=" text-scale-increase "in")
     ("-" text-scale-decrease "out")
     ("0" (text-scale-increase 0) "reset"))
    "Misc"
    (("o" set-frame-font "frame font")
     ("f" make-frame-command "new frame")
     ("d" delete-frame "delete frame")
     ("<left>" tab-bar-history-back "previous layout")
     ("<right>" tab-bar-history-back "next layout"))))
  :custom-face
  (aw-leading-char-face ((t (:inherit font-lock-keyword-face :foreground unspecified :bold t :height 3.0))))
  (aw-minibuffer-leading-char-face ((t (:inherit font-lock-keyword-face :bold t :height 1.0))))
  (aw-mode-line-face ((t (:inherit mode-line-emphasis :bold t))))
  :bind (([remap other-window] . ace-window)
         ("C-c w" . ace-window-hydra/body)
         ("C-x |" . split-window-horizontally-instead)
         ("C-x _" . split-window-vertically-instead))
  :config
  (defun toggle-window-split ()
    (interactive)
    (if (= (count-windows) 2)
        (let* ((this-win-buffer (window-buffer))
               (next-win-buffer (window-buffer (next-window)))
               (this-win-edges (window-edges (selected-window)))
               (next-win-edges (window-edges (next-window)))
               (this-win-2nd (not (and (<= (car this-win-edges)
                                           (car next-win-edges))
                                       (<= (cadr this-win-edges)
                                           (cadr next-win-edges)))))
               (splitter
                (if (= (car this-win-edges)
                       (car (window-edges (next-window))))
                    'split-window-horizontally
                  'split-window-vertically)))
          (delete-other-windows)
          (let ((first-win (selected-window)))
            (funcall splitter)
            (if this-win-2nd (other-window 1))
            (set-window-buffer (selected-window) this-win-buffer)
            (set-window-buffer (next-window) next-win-buffer)
            (select-window first-win)
            (if this-win-2nd (other-window 1))))
      (user-error "`toggle-window-split' only supports two windows")))

  ;; Bind hydra to dispatch list
  (add-to-list 'aw-dispatch-alist '(?w ace-window-hydra/body) t))

;; Enforce rules for popups
(use-package popper
  :after project
  :demand t
  :custom
  (popper-group-function #'popper-group-by-project)
  (popper-echo-dispatch-actions t)
  :bind (:map popper-mode-map
         ("C-h z"       . popper-toggle)
         ("C-<tab>"     . popper-cycle)
         ("C-M-<tab>"   . popper-toggle-type))
  :init
  (setq popper-mode-line ""
        popper-reference-buffers
        '("\\*Messages\\*$"
          "Output\\*$" "\\*Pp Eval Output\\*$"
          "^\\*eldoc.*\\*$"
          "\\*Compile-Log\\*$"
          "\\*Completions\\*$"
          "\\*Warnings\\*$"
          "\\*Async Shell Command\\*$"
          "\\*Apropos\\*$"
          "\\*Backtrace\\*$"
          "\\*Calendar\\*$"
          "\\*Fd\\*$" "\\*Find\\*$" "\\*Finder\\*$"
          "\\*Kill Ring\\*$"
          "\\*Embark \\(Collect\\|Live\\):.*\\*$"

          bookmark-bmenu-mode
          comint-mode
          compilation-mode
          help-mode helpful-mode
          tabulated-list-mode
          Buffer-menu-mode

          flymake-diagnostics-buffer-mode
          gnus-article-mode devdocs-mode
          grep-mode occur-mode rg-mode

          osx-dictionary-mode fanyi-mode
          "^\\*gt-result\\*$" "^\\*gt-log\\*$"
          "^\\*Process List\\*$" process-menu-mode cargo-process-mode

          "^\\*.*eat.*\\*.*$" eat-mode
          "^\\*.*eshell.*\\*.*$" eshell-mode
          "^\\*.*shell.*\\*.*$" shell-mode
          "^\\*.*terminal.*\\*.*$" term-mode
          "^\\*.*vterm[inal]*.*\\*.*$" vterm-mode

          "\\*DAP Templates\\*$" dap-server-log-mode
          "\\*ELP Profiling Results\\*" profiler-report-mode
          "\\*package update results\\*$" "\\*Package-Lint\\*$"
          "\\*[Wo]*Man.*\\*$"
          "\\*ert\\*$"
          "\\*gud-debug\\*$"
          "\\*lsp-help\\*$" "\\*lsp session\\*$"
          "\\*quickrun\\*$"
          "\\*vc-.*\\**"
          "\\*diff-hl\\**"
          "^\\*macro expansion\\**"

          "\\*Agenda Commands\\*" "\\*Org Select\\*" "\\*Capture\\*" "^CAPTURE-.*\\.org*"
          "\\*Gofmt Errors\\*$" "\\*Go Test\\*$" godoc-mode
          "\\*docker-.+\\*" "\\*prolog\\*" "\\*rustfmt\\*$"
          inferior-python-mode inf-ruby-mode swift-repl-mode))
  :config
  (with-no-warnings
    (defun my/popper-fit-window-height (win)
      "Adjust the height of popup window WIN to fit the buffer's content."
      (let ((desired-height (floor (/ (frame-height) 3))))
        (fit-window-to-buffer win desired-height desired-height)))
    (setq popper-window-height #'my/popper-fit-window-height)

    (defun popper-close-window-hack (&rest _args)
      "Close popper window via `C-g'."
      (when (and ; (called-interactively-p 'interactive)
             (not (region-active-p))
             popper-open-popup-alist)
        (let ((window (caar popper-open-popup-alist))
              (buffer (cdar popper-open-popup-alist)))
          (when (and (window-live-p window)
                     (buffer-live-p buffer)
                     (not (with-current-buffer buffer
                            (derived-mode-p 'eshell-mode
                                            'shell-mode
                                            'term-mode
                                            'vterm-mode))))
            (delete-window window)))))
    (advice-add #'keyboard-quit :before #'popper-close-window-hack)
    (popper-mode 1)
    (popper-tab-line-mode 1)))

;; Display available keybindings in popup
(use-package which-key
  :diminish
  :bind ("C-h M-m" . which-key-show-major-mode)
  :hook (after-init . which-key-mode)
  :init (setq which-key-max-description-length 30
              which-key-lighter nil
              which-key-show-remaining-keys t)
  :config
  ;; Key prefix descriptions
  (dolist (map '(("M-s h" . "highlight")
                 ("M-s s" . "symbol-overlay")
                 ("C-c &" . "yasnippet")
                 ("C-c @" . "hideshow")
                 ("C-c c" . "consult")
                 ("C-c d" . "dict")
                 ("C-c l" . "link-hint")
                 ("C-c n" . "org-roam")
                 ("C-c o" . "org")
                 ("C-c t" . "hl-todo")
                 ("C-c C-a" . "activities")
                 ("C-c C-z" . "browse")
                 ("C-x 8" . "unicode")
                 ("C-x 8 e" . "emoji")
                 ("C-x @" . "modifior")
                 ("C-x a" . "abbrev")
                 ("C-x c" . "colorful")
                 ("C-x n" . "narrow")
                 ("C-x p" . "project")
                 ("C-x r" . "rect & bookmark")
                 ("C-x t" . "tab & treemacs")
                 ("C-x w" . "window & highlight")
                 ("C-x w ^" . "window")
                 ("C-x C-a" . "edebug")
                 ("C-x RET" . "coding-system")
                 ("C-x X" . "edebug")
                 ("C-x v b" . "vc-branch")
                 ("C-x v M" . "vc-mergebase")))
    (which-key-add-key-based-replacements (car map) (cdr map)))

  ;; Mode-specific key replacements
  (dolist (mode-map '((org-mode
                       ("C-c \"" . "org-plot")
                       ("C-c C-v" . "org-babel")
                       ("C-c C-x" . "org-misc"))
                      (python-mode
                       ("C-c C-t" . "python-skeleton"))
                      (markdown-mode
                       ("C-c C-a" . "markdown-link")
                       ("C-c C-c" . "markdown-command")
                       ("C-c C-s" . "markdown-style")
                       ("C-c C-t" . "markdown-header")
                       ("C-c C-x" . "markdown-toggle"))
                      (gfm-mode
                       ("C-c C-a" . "markdown-link")
                       ("C-c C-c" . "markdown-command")
                       ("C-c C-s" . "markdown-style")
                       ("C-c C-t" . "markdown-header")
                       ("C-c C-x" . "markdown-toggle"))))
    (let ((mode (car mode-map))
          (maps (cdr mode-map)))
      (dolist (map maps)
        (which-key-add-major-mode-key-based-replacements
          mode (car map) (cdr map))))))

;; Search tools
(use-package grep
  :ensure nil
  :autoload grep-apply-setting
  :init
  (when (executable-find "rg")
    (grep-apply-setting
     'grep-command "rg --color=auto --null -nH --no-heading -e ")
    (grep-apply-setting
     'grep-template "rg --color=auto --null --no-heading -g '!*/' -e <R> <D>")
    (grep-apply-setting
     'grep-find-command '("rg --color=auto --null -nH --no-heading -e ''" . 38))
    (grep-apply-setting
     'grep-find-template "rg --color=auto --null -nH --no-heading -e <R> <D>")))

;; Writable `grep' buffer
(use-package wgrep
  :init (setq wgrep-auto-save-buffer t
              wgrep-change-readonly-file t))

;; Fast search tool `ripgrep'
(use-package rg
  :hook (after-init . rg-enable-default-bindings)
  :bind (:map rg-global-map
         ("c" . rg-dwim-current-dir)
         ("f" . rg-dwim-current-file)
         ("m" . rg-menu))
  :init (setq rg-show-columns t)
  :config (add-to-list 'rg-custom-type-aliases '("tmpl" . "*.tmpl")))

(use-package proced
  :ensure nil
  :init
  (setq-default proced-format 'verbose)
  (setq proced-auto-update-flag t
        proced-auto-update-interval 3
        proced-enable-color-flag t))

;; Search
(use-package webjump
  :ensure nil
  :bind ("C-c /" . webjump)
  :init (setq webjump-sites
              '(;; Emacs
                ("Emacs Home Page" .
                 "www.gnu.org/software/emacs/emacs.html")
                ("Xah Emacs Site" . "ergoemacs.org/index.html")
                ("(or emacs irrelevant)" . "oremacs.com")
                ("Mastering Emacs" .
                 "https://www.masteringemacs.org/")

                ;; Search engines.
                ("DuckDuckGo" .
                 [simple-query "duckduckgo.com"
                               "duckduckgo.com/?q=" ""])
                ("Google" .
                 [simple-query "www.google.com"
                               "www.google.com/search?q=" ""])
                ("Bing" .
                 [simple-query "www.bing.com"
                               "www.bing.com/search?q=" ""])

                ("Baidu" .
                 [simple-query "www.baidu.com"
                               "www.baidu.com/s?wd=" ""])
                ("Wikipedia" .
                 [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""]))))

;; 文件信息
(use-package file-info
  :bind ("C-c c i" . file-info-show))

;; 打开文件管理器
(use-package reveal-in-folder)

(provide 'init-base)

;;; init-base.el ends here
