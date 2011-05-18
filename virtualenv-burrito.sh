#!/bin/bash
#
# virtualenv-burrito
#
#   One command to have a working virtualenv + virtualenvwrapper environment.
#
set -e

VENVBURRITO="$HOME/.venvburrito"
VENVBURRITO_esc="\$HOME/.venvburrito"
MASTER_URL="https://github.com/brainsik/virtualenv-burrito/raw/experimental"

kernel=$(uname -s)
case "$kernel" in
    Darwin|Linux) ;;
    *) echo "Sadly, $kernel hasn't been tested. :'("; exit 1
esac

if [ -e "$VENVBURRITO" ]; then
    echo "Looks like virtualenv-burrito is already installed. Bye."
    exit 1
fi

if [ -s "$HOME/.bash_profile" ]; then
    if grep -q "$VENVBURRITO_esc/startup.sh" $HOME/.bash_profile; then
        echo "Looks like virtualenv-burrito is already installed. Bye."
        exit 1
    fi
fi


test -d $VENVBURRITO || mkdir -p $VENVBURRITO/{bin,lib/python}
test -d $HOME/.virtualenvs || mkdir $HOME/.virtualenvs

echo "Downloading virtualenv-burrito command"
curl $MASTER_URL/virtualenv-burrito.py > $VENVBURRITO/bin/virtualenv-burrito
chmod 755 $VENVBURRITO/bin/virtualenv-burrito
echo -e "\nRunning: virtualenv-burrito upgrade"
$VENVBURRITO/bin/virtualenv-burrito upgrade
echo

# create the startup script
cat >$VENVBURRITO/startup.sh <<EOF
export WORKON_HOME="\$HOME/.virtualenvs"
export VIRTUALENV_USE_DISTRIBUTE=true
export PIP_VIRTUALENV_BASE="\$WORKON_HOME"
export PIP_RESPECT_VIRTUALENV=true
if ! echo \$PYTHONPATH | grep -q "$VENVBURRITO_esc/lib/python"; then
    export PYTHONPATH="$VENVBURRITO_esc/lib/python:\$PYTHONPATH"
fi
if ! echo \$PATH | grep -q "$VENVBURRITO_esc/bin"; then
    export PATH="$VENVBURRITO_esc/bin:\$PATH"
fi
. $VENVBURRITO_esc/bin/virtualenvwrapper.sh
if ! [ -e $VENVBURRITO_esc/.firstrun ]; then
    echo
    echo "To create a virtualenv, run:"
    echo "mkvirtualenv <cool-name>"
    touch $VENVBURRITO_esc/.firstrun
fi
EOF

# startup virtualenv-burrito in the bash_profile
if [ -s "$HOME/.bash_profile" ]; then
    if ! grep -q "$VENVBURRITO_esc/startup.sh" $HOME/.bash_profile; then
        echo -e "\n# startup virtualenv-burrito\n. $VENVBURRITO_esc/startup.sh" >> ~/.bash_profile
    fi
else
    echo -e "# run .bashrc\n. ~/.bashrc\n\n# startup virtualenv-burrito\n. $VENVBURRITO_esc/startup.sh" > ~/.bash_profile
fi

echo
echo "Done with setup!"
echo
echo "The virtualenvwrapper environment will be available when you login."
echo
echo "To start it now, run this:"
echo "source $VENVBURRITO/startup.sh"
