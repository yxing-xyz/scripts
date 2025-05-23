;; init-window.el --- Initialize window configurations.	-*- lexical-binding: t -*-

;;; Code


;; directional window-selection routines
(use-package windmove :ensure nil
  :bind (
         ("M-h" . windmove-left)
         ("M-l" . windmove-right)
         ("M-k" . windmove-up)
         ("M-j" . windmove-down)))

;; Restore old window configurations
(use-package winner
  :ensure nil
  :commands (winner-undo winner-redo)
  :hook (after-init . winner-mode)
  :init (setq winner-boring-buffers '("*Completions*"
                                      "*Compile-Log*"
                                      "*inferior-lisp*"
                                      "*Fuzzy Completions*"
                                      "*Apropos*"
                                      "*Help*"
                                      "*cvs*"
                                      "*Buffer List*"
                                      "*Ibuffer*"
                                      "*esh command on file*")))

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
     ("a" ace-select-window "select" :exit t))
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
    (("<left>" winner-undo "winner undo")
     ("<right>" winner-redo "winner redo")
     ("T" xx-load-theme "theme"))))
  :custom-face
  (aw-leading-char-face ((t (:inherit font-lock-keyword-face :foreground unspecified :bold t :height 3.0))))
  (aw-minibuffer-leading-char-face ((t (:inherit font-lock-keyword-face :bold t :height 1.0))))
  (aw-mode-line-face ((t (:inherit mode-line-emphasis :bold t))))
  :bind (([remap other-window] . ace-window)
         ("C-c w" . ace-window-hydra/body))
  :hook (emacs-startup . ace-window-display-mode)
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
  :custom
  (popper-group-function #'popper-group-by-directory)
  (popper-echo-dispatch-actions t)
  :bind (:map popper-mode-map
         ("C-h z"     . popper-toggle)
         ("C-<tab>"   . popper-cycle)
         ("C-M-<tab>" . popper-toggle-type))
  :hook (emacs-startup . popper-echo-mode)
  :init
  (setq   popper-mode-line ""
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
            flycheck-error-list-mode flycheck-verify-mode

            gnus-article-mode devdocs-mode
            grep-mode occur-mode rg-mode deadgrep-mode ag-mode pt-mode
            youdao-dictionary-mode osx-dictionary-mode fanyi-mode
            "^\\*gt-result\\*$" "^\\*gt-log\\*$"


            "^\\*Process List\\*$" process-menu-mode
            list-environment-mode cargo-process-mode

            "^\\*.*eshell.*\\*.*$"
            "^\\*.*shell.*\\*.*$"
            "^\\*.*terminal.*\\*.*$"
            "^\\*.*vterm[inal]*.*\\*.*$"

            "\\*DAP Templates\\*$" dap-server-log-mode
            "\\*ELP Profiling Restuls\\*" profiler-report-mode
            "\\*Paradox Report\\*$" "\\*package update results\\*$" "\\*Package-Lint\\*$"
            "\\*[Wo]*Man.*\\*$"
            "\\*ert\\*$" overseer-buffer-mode
            "\\*gud-debug\\*$"
            "\\*lsp-help\\*$" "\\*lsp session\\*$"
            "\\*quickrun\\*$"
            "\\*tldr\\*$"
            "\\*vc-.*\\**"
            "\\*diff-hl\\**"
            "^\\*macro expansion\\**"

            "\\*Agenda Commands\\*" "\\*Org Select\\*" "\\*Capture\\*" "^CAPTURE-.*\\.org*"
            "\\*Gofmt Errors\\*$" "\\*Go Test\\*$" godoc-mode
            "\\*docker-.+\\*"
            "\\*prolog\\*" inferior-python-mode inf-ruby-mode swift-repl-mode
            "\\*rustfmt\\*$" rustic-compilation-mode rustic-cargo-clippy-mode
            rustic-cargo-outdated-mode rustic-cargo-run-mode rustic-cargo-test-mode))

  :config
  (with-no-warnings
    (defun my-popper-fit-window-height (win)
      "Adjust the height of popup window WIN to fit the buffer's content."
      (let ((desired-height (floor (/ (frame-height) 3))))
        (fit-window-to-buffer win desired-height desired-height)))
    (setq popper-window-height #'my-popper-fit-window-height)

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
    (advice-add #'keyboard-quit :before #'popper-close-window-hack)))

(provide 'init-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-window.el ends here
