cd /d "%~dp0"

if not exist "emacs.d\." emacs --batch -l org config.org -f org-babel-tangle

start runemacs --init-directory=emacs.d --debug-init
