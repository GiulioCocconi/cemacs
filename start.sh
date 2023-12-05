#!/bin/sh
cd $(dirname $0)
setsid emacs --init-directory=./emacs.d $@
