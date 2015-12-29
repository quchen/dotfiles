# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

PATH="/usr/local/sbin:$PATH"
PATH="/usr/local/bin:$PATH"
PATH="/usr/sbin:$PATH"
PATH="/usr/bin:$PATH"
PATH="/sbin:$PATH"
PATH="/bin:$PATH"
PATH="/usr/games:$PATH"
PATH="/usr/local/games:$PATH"
for bindir in $(find "$HOME/bin" -type d); do
    PATH="$bindir:$PATH"
done
PATH="$HOME/.cabal/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"

for mandir in $(find "$HOME/Programs" -type d -name man); do
    MANPATH="$mandir:$MANPATH"
done
