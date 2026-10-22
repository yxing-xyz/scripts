;;; init-workspace.el --- Initialize workspace configurations.	-*- lexical-binding: t -*-

;;; Commentary:
;;
;; Workspace configurations.
;;

;;; Code:

(eval-when-compile
  (require 'init-custom))

(use-package project-x
  :custom
  ;; auto-save project state after 30 seconds of idle time
  (project-x-auto-save-delay 30) ; nil to disable autosave
  ;; use the custom prompter that shows session labels
  (project-prompter #'project-x--project-prompt)
  ;; automatically restore the last project on startup
  (project-x-restore-last-project-on-startup t)
  ;; not display tab bar
  (tab-bar-show nil)
  :hook
  (after-init     . project-x-mode)
  (project-x-mode . project-x-tabs-mode))

(provide 'init-workspace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-workspace.el ends here
