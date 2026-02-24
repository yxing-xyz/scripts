;; init-rust.el --- Initialize Rust configurations.	-*- lexical-binding: t -*-

;;; Commentary:
;;
;; Rust configurations.
;;

;;; Code:

(use-package rust-mode
  :init (setq rust-format-on-save t
              rust-mode-treesitter-derive t))

(use-package ron-mode
  :mode ("\\.ron" . ron-mode))

(provide 'init-rust)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-rust.el ends here
