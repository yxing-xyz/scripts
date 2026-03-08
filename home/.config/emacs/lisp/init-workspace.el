;; -*- lexical-binding: t; -*-

;;; Code:

(eval-when-compile
  (require 'init-custom))

(defun my/project-find-root (dir)
  "在 DIR 中寻找 go.mod 或 .project 文件，将其识别为项目根目录。"
  (let* ((files '("go.mod" ".project"))
         ;; 寻找列表中任意一个文件所在的目录
         (root (cl-some (lambda (f) (locate-dominating-file dir f)) files)))
    (when root
      (cons 'transient root))))

;; 确保在 project.el 加载后注入
(with-eval-after-load 'project
  (add-hook 'project-find-functions #'my/project-find-root))


(use-package tabspaces
  :bind (:map tabspaces-command-map
         ("C-r"   . tabspaces-restore-session)
         ("C-S-r" . tabspaces-restore-session-alt)
         ("C-s"   . tabspaces-save-session)
         ("C-w"   . tabspaces-save-current-project-session))
  :hook ((after-init . tabspaces-mode)
         (tabspaces-mode . tab-bar-history-mode))
  :custom
  (tab-bar-show nil)
  (tab-bar-history-limit 30)
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Default")
  (tabspaces-remove-to-default t)
  (tabspaces-exclude-buffers '("*eat*" "*vterm*" "*shell*" "*eshell*"))
  (tabspaces-include-buffers '("*scratch*"))
  (tab-bar-new-tab-choice "*scratch*")
  (tabspaces-fully-resolve-paths t)
  ;; project todo
  (tabspaces-initialize-project-with-todo t)
  (tabspaces-todo-file-name "project-todo.org")
  ;; sessions
  (tabspaces-session t)
  (tabspaces-session-auto-restore t)
  (tabspaces-session-file (concat user-emacs-directory "tabspaces/tabsession.el"))
  (tabspaces-session-project-session-store (concat user-emacs-directory "tabspaces/"))

  :config
  ;; --- 1. 项目切换逻辑覆盖 ---
  (with-eval-after-load 'project
    (keymap-set project-prefix-map "p" #'tabspaces-open-or-create-project-and-workspace))

    ;; --- 2. Consult 数据源定义 ---
    (with-eval-after-load 'consult
      ;; hide full buffer list (still available with "b" prefix)
      (plist-put consult-source-buffer :hidden t)
      (plist-put consult-source-buffer :default nil)
      ;; set consult-workspace buffer list
      (defvar consult--source-workspace
        (list :name     "Workspace Buffers"
              :narrow   ?w
              :history  'buffer-name-history
              :category 'buffer
              :state    #'consult--buffer-state
              :default  t
              :items    (lambda () (consult--buffer-query
                                    :predicate #'tabspaces--local-buffer-p
                                    :sort 'visibility
                                    :as #'buffer-name)))

        "Set workspace buffer list for consult-buffer.")
      (add-to-list 'consult-buffer-sources 'consult--source-workspace)))


  ;; 配合direnv allow实现emacs自动进入开发环境
  (use-package envrc
    :hook (after-init . envrc-global-mode))
  (provide 'init-workspace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-workspace.el ends here
