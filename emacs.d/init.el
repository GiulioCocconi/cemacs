(defconst IS-MAC      (eq system-type 'darwin))
(defconst IS-LINUX    (memq system-type '(gnu gnu/linux gnu/kfreebsd berkeley-unix)))
(defconst IS-WINDOWS  (memq system-type '(cygwin windows-nt ms-dos)))

(defconst IS-NIX (getenv "NIX_EMACS")
  "If non-nil then consider emacs as configured by Nix Emacs Overlay")

(defvar language-list nil
  "The list of programming languages supported by this config that are manually managed  (if `IS-NIX' is non-nil then you can, and actually should, manage your programming languages with nix)")

(when IS-NIX
  (defvar is-nix-pure t
    "True if (and only if) using a pure config"))

(defun is-language-active (lang)
  (or (and IS-NIX
	   (or (getenv (concat "NIX_LANG_" (upcase lang)))
	       (string-equal lang "nix")))
      (member lang language-list)))

(defun add-multiple-hooks (hooks fun)
  "Add function to multiple hooks"
  (dolist (hook hooks)
    (add-hook hook fun)))

(when IS-NIX
  (if (string= user-emacs-directory "/etc/emacs.d/")
      (setq user-emacs-directory "~/.emacs.d/")
    (progn
      (display-warning 'nix-config
		       "Using an impure config in NixOS!")
      (setq is-nix-pure nil))))

(when (and IS-WINDOWS
	   (null (getenv "HOME")))
  (setenv "HOME" (getenv "USERPROFILE")))

(unless (and IS-NIX is-nix-pure)
  (require 'package)

  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
			   ("org" . "https://orgmode.org/elpa/")
			   ("elpa" . "https://elpa.gnu.org/packages/")))

  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents)))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(unless (and IS-NIX is-nix-pure)
  (setq package-native-compile t
	use-package-always-ensure t))

(setq recentf-save-file "~/.emacs.d/recentf"
      recentf-filename-handlers '(file-truename)
      recentf-exclude (list "^/tmp/"))
(recentf-mode 1)

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq inhibit-startup-screen  t
      inhibit-startup-message t
      visible-bell            nil
      use-dialog-box          nil)

(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

(setq initial-scratch-message (purecopy "\
;; CoGiSystems emacs
;; Remember to have fun :)

"))

(setq display-line-numbers-type 'relative)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(setq frame-resize-pixelwise t)

(use-package hl-todo
  :hook ((prog-mode org-mode) . hl-todo-mode))

(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))

(set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 130)

(use-package ligature
  :config
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
				       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
				       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
				       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
				       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
				       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
				       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
				       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
				       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
				       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
				       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
				       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
				       "\\\\" "://"))
  (global-ligature-mode t))

(use-package doom-themes
  :config
  (load-theme 'doom-one t)

  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(add-hook 'prog-mode-hook 'electric-pair-mode)
(add-multiple-hooks '(org-mode-hook text-mode-hook) 'visual-line-mode)

(use-package all-the-icons
  :if (display-graphic-p))

(fset 'yes-or-no-p 'y-or-n-p)

(setq confirm-kill-emacs #'(lambda (&rest _)
			     (y-or-n-p "Do you really want to kill me?!?")))

(use-package which-key
  :init (which-key-mode))

(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer leader-key-definer
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (leader-key-definer
    "SPC" '(execute-extended-command :which-key "execute command")
    "RET" 'browse-url
    "."   'repeat
    "f"   '(:ignore t :which-key "Files")
    "ff"  'find-file
    "b"   '(:ignore t :which-key "Buffers")
    "bk"  'kill-buffer
    "bi"  'ibuffer
    "w"   '(:ignore t :which-key "Windows")
    "ws"  'split-window-below
    "wv"  'split-window-horizontally
    "ww"  '(other-window :which-key "cycle")
    "wk"  'delete-window))

(advice-add 'eshell-life-is-too-much
	    :after #'(lambda ()
		       (unless (one-window-p)
			 (delete-window))))

(defun split-eshell ()
  "Create a split window below the current one, with an eshell"
  (interactive)
  (select-window (split-window-below))
  (eshell))

(leader-key-definer
  "'" 'split-eshell)

(mapc (lambda (alias) (defalias (car alias) (cdr alias)))
      '((eshell/ffow . find-file-other-window)))

(defun eshell/ff (path)
  (eshell-life-is-too-much)
  (find-file path))

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package all-the-icons-completion
  :after (marginalia)
  :init (all-the-icons-completion-mode)
  :hook (marginalia-mode-hook . all-the-icons-completion-marginalia-setup))

(use-package consult)
(use-package embark)
(use-package embark-consult)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (dolist (lst '((special-mode . motion)
		 (tetris-mode  . emacs)))
    (evil-set-initial-state (car lst) (cdr lst))))

(use-package evil-collection
  :after evil
  :init (evil-collection-init))

(use-package org)

(use-package org-appear
  :hook (org-mode-hook . org-appear-mode))

(add-hook 'after-save-hook (lambda ()
			     (when (and (string-equal (buffer-name) "config.org")
					(y-or-n-p "Tangle?"))
			       (org-babel-tangle))))

(use-package magit)

(use-package company
  :init (global-company-mode))

(use-package company-quickhelp
  :init (company-quickhelp-mode))

(use-package helpful)

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-loader-install :no-query))

(when (is-language-active "nix")
  (use-package nix-mode
    :mode "\\.nix\\'"))

(when (is-language-active "clisp")
  (use-package slime
    :commands slime-mode
    :config (setq inferior-lisp-program "sbcl")))
