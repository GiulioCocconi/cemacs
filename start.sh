#!/bin/sh
cd $(dirname $0)

EMACS_CMD="emacs --init-directory ./emacs.d $@"

if [[ $1 == "--upgrade" ]]; then
    rm -r ./emacs.d/
    git pull
fi

[ ! -d ./emacs.d ] && emacs --batch -l org config.org -f org-babel-tangle

if [ -z "${NIX_EMACS}" ]; then
    setsid $EMACS_CMD $@ &
    exit
fi


# TODO: Always check also cwd for nix-shells, but $1 should take precedence

if [[ ! $1 =~ ^.*\/(default|shell).nix ]]; then
    # figure out the project root directory
    ELISP_CMD="(message (get-vc-root \"$1\"))"
    ROOT_PATH=$(emacs --batch --load ./emacs.d/early-init.el --eval "$ELISP_CMD" 2>&1 | tail -1)
    echo $ROOT_PATH

    if [ -e "$ROOT_PATH/shell.nix" ]; then
        SHELL_FILE="$ROOT_PATH/shell.nix"
    elif [ -e "$ROOT_PATH/default.nix" ]; then
        SHELL_FILE="$ROOT_PATH/default.nix"
    fi
fi

if [[ $SHELL_FILE == "" ]]; then
    setsid $EMACS_CMD &
else
    nix-shell --run "setsid $EMACS_CMD &" $SHELL_FILE
fi
