;;; custom-post.el --- custom-post.el -*- lexical-binding: t no-byte-compile: t -*-

;; 隐藏菜单栏
(menu-bar-mode -1)
;; 隐藏工具栏
(tool-bar-mode -1)
;; 隐藏滚动条
(scroll-bar-mode -1)
;; 隐藏侧边栏
(fringe-mode 0)
;; 关闭鼠标滚动
(mouse-wheel-mode -1)
;; 打开软链接文件
(setq vc-follow-symlinks t)
;; 关闭自动换行
(set-default 'truncate-lines t)
;; hide line-truncation symbols in terminal
(set-display-table-slot standard-display-table 0 ?\ )
;; 光标实心
(setq-default cursor-type 'box)
;; 禁止闪烁光标
(setq blink-cursor-mode nil)

;; 设置mode-line显示路径风格
(setq doom-modeline-buffer-file-name-style 'relative-from-project)
;; key重定向
;; (define-key key-translation-map (kbd "M-\\") (kbd "M-g w"))
;; (define-key prog-mode-map (kbd "M-RET") (key-binding (kbd "M-g w")))
(add-hook 'ace-pinyin-mode-hook (lambda () (progn
                                             (local-set-key (kbd "M-RET") (key-binding (kbd "C-:")))
                                             )))
(add-hook 'prog-mode-hook (lambda () (progn
                                       (local-set-key (kbd "C-c @ `") 'hideshow-hydra/body))))

(provide 'custom-post)
;;;
