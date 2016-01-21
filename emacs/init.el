;; link this to ~/.emacs.d/init.el

(let ((q (directory-file-name (file-name-directory (file-truename user-init-file)))))
  (if q
	  (add-to-list 'load-path q)))

(require 'psvn)
(setq svn-status-hide-unmodified t)

(setq user-mail-address "oleg.sesov@dev.zodiac.tv")

(defalias 'yes-or-no-p 'y-or-n-p)

;; C-mode
(require 'cc-mode)
(setq-default c-basic-offset 4)
(setq-default c-default-style "linux")
(setq-default tab-width 4)
(setq-default indent-tabs-mode t)
(define-key c-mode-base-map (kbd "RET") 'newline-and-indent)

;; markdown
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; zmk
(load-theme 'manoj-dark)

(global-set-key (kbd "<f9>") 'compile)
(global-set-key (kbd "<f4>") 'next-error)
(global-set-key (kbd "S-<f4>") 'previous-error)

(setenv "ENABLE_DIRTRACE" "1")
(setenv "DISABLE_COLORS" "1")
(setq compile-command "zmk")


;(loop for x being the symbols
;    if (boundp x)
;    do (print (cons (symbol-name x) (symbol-value x))))

;; shell
(defun my-shell-clear ()
  (interactive)
  (erase-buffer)
  (comint-send-input))

(defun my-shell-hook ()
  (local-set-key "\C-cl" 'my-shell-clear))

(add-hook 'shell-mode-hook 'my-shell-hook)
