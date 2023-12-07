(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

(defvar saved--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq-default bidi-display-reordering 'left-to-right 
	      bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

(setq fast-but-imprecise-scrolling t)

(setq native-comp-async-report-warnings-errors 'silent)
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(add-hook 'after-init-hook #'(lambda ()
			       (setq gc-cons-threshold 16777216
				     gc-cons-percentage 0.1)
			       (setq file-name-handler-alist saved--file-name-handler-alist)))
