;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold 100000000)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                      (format "%.2f seconds"
                              (float-time
                               (time-subtract after-init-time before-init-time)))
                      gcs-done)))

;; Terminal (eat) performance
(setq process-adaptive-read-buffering nil)
(setq read-process-output-max (* 4 1024 1024))

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)
  (setq mac-right-option-modifier 'super)
  (setq dired-use-ls-dired nil)
  (setq insert-directory-program "gls")
  (use-package exec-path-from-shell
    :ensure t
    :init
    (exec-path-from-shell-initialize))
  ;; Simulate Cua mode on Mac
  (keymap-global-set "M-c" 'kill-ring-save)
  (keymap-global-set "M-v" 'yank))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(when (eq system-type 'gnu/linux)
  (setq cua-auto-tabify-rectangles nil)
  (cua-mode t)
  (transient-mark-mode 1))

;; Not needed if Emacs is in version 30+
(unless (package-installed-p 'vc-use-package)
    (package-vc-install "https://github.com/slotThe/vc-use-package"))
(require 'vc-use-package)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Thanks, but no thanks
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell nil)

(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook latex-mode-hook LaTeX-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Highlight the current line
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'text-mode-hook #'hl-line-mode)

;; Screenshots: https://github.com/doomemacs/themes/blob/screenshots/
(use-package doom-themes
 :ensure t
 :config
 ;; Global settings (defaults)
 (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
       doom-themes-enable-italic t) ; if nil, italics is universally disabled
 (load-theme 'doom-one t)

 ;; Enable flashing mode-line on errors
 (doom-themes-visual-bell-config)
 ;; Corrects (and improves) org-mode's native fontification.
 (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

;; Set the default pitch face
(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :weight 'normal
                    :height 120)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrains Mono"
                    :height 1.0
                    :weight 'normal)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil
                    :font "Iosevka Aile"
                    :height 1.0
                    :weight 'normal)

(defvar user-temporary-file-directory (concat user-emacs-directory "tmp/"))

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,user-temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))
(setq create-lockfiles nil)

(use-package undo-tree
  :ensure t
  :init
  (setq undo-tree-history-directory-alist `(("." . ,(expand-file-name "undo" user-emacs-directory))))
  (global-undo-tree-mode))

(use-package savehist
  :custom
  (history-length 100)
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
  (savehist-file "~/.cache/savehist")
  :init
  (savehist-mode 1))

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous)
              ("C-j" . vertico-exit))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism
     orderless-regexp))
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :custom
  (completion-in-region-function #'consult-completion-in-region))

(use-package marginalia
  :ensure t
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window))
  :custom
  (aw-scope 'frame)
  (aw-minibuffer-flag t)
  (aw-keys '(?q ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-char-2)))

(use-package magit
  :ensure t
  :bind (("C-x g" .  magit-status))
  :custom
  (magit-diff-refine-hunk (quote all)))

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . variable-pitch-mode)
  :custom
  (org-id-link-to-org-use-id t)
  (org-ellipsis " ▾")
  ;; (org-hide-emphasis-markers t)
  (org-startup-folded t)
  (org-fontify-quote-and-verse-blocks t)
  (org-startup-indented t)
  :config
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((shell . t)
      (gnuplot . t)
      (python . t)
      (emacs-lisp . t))))

;; Center org document
(use-package olivetti
  :ensure t
  :hook
  (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 150))

;; Sleek look
(use-package org-modern-indent
  :vc (:fetcher github :repo jdtsmith/org-modern-indent)
  :ensure t
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

;; This is needed as of Org 9.2
(use-package org-tempo
  :after (org)
  :config
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
  (add-to-list 'org-structure-template-alist '("json" . "src json")))

(use-package org-superstar
  :ensure t
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-faces
  :after (color)
  :custom-face
  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (org-block ((t (:inherit 'fixed-pitch))))
  (org-table ((t (:inherit 'fixed-pitch))))
  (org-formula ((t (:inherit 'fixed-pitch))))
  (org-code ((t (:inherit 'fixed-pitch))))
  (org-verbatim ((t (:inherit 'fixed-pitch))))
  (org-tag ((t (:inherit 'fixed-pitch)))))

(use-package gnuplot :ensure t)
