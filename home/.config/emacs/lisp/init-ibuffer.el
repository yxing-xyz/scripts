;;; ibuffer.el --- ibuffer -*- lexical-binding: t -*-

;; Author: Ethan
;; Maintainer: Ethan
;; Version: version
;; Package-Requires: (dependencies)
;; Homepage: homepage
;; Keywords: keywords


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; commentary

;;; Code:
(eval-when-compile
  (require 'init-custom))

(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer)
  :init (setq ibuffer-filter-group-name-face '(:inherit (font-lock-string-face bold))))

;; Display icons for buffers
(use-package nerd-icons-ibuffer
  :hook ibuffer-mode)

(use-package ibuffer-tramp
  :after ibuffer
  :config
  (add-hook 'ibuffer-hook
            (lambda ()
              (ibuffer-tramp-set-filter-groups-by-tramp-connection)
              (ibuffer-do-update))))

;; Group ibuffer's list by project
(use-package ibuffer-project
  :init
  (setq ibuffer-project-use-cache t)
  :config
  ;; 1. 将远程识别逻辑放在首位，全局只设一次
  (setq ibuffer-project-root-functions
        '((file-remote-p . "Remote")  ; 直接用 file-remote-p 更通用
          (ibuffer-project-project-root . "Project")))

  :hook (ibuffer . (lambda ()
                     "分组并有条件地排序。"
                     (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))

                     ;; 2. 只有当不是远程目录时，才自动执行相对路径排序
                     ;; 这样可以避免 Ibuffer 每次一打开就卡在那几秒
                     (unless (or (file-remote-p default-directory)
                                 (eq ibuffer-sorting-mode 'project-file-relative))
                       (ignore-errors
                         (ibuffer-do-sort-by-project-file-relative))))))

(provide 'init-ibuffer)
;;; init-buffer.el
