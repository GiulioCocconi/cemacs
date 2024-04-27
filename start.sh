#!/bin/sh
cd $(dirname $0)

EMACS_CMD="emacs --init-directory ./emacs.d $@"

if [[ $1 == "--upgrade" ]]; then
    rm -r ./emacs.d/
    git pull
fi

[ ! -d ./emacs.d ] && emacs --batch -l org config.org -f org-babel-tangle

if [ -n "{NIX_EMACS}" ]; then

    search_for_shell_file() {
	for path in "$@"; do
	    if [ -e $path ]; then
		SHELL_FILE=$path
		return
	    fi
	done
    }

    if [[ $1 == "" ]]; then
	search_for_shell_file "$(pwd)/shell.nix"\
			      "$(pwd)/default.nix"

    elif [[ ! $1 =~ ^.*\/(default|shell).nix ]]; then
	# figure out the project root directory
	ELISP_CMD="(message (get-vc-root \"$1\"))"
	ROOT_PATH=$(emacs --batch --load ./emacs.d/early-init.el\
			  --eval "$ELISP_CMD" 2>&1 | tail -1)

	search_for_shell_file "$ROOT_PATH/shell.nix"\
			      "$ROOT_PATH/default.nix"\
			      "$(pwd)/shell.nix"\
			      "$(pwd)/default.nix"
    fi
fi

if [[ $SHELL_FILE == "" ]]; then
    setsid $EMACS_CMD &
else
    nix-shell --run "setsid $EMACS_CMD &" $SHELL_FILE
fi
