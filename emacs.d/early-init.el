(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

(defvar saved--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'after-init-hook #'(lambda ()
			       (setq gc-cons-threshold 16777216
				     gc-cons-percentage 0.1)
			       (setq file-name-handler-alist saved--file-name-handler-alist)))
