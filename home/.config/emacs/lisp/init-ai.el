;; init-ai.el --- Initialize AI configurations.	-*- lexical-binding: t -*-

;;; Commentary:
;;
;; AI configurations.
;;

;;; Code:

(eval-when-compile
  (require 'init-const))

;; Interact with ChatGPT or other LLMs
;;
;; API Key management via authinfo (no plain-text secrets):
;;   machine api.deepseek.com               login api-key password <ds_key>
;;   machine api.anthropic.com              login api-key password <claude_key>
;;
(use-package gptel
  :functions (gptel-make-openai gptel-make-deepseek
                                gptel-make-anthropic gptel-make-gemini)
  :autoload gptel-get-backend
  :bind (("C-<f12>"   . gptel)
         ("C-M-<f12>" . gptel-menu)
         ("C-c a g"   . gptel)
         ("C-c a G"   . gptel-menu))
  :hook (gptel-mode . gptel-highlight-mode)
  :config
  ;; DeepSeek
  (gptel-make-deepseek "DeepSeek"
                       :stream t
                       :key 'gptel-api-key)

  ;; GLM
  (gptel-make-openai "GLM"
                     :host "open.bigmodel.cn"
                     :endpoint "/api/paas/v4/chat/completions"
                     :stream t
                     :key 'gptel-api-key
                     :models '(glm-5.3 glm-5.3-flash glm-4.7 glm-4.7-flash))

  ;; Qwen (Alibaba Cloud)
  (gptel-make-openai "Qwen"
                     :host "dashscope.aliyuncs.com"
                     :endpoint "/compatible-mode/v1/chat/completions"
                     :stream t
                     :key 'gptel-api-key
                     :models '(qwen-plus qwen-turbo qwen-max))

  ;; Kimi (Moonshot)
  (gptel-make-openai "Kimi"
                     :host "api.moonshot.cn" ;; or "api.moonshot.ai" for the global site
                     :key 'gptel-api-key
                     :stream t
                     :models '(kimi-k3 kimi-k2.7-code kimi-k2.7-code-highspeed kimi-k2.6))

  ;; Gemini (Google)
  (gptel-make-gemini "Gemini"
                     :key 'gptel-api-key
                     :stream t)

  ;; Claude (Anthropic)
  (gptel-make-anthropic "Claude"
                        :stream t
                        :key 'gptel-api-key)

  ;; Set default model and backend
  (setq gptel-model 'deepseek-flash
        gptel-backend (gptel-get-backend "DeepSeek")))

  ;; Generate commit messages for magit
  (use-package gptel-magit
    :vc (:url "https://github.com/roife/gptel-magit" :rev :newest)
    :hook (magit-mode . gptel-magit-install))

  ;; A native shell experience to interact with ACP agents
(use-package agent-shell
  :commands agent-shell-insert
  :defines magit-mode-map
  :functions (magit-staged-files magit-commit-p magit-thing-at-point)
  :custom (agent-shell-display-action '(display-buffer-reuse-window))
  :bind (("<f12>"      . agent-shell)
         ("<f13>"      . agent-shell)
         ("C-c a a"    . agent-shell)
         ("C-c a A"    . agent-shell-new-shell)
         :map agent-shell-mode-map
         ("C-h ?"      . agent-shell-help-menu)
         ("C-<return>" . agent-shell-help-menu))
  :config
  (with-no-warnings
    ;; Integrate into magit
    (with-eval-after-load 'magit
      (defun xx-generate-commit ()
        "Generate conventional commit message from staged changes."
        (interactive)
        (if (magit-staged-files)
            (agent-shell-insert
             :submit t
             :text "Commit changes with conventional message")
          (user-error "No staged changes")))

      (defun xx-review-commit ()
        "Send the commit at point to agent-shell for review."
        (interactive)
        (if-let* ((commit (magit-commit-p (magit-thing-at-point 'git-revision t))))
            (agent-shell-insert
             :submit t
             :text (format "Review commit: %s" commit))
          (user-error "No magit commit at point")))

      (bind-keys :map magit-mode-map
                 ("C-c C-g" . xx-generate-commit)
                 ("C-c C-r" . xx-review-commit)))))

(provide 'init-ai)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-ai.el ends here
