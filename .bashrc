# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
    else
      color_prompt=
    fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -AFhl'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#################################
## Environmental variables
#################################

PATH=""
MANPATH=""
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
PATH="$HOME/.stack/bin:$PATH"

for mandir in $(find "$HOME/Programs" -type d -name man); do
    MANPATH="$mandir:$MANPATH"
done
export PATH
export MANPATH





#################################
## Prompt
#################################

# Root terminal is set in /root/.bashrc
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

    # Handcoded pretty prompt

    cBlack="\[\033[0;30m\]"
    cRed="\[\033[0;31m\]"
    cGreen="\[\033[0;32m\]"
    cYellow="\[\033[0;33m\]"
    cBlue="\[\033[0;34m\]"
    cPink="\[\033[0;35m\]"
    cCyan="\[\033[0;36m\]"
    cGray="\[\033[0;37m\]"
    cDGray="\[\033[0;38m\]"
    cReset="\[\033[0m\]"
    if [[ ${EUID} == 0 ]]
          then # Root
                cLine=$cRed;
          else
                cLine=$cDGray;
    fi
    lineUL="\342\224\214"
    lineBL="\342\224\224"
    lineU="\342\224\200"
    lineEndR="\342\225\274"
    # Show cross-out symbol if last command failed
    # crossOut="\342\234\227"
    # status="\$([[ \$? != 0 ]] && echo \"$cLine$lineU[$cRed$crossOut$cLine]\")"
    timeBox="$cLine$lineU[$cBlack\t$cLine]"
    userBox="$cLine$lineU[$cBlack\u$cLine@$cBlack\h$cLine]"
    currentDir="$cLine$lineU[$cBlue\w$cLine]"
    # Print exit code of last command if it was unsuccessful
    status="\$(lastStatus=\$? && [[ \$lastStatus != 0 ]] && echo \"$cLine$lineU[$cRed$(echo \$lastStatus)$cLine]\")"
    PS1="$cLine$lineUL$timeBox$userBox$currentDir$status\n$cLine$lineBL$lineU$lineU$lineEndR$cReset "

    # PROMPT_COMMAND="Prompt \$?"
    # PS1="└──╼ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
# unset color_prompt force_color_prompt
# unset cBlack cRed cGreen cYellow cBlue cPink cCyan cGray cDGray cReset cLine lineUL lineBL lineU lineEndR crossOut status timeBox userBox currentDir



export EDITOR=vim
export VISUAL=vim



# Autocomplete GHC commands
_ghc()
{
    local envs=`ghc --show-options`
    # get the word currently being completed
    local cur=${COMP_WORDS[$COMP_CWORD]}

    # the resulting completions should be put into this array
    COMPREPLY=( $( compgen -W "$envs" -- $cur ) )
}
complete -F _ghc -o default ghc


[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh
