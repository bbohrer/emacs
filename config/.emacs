(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(tab-always-indent nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; for D programming language
(autoload 'd-mode "d-mode" "Major mode for editing D code." t)
(add-to-list 'auto-mode-alist '("\\.d[i]?\\'" . d-mode))

;; for tablature
(autoload 'tab-mode "tablature-mode" "Tablature mode" t)
(setq auto-mode-alist (append '(("\\.tab$" . tab-mode))
auto-mode-alist))

;; Save session
(desktop-save-mode 1)

;; Custom key bindings
(global-set-key "\M-g" 'goto-line)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(custom-set-variables
  '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
  '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))

;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

(column-number-mode)
(iswitchb-mode)
(global-set-key [(meta up)] `windmove-up)
(global-set-key [(meta right)] `windmove-right)
(global-set-key [(meta left)] `windmove-left)
(global-set-key [(meta down)] `windmove-down)
(global-set-key "\M-<left>" `windmove-left)
(global-set-key "\M-<right>" `windmove-right)
(global-set-key "\M-<down>" `windmove-down)
