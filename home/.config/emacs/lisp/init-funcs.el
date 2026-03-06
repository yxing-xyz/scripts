;; -*- lexical-binding: t; -*-


(require 'cl-lib)

;; Suppress warnings
(defvar socks-noproxy)
(defvar socks-server)

(declare-function browse-url-file-url "browse-url")
(declare-function browse-url-interactive-arg "browse-url")
(declare-function chart-bar-quickie "chart")
(declare-function consult-theme "ext:consult")
(declare-function nerd-icons-install-fonts "ext:nerd-icons")
(declare-function xwidget-buffer "xwidget")
(declare-function xwidget-webkit-current-session "xwidget")

;; Font
(defun font-available-p (font-name)
  "Check if font with FONT-NAME is available."
  (find-font (font-spec :name font-name)))

;; Dos2Unix/Unix2Dos
(defun dos2unix ()
  "Convert the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))

(defun unix2dos ()
  "Convert the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))

(defun delete-dos-eol ()
  "Delete `^M' characters in current region or buffer.
Same as `replace-string' `C-q' `C-m' `RET' `RET'."
  (interactive)
  (save-excursion
    (when (region-active-p)
      (narrow-to-region (region-beginning) (region-end)))
    (goto-char (point-min))
    (let ((count 0))
      (while (search-forward "\r" nil t)
        (replace-match "" nil t)
        (setq count (1+ count)))
      (message "Removed %d " count))
    (widen)))

;; File and buffer
(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defun rename-this-file (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

(defun browse-this-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))

(defun create-scratch-buffer ()
  "Create a scratch buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))

(defun save-buffer-as-utf8 (coding-system)
  "Revert a buffer with `CODING-SYSTEM' and save as UTF-8."
  (interactive "zCoding system for visited file (default nil):")
  (revert-buffer-with-coding-system coding-system)
  (set-buffer-file-coding-system 'utf-8)
  (save-buffer))

(defun save-buffer-gbk-as-utf8 ()
  "Revert a buffer with GBK and save as UTF-8"
  (interactive)
  (save-buffer-as-utf8 'gbk))

(defun selected-region-or-symbol-at-point ()
  "Return the selected region, otherwise return the symbol at point."
  (if (region-active-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'symbol t)))

(defun xwidget-workable-p ()
  "Check whether xwidget is available."
  (and (display-graphic-p)
       (featurep 'xwidget-internal)))

;; Browse URL
(defun xwidget-workable-p ()
  "Check whether xwidget is available."
  (and (display-graphic-p)
       (featurep 'xwidget-internal)))

(defun xx-webkit-browse-url (url &optional pop-buffer new-session)
  "Browse URL with xwidget-webkit' and switch or pop to the buffer.

POP-BUFFER specifies whether to pop to the buffer.
NEW-SESSION specifies whether to create a new xwidget-webkit session.
Interactively, URL defaults to the string looking like a url around point."
  (interactive (progn
                 (require 'browse-url)
                 (browse-url-interactive-arg "URL: ")))
  (xwidget-webkit-browse-url url new-session)
  (let ((buf (xwidget-buffer (xwidget-webkit-current-session))))
    (when (buffer-live-p buf)
      (and (eq buf (current-buffer)) (quit-window))
      (if pop-buffer
          (pop-to-buffer buf)
        (switch-to-buffer buf)))))

(defun xx-browse-url (url)
  "Open URL using a configurable method.
See `browse-url' for more details."
  (interactive)
  (if (xwidget-workable-p)
      (xx-webkit-browse-url url t)
    (browse-url url)))

(defun xx-browse-url-of-file (file)
  "Use a web browser to display FILE.
Display the current buffer's file if FILE is nil or if called
interactively.  Turn the filename into a URL with function
`browse-url-file-url'.  Pass the URL to a browser using the
`browse-url' function then run `browse-url-of-file-hook'."
  (interactive)
  (if (xwidget-workable-p)
      (xx-webkit-browse-url (browse-url-file-url file) t)
    (browse-url-of-file file)))

;; Reload configurations
(defun reload-init-file ()
  "Reload Emacs configurations."
  (interactive)
  (load user-init-file))
(defalias 'xx-reload-init-file #'reload-init-file)


;; Misc
(defun byte-compile-elpa ()
  "Compile packages in elpa directory. Useful if you switch Emacs versions."
  (interactive)
  (if (fboundp 'async-byte-recompile-directory)
      (async-byte-recompile-directory package-user-dir)
    (byte-recompile-directory package-user-dir 0 t)))

(defun byte-compile-site-lisp ()
  "Compile packages in site-lisp directory."
  (interactive)
  (let ((dir (locate-user-emacs-file "site-lisp")))
    (if (fboundp 'async-byte-recompile-directory)
        (async-byte-recompile-directory dir)
      (byte-recompile-directory dir 0 t))))

(defun native-compile-elpa ()
  "Native-compile packages in elpa directory."
  (interactive)
  (if (fboundp 'native-compile-async)
      (native-compile-async package-user-dir t)))

(defun native-compile-site-lisp ()
  "Native compile packages in site-lisp directory."
  (interactive)
  (let ((dir (locate-user-emacs-file "site-lisp")))
    (if (fboundp 'native-compile-async)
        (native-compile-async dir t))))


(defun xx-set-variable (variable value &optional no-save)
  "Set the VARIABLE to VALUE, and return VALUE.

If NO-SAVE is non-nil, don't save to the custom file.
This function both sets the variable in the current session and persists it to
the custom file."
  (customize-set-variable variable value)
  (when (and (not no-save)
             (file-writable-p custom-file))
    (with-temp-buffer
      (insert-file-contents custom-file)
      (goto-char (point-min))
      (while (re-search-forward
              (format "^[\t ]*[;]*[\t ]*(setq %s .*)" variable)
              nil t)
        (replace-match (format "(setq %s '%s)" variable value) nil nil))
      (write-region nil nil custom-file)
      (message "Saved %s (%s) to %s" variable value custom-file))))

(defun file-too-long-p ()
  "Check whether the file is too long.

Returns non-nil if the buffer size exceeds 500,000 bytes or has more than 10,000
lines."
  (or (> (buffer-size) 500000)
      (and (fboundp 'buffer-line-statistics)
           (> (car (buffer-line-statistics)) 10000))))


(defun set-package-archives (archives &optional refresh async no-save)
  "If REFRESH is non-nil, refresh the package contents.  If ASYNC is non-nil,
perform the refresh in the background.  Save the setting to `custom-file'
if NO-SAVE is nil.  This function updates `xx-package-archives'."
  (interactive
   (list
    (intern
     (completing-read "Select package archives: "
                      (mapcar #'car xx-package-archives-alist)))))
  ;; Set option
  (xx-set-variable 'xx-package-archives archives no-save)

  ;; Refresh if need
  (and refresh (package-refresh-contents async))

  (message "Set package archives to `%s'" archives))

(defalias 'xx-set-package-archives #'set-package-archives)


;; Refer to https://emacs-china.org/t/elpa/11192
(defun xx-test-package-archives (&optional no-chart)
  "Test connection speed of all package archives and display on chart.

Not displaying the chart if NO-CHART is non-nil.
Return the fastest package archive."
  (interactive)

  (let* ((durations (mapcar
                     (lambda (pair)
                       (let ((url (concat (cdr (nth 2 (cdr pair)))
                                          "archive-contents"))
                             (start (current-time)))
                         (message "Fetching %s..." url)
                         (ignore-errors
                           (url-copy-file url null-device t))
                         (float-time (time-subtract (current-time) start))))
                     xx-package-archives-alist))
         (fastest (car (nth (cl-position (apply #'min durations) durations)
                            xx-package-archives-alist))))

    ;; Display on chart
    (when (and (not no-chart)
               (require 'chart nil t)
               (require 'url nil t))
      (chart-bar-quickie
       'vertical
       "Speed test for the ELPA mirrors"
       (mapcar (lambda (p) (symbol-name (car p))) xx-package-archives-alist)
       "ELPA"
       (mapcar (lambda (d) (* 1e3 d)) durations) "ms"))

    (message "`%s' is the fastest package archive" fastest)

    ;; Return the fastest
    fastest))

(defun set-from-minibuffer (sym)
  "Set SYM value from minibuffer."
  (eval-expression
   (minibuffer-with-setup-hook
       (lambda ()
         (run-hooks 'eval-expression-minibuffer-setup-hook)
         (goto-char (minibuffer-prompt-end))
         (forward-char (length (format "(setq %S " sym))))
     (read-from-minibuffer
      "Eval: "
      (let ((sym-value (symbol-value sym)))
        (format
         (if (or (consp sym-value)
                 (and (symbolp sym-value)
                      (not (null sym-value))
                      (not (keywordp sym-value))))
             "(setq %s '%S)"
           "(setq %s %S)")
         sym sym-value))
      read-expression-map t
      'read-expression-history))))


;; Update
(defun update-config ()
  "Update  Emacs configurations to the latest version."
  (interactive)
  (let ((dir (expand-file-name user-emacs-directory)))
    (unless (file-exists-p dir)
      (user-error "\"%s\" doesn't exist" dir))

    (message "Updating configurations...")
    (cd dir)
    (shell-command "git pull")
    (message "Updating configurations...done")))

(defun update-packages ()
  "Refresh package contents and update all packages."
  (interactive)
  (message "Updating packages...")
  (package-upgrade-all)
  (message "Updating packages...done"))
(defalias 'xx-update-packages #'update-packages)

(defun update-config-and-packages()
  "Update configurations and packages."
  (interactive)
  (update-config)
  (update-packages))
(defalias 'xx-update #'update-config-and-packages)


(defun update-all()
  "Update dotfiles, org files, configurations and packages to the latest."
  (interactive)
  (update-config-and-packages))
(defalias 'xx-update-all #'update-all)

;; Fonts
(defun xx-install-fonts ()
  "Install necessary fonts."
  (interactive)
  (nerd-icons-install-fonts))


;; Network Proxy
(defun show-http-proxy ()
  "Show HTTP/HTTPS proxy."
  (interactive)
  (if url-proxy-services
      (message "Current HTTP proxy is `%s'" xx-proxy)
    (message "No HTTP proxy")))

(defun enable-http-proxy ()
  "Enable HTTP/HTTPS proxy."
  (interactive)
  (setq url-proxy-services
        `(("http" . ,xx-proxy)
          ("https" . ,xx-proxy)
          ("no_proxy" . "^\\(localhost\\|192.168.*\\|10.*\\)")))
  (show-http-proxy))

(defun disable-http-proxy ()
  "Disable HTTP/HTTPS proxy."
  (interactive)
  (setq url-proxy-services nil)
  (show-http-proxy))

(defun toggle-http-proxy ()
  "Toggle HTTP/HTTPS proxy."
  (interactive)
  (if (bound-and-true-p url-proxy-services)
      (disable-http-proxy)
    (enable-http-proxy)))

(defun show-socks-proxy ()
  "Show SOCKS proxy."
  (interactive)
  (if (bound-and-true-p socks-noproxy)
      (message "Current SOCKS%d proxy is %s:%s"
               (cadddr socks-server) (cadr socks-server) (caddr socks-server))
    (message "No SOCKS proxy")))

(defun enable-socks-proxy ()
  "Enable SOCKS proxy."
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'socks
        socks-noproxy '("localhost"))
  (let* ((proxy (split-string xx-socks-proxy ":"))
         (host (car proxy))
         (port (string-to-number (cadr proxy))))
    (setq socks-server `("Default server" ,host ,port 5)))
  (setenv "all_proxy" (concat "socks5://" xx-socks-proxy))
  (show-socks-proxy))

(defun dsiable-socks-proxy ()
  "Disable SOCKS proxy."
  (interactive)
  (setq url-gateway-method 'native
        socks-noproxy nil
        socks-server nil)
  (setenv "all_proxy" "")
  (show-socks-proxy))

(defun toggle-socks-proxy ()
  "Toggle SOCKS proxy."
  (interactive)
  (if (bound-and-true-p socks-noproxy)
      (disable-socks-proxy)
    (enable-socks-proxy)))

(defun enable-proxy ()
  "Enalbe proxy."
  (interactive)
  (enable-http-proxy)
  (enable-socks-proxy))

(defun disable-proxy ()
  "Disable proxy."
  (interactive)
  (disable-http-proxy)
  (disable-socks-proxy))

(defun toggle-proxy ()
  "Toggle proxy."
  (interactive)
  (toggle-http-proxy)
  (toggle-socks-proxy))


;; UI

(defun theme-solaire-p (theme)
  "判断 THEME 是否支持 solaire-mode（目前仅识别 doom- 前缀）。"
  (and theme
       (string-prefix-p "doom-" (symbol-name theme))))

(defvar after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")
(defun run-after-load-theme-hook (&rest _)
  "Run `after-load-theme-hook'."
  (run-hooks 'after-load-theme-hook))
(add-hook 'enable-theme-functions #'run-after-load-theme-hook)

(defun xx-load-theme (theme &optional no-save)
  "Load color THEME. Save setting to `custom-file' if NO-SAVE is nil."
  (interactive
   (list
    (intern
     (completing-read "Load theme: "
                      (mapcar #'symbol-name (custom-available-themes))
                      ))))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (xx-set-variable 'xx-doom-theme theme no-save))


(defun icons-displayable-p ()
  "Return non-nil if icons are displayable."
  (or (featurep 'nerd-icons)
      (require 'nerd-icons nil t)))

;; Rearrange split windows
(defun split-window-horizontally-instead ()
  "Kill other windows and split the current window is on the top half of the frame."
  (interactive)
  (let* ((next-window (next-window))
         (other-buffer (and next-window (window-buffer next-window))))
    (delete-other-windows)
    (split-window-horizontally)
    (when other-buffer
      (set-window-buffer next-window other-buffer))))

(defun split-window-vertically-instead ()
  "Kill other windows and split the current window is on left half of the frame."
  (interactive)
  (let* ((next-window (next-window))
         (other-buffer (and next-window (window-buffer next-window))))
    (delete-other-windows)
    (split-window-vertically)
    (when other-buffer
      (set-window-buffer next-window other-buffer))))

(defun childframe-workable-p ()
  "Whether childframe is workable."
  (and (>= emacs-major-version 26)
       (not noninteractive)
       (not emacs-basic-display)
       (or (display-graphic-p)
           (featurep 'tty-child-frames))
       (eq (frame-parameter (selected-frame) 'minibuffer) 't)))

(provide 'init-funcs)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-funcs.el ends here
