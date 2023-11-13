#!/bin/sh
cd $(dirname $0)
emacs --init-directory=./emacs.d $@ &
