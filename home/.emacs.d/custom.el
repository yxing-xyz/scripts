;;; custom.el --- user customization file    -*- lexical-binding: t no-byte-compile: t -*-
;;; Code:

;; (setq debug-on-error t)

(setq xx-package-archives 'nju)
;; (setq xx-package-archives 'melpa)
(setq xx-full-name "shawnyyu")
(setq xx-mail-address "yxing.xyz@gmail.com")
(setq xx-server nil)
(setq xx-doom-theme 'doom-dracula)
(setq xx-tree-sitter t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((ultra-scroll :vc-backend Git :url "https://github.com/jdtsmith/ultra-scroll"))))

(defun xx-setup-fonts ()
  "Setup fonts."
  (when (display-graphic-p)
    ;; Set Nerd Icons font family
    (setq nerd-icons-font-family "CodeNewRoman Nerd Font Propo")
    ;; Set default font
    (cl-loop for font in '("CodeNewRoman Nerd Font Propo")
             when (font-installed-p font)
             return (set-face-attribute 'default nil
                                        :family font
                                        :height (cond (sys/macp 130)
                                                      (sys/win32p 110)
                                                      (t 120))))

    ;; Set mode-line font
    ;; (cl-loop for font in '("Menlo" "SF Pro Display" "Helvetica")
    ;;          when (font-installed-p font)
    ;;          return (progn
    ;;                   (set-face-attribute 'mode-line nil :family font :height 120)
    ;;                   (when (facep 'mode-line-active)
    ;;                     (set-face-attribute 'mode-line-active nil :family font :height 120))
    ;;                   (set-face-attribute 'mode-line-inactive nil :family font :height 120)))

    ;; Specify font for all unicode characters
    (cl-loop for font in '("CodeNewRoman Nerd Font Propo" "Apple Symbols" "Segoe UI Symbol" "Symbola" "Symbol")
             return (set-fontset-font t 'symbol (font-spec :family font) nil 'prepend))

    ;; Emoji
    (cl-loop for font in '("CodeNewRoman Nerd Font Propo" "Noto Color Emoji" "Apple Color Emoji" "Segoe UI Emoji")
             when (font-installed-p font)
             return (set-fontset-font t
                                      (if (< emacs-major-version 28)'symbol 'emoji)
                                      (font-spec :family font) nil 'prepend))

    ;; Specify font for Chinese characters
    (cl-loop for font in '("Noto Sans Mono CJK SC")
             when (font-installed-p font)
             return (progn
                      (setq face-font-rescale-alist `((,font . 1.15)))
                      (set-fontset-font t 'han (font-spec :family font))))))

;; Call the function to setup fonts
(xx-setup-fonts)
(add-hook 'window-setup-hook #'xx-setup-fonts)
(add-hook 'server-after-make-frame-hook #'xx-setup-fonts)


;;你好aaa你ac
;;abcdaaaabad
;; | 一个普通标题     | 一个普通标题 | 一个普通标题     |
;; | ---------------- | ------------ | ---------------- |
;; | 短文本           | 中等文本     | 稍微长一点的文本 |
;; | 稍微长一点的文本 | 短文本       | 中等文本         |

;;; custom.el ends here
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
