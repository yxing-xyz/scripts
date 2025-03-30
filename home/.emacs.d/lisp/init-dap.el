;; init-dap.el --- Initialize DAP configurations.	-*- lexical-binding: t -*-

;;; Code:

(eval-when-compile
  (require 'init-const))

(when emacs/>=29p
  (use-package dape
    :bind (("<f5>" . dape)
           ("M-<f5>" . dape-hydra/body))
    :custom (dape-buffer-window-arrangment 'right)
    :pretty-hydra
    ((:title (pretty-hydra-title "Debug" 'codicon "nf-cod-debug")
      :color pink :quit-key ("q" "C-g"))
     ("Stepping"
      (("n" dape-next "next")
       ("s" dape-step-in "step in")
       ("o" dape-step-out "step out")
       ("c" dape-continue "continue")
       ("p" dape-pause "pause")
       ("k" dape-kill "kill")
       ("r" dape-restart "restart")
       ("D" dape-disconnect-quit "disconnect"))
      "Switch"
      (("m" dape-read-memory "memory")
       ("t" dape-select-thread "thread")
       ("w" dape-watch-dwim "watch")
       ("S" dape-select-stack "stack")
       ("i" dape-info "info")
       ("R" dape-repl "repl"))
      "Breakpoints"
      (("b" dape-breakpoint-toggle "toggle")
       ("l" dape-breakpoint-log "log")
       ("e" dape-breakpoint-expression "expression")
       ("B" dape-breakpoint-remove-all "clear"))
      "Debug"
      (("d" dape "dape")
       ("Q" dape-quit "quit" :exit t))))
    :config
    ;; Save buffers on startup, useful for interpreted languages
    (add-hook 'dape-on-start-hooks
              (defun dape--save-on-start ()
                (save-some-buffers t t)))
    ;; Display hydra on startup
    (add-hook 'dape-on-start-hooks #'dape-hydra/body)))

(provide 'init-dap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-dap.el ends here
