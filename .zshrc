###############################################################################
###  Patterns  ################################################################
###############################################################################

# Case-insensitive globbing
setopt NO_CASE_GLOB

# Sort numerically, not lexicographically, if appropriate
setopt NUMERIC_GLOB_SORT

# Allow some neat globs:
# - Recursive: ls **/foo
# - Negate with ^
# - Levenshtein: (#aX)foobar matches anything with distance X from foobar
setopt EXTENDED_GLOB





###############################################################################
###  Environment  #############################################################
###############################################################################

export EDITOR=vim
export PAGER=less



declare -Ux PATH # U = no duplicates, x = export
declare -Ux MANPATH
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
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.cabal/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.stack/bin:$PATH"

for mandir in $(find "$HOME/Programs" -type d -name man); do
    MANPATH="$mandir:$MANPATH"
done





###############################################################################
###  History  #################################################################
###############################################################################

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/history
setopt APPEND_HISTORY # Append instead of overwrite
setopt HIST_IGNORE_ALL_DUPS # Don't store *any* duplicates in history
setopt HIST_IGNORE_DUPS # Don't store consecutive duplicates in history
setopt SHARE_HISTORY # Share history between shells
setopt HIST_VERIFY # When using a hist thing, make a newline show the change before executing it.





###############################################################################
###  Completion  ##############################################################
###############################################################################

# I don't understand this section very well.

# Some third party completions, e.g. Cabal, GHC
# Taken from e.g. https://github.com/zsh-users/zsh-completions
fpath=($HOME/Programs/zsh-completions/src $fpath)

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Fancy kill completion, not sure whether I need it
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'



hash stack 2>/dev/null && { eval "$(stack --bash-completion-script stack)" }

setopt rm_star_silent






###############################################################################
###  Key bindings  ############################################################
###############################################################################

# Vi bindings
bindkey -v

# Search history with ^R
bindkey '^R' history-incremental-search-backward


# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi





###############################################################################
###  Aliases  ################################################################
###############################################################################

# Autocompletion for aliases
unsetopt COMPLETE_ALIASES # Yes, *un*set. Wat

# Filesystem
alias ..='cd ..'

# "multi-.. aliases"
# ..2 = cd ../..
# ...= cd ../../..
for i in $(seq 2 15); do
    local dots=$(printf '.%.0s' {1..$(($i+1))})
    local dotdots=$(printf '/..%.0s' {1..$(($i-1))})
    alias "$dots=cd ..$dotdots"
    alias "..$i=cd ..$dotdots"
done


# Modifiers
alias -g G=" | grep "
alias -g L=" | less "
alias -g LC=" | wc -l "
alias -g C=" | clipboard "
alias -g TB=" | nc termbin.com 9999 | clipboard "

# List files
LS_COMMON="--group-directories-first --color=always"
alias l="ls -lFh $LS_COMMON"  # Long view, no hidden
alias ll="ls -lAh $LS_COMMON" # Long view, show hidden
alias lh="ls -AF $LS_COMMON"  # Compact view, show hidden

alias g=git
alias depp=git
alias pped=tig

alias s=sublime
sublimeAdd() {
    if [[ "$#" -ne 0 ]]; then
        sublime -a "$@"
    else
        sublime -a .
    fi
}
alias sa=sublimeAdd

alias a=atom
atomAdd() {
    if [[ "$#" -ne 0 ]]; then
        atom -a "$@"
    else
        atom -a .
    fi
}
alias aa=atomAdd

alias r=ranger

alias ta="tig --all"

# Store/delete commits, useful for keeping backups when rebasing
alias -g save='branch save_$(git rev-parse --abbrev-ref HEAD)_$(date +%Y-%m-%d_%H-%M-%S)'
alias delete-all-saves='for savedBranch in $(git branch | grep save_ | sed '"'"'s,\s,,g'"'"'); do git branch -D "$savedBranch"; done'

# Disk usage
alias df='df -h' # Disk free, human readable
alias du='du -hc' # Disk usage for folder, human readable

alias ghci-core="ghci -ddump-simpl \
                      -dsuppress-idinfo \
                      -dsuppress-coercions \
                      -dsuppress-type-applications \
                      -dsuppress-uniques \
                      -dsuppress-module-prefixes"

