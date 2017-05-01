;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; language env
;;;

(set-language-environment "UTF-8")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; setup package.el
;;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(when (not (require 'use-package nil t))
  (package-install 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; Utilities (copied from https://github.com/rfkm/.emacs.d)
;;;

(defun my/untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun my/indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun my/cleanup-buffer-safe ()
  "Perform a bunch of safe operations on the whitespace content of a buffer.
Does not indent buffer, because it is used for a before-save-hook, and that
might be bad."
  (interactive)
  (my/untabify-buffer)
  (delete-trailing-whitespace)
  (set-buffer-file-coding-system 'utf-8))

(defun my/cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer.
Including my/indent-buffer, which should not be called automatically on save."
  (interactive)
  (my/cleanup-buffer-safe)
  (my/indent-buffer))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; basic configurations
;;;

;;; enable use-package
(require 'use-package)
(setq use-package-always-ensure t)
;; (setq use-package-always-pin "melpa-stable")
(setq use-package-verbose t)

;;; load your preferred theme
(use-package material-theme
  :config
  (load-theme 'material t))

;;; set up exec-path
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package mykie
  :config
  (setq mykie:use-major-mode-key-override t)
  (mykie:initialize))

;;; happy (((()))) !!!
(use-package paren
  :init
  (setq show-paren-style 'parenthesis)
  (show-paren-mode 1))

;;; yasnippet
(use-package yasnippet
  :init
  (yas-global-mode 1)
  (bind-keys :map yas-minor-mode-map
             ("<tab>" . nil)
             ("TAB" . nil)
             ("C-i" . nil)
             ("C-o" . yas/expand)))

;;; comapany-mode!
(use-package company
  :defer t
  :config
  (global-company-mode +1)
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 2
        company-selection-wrap-around t
        company-global-modes '(not magit-mode))

  (bind-keys :map company-mode-map
             ("C-i" . company-complete))
  (bind-keys :map company-active-map
             ("C-n" . company-select-next)
             ("C-p" . company-select-previous))
  (bind-keys :map company-search-map
             ("C-n" . company-select-next)
             ("C-p" . company-select-previous)))

;;; projectile
(use-package projectile
  :init
  (projectile-global-mode))

(use-package subword
  :init
  (global-subword-mode 1))

;;; answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;;; turn off graphical user interface
(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;;; some useful settings
(setq visible-bell t
      font-lock-maximum-decoration t
      truncate-partial-width-windows nil
      echo-keystrokes 0.1
      create-lockfiles nil
      ;; disable to buckup funciton
      backup-inhibited t
      delete-auto-save-files t
      ;; completion ignore case (lower/upper)
      completion-ignore-case t
      read-file-name-completion-ignore-case t
      inhibit-startup-message t)

;; show me empty lines after buffer end
(set-default 'indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'right)
(setq uniquify-buffer-name-style 'post-forward)

;; whitespace
(use-package whitespace
  :config
  (setq whitespace-style '(face
                           trailing
                           tabs
                           spaces
                           empty
                           space-mark
                           tab-mark))
  (setq whitespace-display-mappings
        '((space-mark ?\u3000 [?\u25a1])
          (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
  (setq whitespace-space-regexp "\\(\u3000+\\)")
  (global-whitespace-mode 1)
  (setq-default tab-width 4 indent-tabs-mode nil))

;;; cleanup whitespace before file save
;;; (add-hook 'before-save-hook 'whitespace-cleanup)

;;; modeline
(setq display-time-string-forms
      '((format
         "%s/%s(%s) %s:%s" month day dayname 24-hours minutes))
      line-number-mode t
      column-number-mode t)
(display-time-mode 1)

;; http://flex.phys.tohoku.ac.jp/texi/eljman/eljman_142.html
(setq-default
 mode-line-format
 '(""
   mode-line-mule-info
   mode-line-modified
   " "
   mode-line-buffer-identification

   " / "
   (line-number-mode "L%l ")
   (column-number-mode "C%c ")
   (-3 . "%p")
   " / "
   mode-name
   minor-mode-alist "%n" mode-line-process
   " / "
   global-mode-string
   ))

(setq-default
 header-line-format
 '(""
   (:propertize (:eval (shorten-directory default-directory 30))
                face mode-line-folder-face)
   (:propertize "%b"
                face mode-line-filename-face)))

(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat ".../" output)))
    output))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; helm
;;;

(use-package helm
  :config
  (setq helm-quick-update t
        helm-buffers-fuzzy-matching t
        helm-ff-transformer-show-only-basename nil)
  (bind-keys :map global-map
             ("M-x" . helm-M-x)))
                                        ; (use-package helm-projectile
;;   :config
;;   (mykie:set-keys nil
;;     "C-x C-f"
;;     :default (call-interactively 'find-file)
;;     :C-u helm-projectile-find-file
;;     "C-x b"
;;     :default (call-interactively 'switch-to-buffer)
;;     :C-u helm-projectile-switch-to-buffer))

(use-package helm-ls-git
  :config
  (mykie:set-keys nil
    "C-x C-f"
    :default (call-interactively 'find-file)
    :C-u! helm-ls-git-ls))

(use-package helm-ag
  :bind ("C-x C-g" . helm-do-ag-project-root))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; lisp
;;;

(use-package paredit
  :defer t
  :config
  (bind-keys :map paredit-mode-map
             ("C-h" . paredit-backward-delete))

  (defun conditionally-enable-paredit-mode ()
    (if (eq this-command 'eval-expression)
        (paredit-mode 1)))
  (add-hook 'minibuffer-setup-hook 'conditionally-enable-paredit-mode))

(use-package eldoc
  :defer t
  :config
  (setq eldoc-idle-delay 0.1
        eldoc-minor-mode-string ""))

(use-package rainbow-delimiters
  :defer t)

(use-package aggressive-indent)

(defun my/lisp-mode-defaults ()
  (aggressive-indent-mode 1)
  (paredit-mode 1)
  (rainbow-delimiters-mode 1)
  (eldoc-mode 1))

(defun my/lisp-mode-hook ()
  (my/lisp-mode-defaults))

(add-hook 'emacs-lisp-mode-hook 'my/lisp-mode-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
;;;
;;; clojure
;;;

(use-package clojure-mode
  :init
  (add-hook 'clojure-mode-hook #'yas-minor-mode)
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'my/lisp-mode-hook)
  (add-hook 'before-save-hook #'my/cleanup-buffer))

(use-package cider
  :init
  (add-hook 'cider-mode-hook #'clj-refactor-mode)
  (add-hook 'cider-mode-hook #'company-mode)
  (add-hook 'cider-repl-mode-hook #'company-mode)
  (add-hook 'cider-repl-mode-hook #'my/lisp-mode-hook)
  :diminish subword-mode
  :config
  (setq nrepl-log-messages t
        cider-repl-display-in-current-window t
        cider-repl-use-clojure-font-lock t
        cider-prompt-save-file-on-load 'always-save
        cider-font-lock-dynamically '(macro core function var)
        cider-overlays-use-font-lock t)
  (cider-repl-toggle-pretty-printing))

(use-package midje-mode)

;; (use-package cider-eval-sexp-fu)

(use-package clj-refactor
  :init   (setq cljr-favor-prefix-notation nil)
  :diminish clj-refactor-mode
  :config (cljr-add-keybindings-with-prefix "C-c j"))

(message "init.el loaded!!")

(add-hook 'after-init-hook
          (lambda ()
            (message "init time: %.3f sec"
                     (float-time (time-subtract after-init-time before-init-time)))))

(use-package magit
  :bind ("C-x g" . magit-status))

(put-clojure-indent 'fnk 'defun)
(put-clojure-indent 'defnk 'defun)
(put-clojure-indent 'for-map 1)
(put-clojure-indent 'instance 2)
(put-clojure-indent 'inline 1)
(put-clojure-indent 'letk 1)
(put-clojure-indent 'when-letk 1)
(put-clojure-indent 'go-loop 1)
(put-clojure-indent 'this-as 'defun)
(put-clojure-indent 'when-some '1)
(put-clojure-indent 'if-some '1)
(put-clojure-indent 'try+ 0)
(put 'specify 'clojure-backtracking-indent '((2)))
(put 'specify! 'clojure-backtracking-indent '((2)))
(put 'defcomponent 'clojure-backtracking-indent '((2)))
(put 'defcomponentk 'clojure-backtracking-indent '((2)))
(put 'defmixin 'clojure-backtracking-indent '((2)))
(put 'clojure.core/defrecord 'clojure-backtracking-indent '(4 4 (2)))
(put 's/defrecord 'clojure-backtracking-indent '(4 4 (2)))
(put 's/defrecord+ 'clojure-backtracking-indent '(4 4 (2)))
(put 'potemkin/deftype+ 'clojure-backtracking-indent '(4 4 (2)))
(put 'potemkin/defrecord+ 'clojure-backtracking-indent '(4 4 (2)))

;;; global keymap
;; (use-package bind-key
;;   :config
;;   (bind-keys :map global-map
;;              ("C-h" . delete-backward-char)))


(use-package bind-key
  :config
  (bind-keys :map global-map
             ("C-+" . text-scale-increase)
             ("C--" . text-scale-decrease)))

;; defined by me
(define-key key-translation-map [?\C-h] [?\C-?])
