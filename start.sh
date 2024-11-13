#!/bin/sh
cd $(dirname $0)

EMACS_CMD="emacs --init-directory ./emacs.d $@"
if [[ $1 == "--upgrade" ]]; then
    rm -r ./emacs.d/
    git pull
fi


[ ! -d ./emacs.d ] && emacs --batch -l org config.org -f org-babel-tangle
#setsid $EMACS_CMD &
nix-shell . --run "setsid $EMACS_CMD &"
