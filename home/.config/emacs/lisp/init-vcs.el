;; -*- lexical-binding: t -*-

;;; Code:

(eval-when-compile
  (require 'init-const))

;; Magit
;; See `magit-define-global-key-bindings'
(use-package magit
  :custom
  (magit-diff-refine-hunk t)
  (git-commit-major-mode 'git-commit-elisp-text-mode)
  :hook (git-commit-setup . (lambda () (setq fill-column git-commit-summary-max-length)))
  :config
  (when sys/win32p
    (setenv "GIT_ASKPASS" "git-gui--askpass")))

;; Prime cache before Magit refresh
(use-package magit-prime
  :diminish
  :hook after-init)

;; Show TODOs in Magit
(use-package magit-todos
  :after magit-status
  :commands magit-todos-mode
  :init
  (setq magit-todos-nice (if (executable-find "nice") t nil))
  (magit-todos-mode 1))

;; Walk through git revisions of a file
(use-package git-timemachine
  :custom-face
  (git-timemachine-minibuffer-author-face ((t (:inherit success :foreground unspecified))))
  (git-timemachine-minibuffer-detail-face ((t (:inherit warning :foreground unspecified))))
  :bind (:map vc-prefix-map
         ("t" . git-timemachine))
  :hook ((git-timemachine-mode . (lambda ()
                                   "Improve `git-timemachine' buffers."
                                   ;; Highlight symbols in elisp
                                   (when (derived-mode-p 'emacs-lisp-mode)
                                     (and (fboundp 'highlight-defined-mode)
                                          (highlight-defined-mode t)))

                                   ;; Display line numbers
                                   (when (derived-mode-p 'prog-mode 'yaml-mode 'yaml-ts-mode)
                                     (and (fboundp 'display-line-numbers-mode)
                                          (display-line-numbers-mode t)))))
         (before-revert . (lambda ()
                            (when (bound-and-true-p git-timemachine-mode)
                              (user-error "Cannot revert the timemachine buffer"))))))

;; Pop up last commit information of current line
(use-package git-messenger
  :bind (:map vc-prefix-map
         ("p" . git-messenger:popup-message)
         :map git-messenger-map
         ("m" . git-messenger:copy-message))
  :init (setq git-messenger:show-detail t
              git-messenger:use-magit-popup t))

;; Resolve diff3 conflicts
(use-package smerge-mode
  :ensure nil
  :diminish
  :pretty-hydra
  ((:title (pretty-hydra-title "Smerge" 'octicon "nf-oct-diff")
    :color pink :quit-key ("q" "C-g"))
   ("Move"
    (("n" smerge-next "next")
     ("p" smerge-prev "previous"))
    "Keep"
    (("b" smerge-keep-base "base")
     ("u" smerge-keep-upper "upper")
     ("l" smerge-keep-lower "lower")
     ("a" smerge-keep-all "all")
     ("RET" smerge-keep-current "current")
     ("C-m" smerge-keep-current "current"))
    "Diff"
    (("<" smerge-diff-base-upper "upper/base")
     ("=" smerge-diff-upper-lower "upper/lower")
     (">" smerge-diff-base-lower "upper/lower")
     ("R" smerge-refine "refine")
     ("E" smerge-ediff "ediff"))
    "Other"
    (("C" smerge-combine-with-next "combine")
     ("r" smerge-resolve "resolve")
     ("k" smerge-kill-current "kill")
     ("ZZ" (lambda ()
             (interactive)
             (save-buffer)
             (bury-buffer))
      "Save and bury buffer" :exit t))))
  :bind (:map smerge-mode-map
         ("C-c m" . smerge-mode-hydra/body))
  :hook ((find-file . (lambda ()
                        (save-excursion
                          (goto-char (point-min))
                          (when (re-search-forward "^<<<<<<< " nil t)
                            (smerge-mode 1)))))
         (magit-diff-visit-file . (lambda ()
                                    (when smerge-mode
                                      (smerge-mode-hydra/body))))))

;; Open github/gitlab/bitbucket page
(use-package browse-at-remote
  :bind (:map vc-prefix-map
         ("B" . browse-at-remote)))

;; Get git URL for a buffer location
(defun git-link-gitee (hostname dirname filename branch commit start end)
  "为 Gitee 生成链接。参数由 git-link 自动传递。"
  (format "%s/%s/blob/%s/%s%s"
          hostname
          dirname
          (or branch commit)
          filename
          (if start
              (concat "#L" (number-to-string start)
                      (if end (concat "-L" (number-to-string end)) ""))
            "")))

(use-package git-link
  :ensure t
  :config
  (add-to-list 'git-link-remote-alist '("gitee\\.com" git-link-gitee))
  (setq git-link-open-in-browser t))

;; Git configuration modes
(use-package git-modes)

(provide 'init-vcs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-vcs.el ends here