# Re-sourcing shortcut
alias zz="source $HOME/.zshrc"
# Edit shortcut
alias ze="s -w $HOME/.zshrc && zz"


###############################################################################
###  Navigation  ##############################################################
###############################################################################

# Open file, directory, or current directory if no args present
open() {
    if [[ "$#" -ne 0 ]]; then
        xdg-open "$@"
    else
        xdg-open .
    fi
}
alias o=open

if [[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]]; then
    source $HOME/.autojump/etc/profile.d/autojump.sh
fi





###############################################################################
###  Dirstack  ################################################################
###############################################################################

# Jump back <num> times using cd -<num>
DIRSTACKFILE="$HOME/.zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
fi
chpwd() {
    print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
DIRSTACKSIZE=16
setopt AUTO_PUSHD # Automatically pushd on cd
setopt PUSHD_SILENT # Silence pushd
setopt PUSHD_TO_HOME # Blank pushd goes to ~
setopt PUSHD_IGNORE_DUPS # Don't push duplicates
setopt PUSHD_MINUS # Reverse +/- operators

setopt RM_STAR_WAIT # 10 second waiting period before deleting *




###############################################################################
###  Coloured man pages  ######################################################
###############################################################################

# Credits to http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized

man() {
    env                                         \
        LESS_TERMCAP_mb=$(printf "\e[1;31m")    \
        LESS_TERMCAP_md=$(printf "\e[1;31m")    \
        LESS_TERMCAP_me=$(printf "\e[0m")       \
        LESS_TERMCAP_se=$(printf "\e[0m")       \
        LESS_TERMCAP_so=$(printf "\e[1;47;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m")       \
        LESS_TERMCAP_us=$(printf "\e[1;32m")    \
        man "$@"
}



###############################################################################
###  Prompt  ##################################################################
###############################################################################

autoload -Uz promptinit
promptinit

# Run parameter expansion in prompt variables before interpreting them
setopt PROMPT_SUBST

# Fancy arrows supported by some fonts supported by WhatTheFont
RIGHT_ARROW=""       # echo -e "\xEE\x82\xB0"
RIGHT_ARROW_EMPTY="" # echo -e "\xEE\x82\xB1"
LEFT_ARROW=""        # echo -e "\xEE\x82\xB2"
LEFT_ARROW_EMPTY=""  # echo -e "\xEE\x82\xB3"




CURRENT_BG='NONE'
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}


prompt_dir() {
    prompt_segment black blue '%~'
}
prompt_time() {
    local DATE
    DATE="$(date "+%H:%M:%S")"
    prompt_segment black blue "$DATE"
}
prompt_status() {
    local SYMBOLS
    SYMBOLS=()

    # Print exit code
    [[ $1 -ne 0 ]] && SYMBOLS+="%{%F{black}%}$1"
    # [[ $UID -eq 0 ]] && SYMBOLS+="%{%F{yellow}%}⚡"
    [[ -n "$SYMBOLS" ]] && prompt_segment red default "$SYMBOLS"

}
prompt_whoami() {
    if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment blue black "%(!.%{%F{red}%}.)$USER@%m"
    fi
}
prompt_bol() {
    if [[ $UID -eq 0 ]]; then
        echo "%{%F{red}%}Λ.%{%f%} "
    else
        echo "λ. "
    fi
}

build_prompt() {
    RETVAL=$?
    SEGMENT_SEPARATOR=$RIGHT_ARROW
    prompt_status $RETVAL
    prompt_dir
    prompt_end
}
build_rprompt() {
    SEGMENT_SEPARATOR=$RIGHT_ARROW
    prompt_time
    prompt_whoami
    prompt_end
}

# f/b/k: reset foreground/bold/background
NEWLINE=$'\n'
PROMPT='%{%f%b%k%}$(build_prompt)${NEWLINE}$(prompt_bol)'
RPROMPT='%{%f%b%k%}$(build_rprompt)'



###############################################################################
###  Plugins  #################################################################
###############################################################################

source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"



###############################################################################
###   Local additions   #######################################################
###############################################################################

# Some users of this script might want individual additional config

localZshrc="$HOME/.zshrc-local"
if [[ -e "$localZshrc" ]]; then
    source "$localZshrc"
fi
