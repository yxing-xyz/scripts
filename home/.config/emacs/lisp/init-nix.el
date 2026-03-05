;;; init-nix.el --- nix -*- lexical-binding: t -*-

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

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'"
  :preface
  (defun my/setup-nix-grammar ()
    "如果缺少 nix grammar，则自动下载并安装。"
    (when (and (fboundp 'treesit-available-p)
               (treesit-available-p)
               (not (treesit-language-available-p 'nix)))
      (treesit-install-language-grammar 'nix)))

  :init
  ;; 设置语法源
  (setq treesit-language-source-alist
        '((nix "https://github.com/nix-community/tree-sitter-nix")))

  ;; 自动安装解析器
  (add-hook 'nix-ts-mode-hook #'my/setup-nix-grammar)

  :config
  ;; 开启默认的缩进支持
  (setq nix-ts-mode-indent-offset 2))

(provide 'init-nix)

;;; init-nix.el ends here
