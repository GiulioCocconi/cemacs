(defconst IS-MAC      (eq system-type 'darwin))
(defconst IS-LINUX    (memq system-type '(gnu gnu/linux gnu/kfreebsd berkeley-unix)))
(defconst IS-WINDOWS  (memq system-type '(cygwin windows-nt ms-dos)))

(defconst IS-NIX (getenv "NIX_EMACS")
  "If non-nil then consider emacs as configured by Nix Emacs Overlay")

(defvar language-list nil
  "The list of programming languages supported by this config that are manually managed  (if `IS-NIX' is non-nil then you can, and actually should, manage your programming languages with nix)")

(defvar custom-font-list nil
  "List of custom fonts to be added to the default font list")

(when IS-NIX
  (defconst IS-NIX-PURE (getenv "EMACS_PURE")
    "True if (and only if) using a pure NixOS config"))

(defun is-language-active (lang)
  (or (and IS-NIX
	   (or (getenv (concat "NIX_LANG_" (upcase lang)))
	       (string-equal lang "nix")))
      (member lang language-list)))

(defun add-multiple-hooks (hooks fun)
  "Add function to multiple hooks"
  (dolist (hook hooks)
    (add-hook hook fun)))

(set-language-environment "UTF-8")
(setq default-input-method nil)

(when IS-NIX
  (if IS-NIX-PURE
      (setq user-emacs-directory "~/.emacs.d")
    (display-warning 'nix-config "Using an impure config in NixOS!")))

(when (and IS-WINDOWS
	   (null (getenv "HOME")))
  (setenv "HOME" (getenv "USERPROFILE")))

(unless IS-NIX-PURE
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

(unless IS-NIX-PURE
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

(setq inhibit-startup-screen  t
      inhibit-startup-message t
      visible-bell            nil
      use-dialog-box          nil)

(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

(setq display-line-numbers-type 'relative)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(setq frame-resize-pixelwise t)

(use-package hl-todo
  :hook ((prog-mode org-mode) . hl-todo-mode))

(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))

(defconst USABLE-FONTS
  (seq-filter #'(lambda (font-name)
		  (find-font (font-spec :name font-name)))
	      (append '("Iosevka Nerd Font"
			"Iosevka NF")
		      custom-font-list)))

(if (null USABLE-FONTS)
    (display-warning 'font
		     "No compatible font found, falling back to default!")
  (set-face-attribute 'default nil :font (car USABLE-FONTS) :height 130))

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

(use-package winum
  :init (winum-mode)
  :config
  (leader-key-definer
    "`" 'winum-select-window-by-number
    "0" 'winum-select-window-0-or-10
    "1" 'winum-select-window-1
    "2" 'winum-select-window-2
    "3" 'winum-select-window-3
    "4" 'winum-select-window-4
    "5" 'winum-select-window-5
    "6" 'winum-select-window-6
    "7" 'winum-select-window-7
    "8" 'winum-select-window-8
    "9" 'winum-select-window-9))

(setq initial-scratch-message (purecopy "\
;; CoGiSystems Emacs
;; Remember to have fun :)

"))

(add-hook 'prog-mode-hook 'electric-pair-mode)
(add-multiple-hooks '(org-mode-hook text-mode-hook) 'visual-line-mode)

(use-package all-the-icons
  :if (display-graphic-p))

(fset 'yes-or-no-p 'y-or-n-p)

(setq confirm-kill-emacs #'(lambda (&rest _)
			     (y-or-n-p "Do you really want to kill me?!?")))

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

(use-package org
  :config
  (setq org-hide-emphasis-markers t))

(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode))

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

(unless IS-WINDOWS
  (use-package pdf-tools
    :magic ("%PDF" . pdf-view-mode)
    :config
    (pdf-loader-install :no-query)))

(use-package tramp)

(when (is-language-active "nix")
  (use-package nix-mode
    :mode "\\.nix\\'"))

(when (is-language-active "clisp")
  (use-package slime
    :commands slime-mode
    :config (setq inferior-lisp-program "sbcl")))

(use-package js2-mode)
(use-package web-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(web-mode js2-mode which-key vertico use-package slime pdf-tools org-appear nix-mode marginalia magit ligature hl-todo highlight-numbers helpful general evil-collection embark-consult doom-themes company-quickhelp all-the-icons-completion winum openwith centaur-tabs)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
