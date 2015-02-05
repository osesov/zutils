;; link this to ~/.emacs.d/init.el

(add-to-list 'load-path "~/zutils/emacs")
(require 'psvn)

(setq user-mail-address "oleg.sesov@dev.zodiac.tv")

(defalias 'yes-or-no-p 'y-or-n-p)

;; C-mode
(require 'cc-mode)
(setq-default c-basic-offset 4)
(setq-default c-default-style "linux")
(setq-default tab-width 4)
(setq-default indent-tabs-mode t)
(define-key c-mode-base-map (kbd "RET") 'newline-and-indent)
