#!/bin/sh
cd $(dirname $0)
[ ! -d ./emacs.d ] && emacs --batch -l org config.org -f org-babel-tangle
setsid emacs --init-directory=./emacs.d $@
