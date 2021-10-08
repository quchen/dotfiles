echo "╭────────────────╮"
echo "│ Loading .zshrc │"
echo "╰────────────────╯"

zshLoadLog() {
    for i in $(/usr/bin/seq 1 "$1"); do
        echo -n " "
    done
    shift
    echo "• $*"
}


###############################################################################
###  Patterns  ################################################################
###############################################################################

zshLoadLog 4 "Pattern configuration"

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

zshLoadLog 4 "Environment, PATH business"

export EDITOR=vim
export PAGER=less

declare -Ux PATH # U = no duplicates, x = export
declare -Ux MANPATH
PATH=""
MANPATH=""

addToPath() {
    [[ -d "$1" ]] && PATH="$1:$PATH" # || zshLoadLog 8 "$1 does not exist – skip PATH entry"
}
addToPath "/usr/local/sbin"
addToPath "/usr/local/bin"
addToPath "/usr/sbin"
addToPath "/usr/bin"
addToPath "/sbin"
addToPath "/bin"
addToPath "/usr/games"
addToPath "/usr/local/games"
for bindir in $(find "$HOME/bin" -type d); do
    addToPath "$bindir"
done
addToPath "$HOME/.local/bin"
NIXPROFILE="$HOME/.nix-profile/etc/profile.d/nix.sh"
[[ -e "$NIXPROFILE" ]] && source "$NIXPROFILE"
unset NIXPROFILE
addToPath "$HOME/.cargo/bin"
addToPath "$HOME/.cabal/bin"
addToPath "$HOME/.local/bin"
addToPath "$HOME/.stack/bin"
addToPath "$HOME/.ghcup/bin"

NIXMAN="$HOME/.nix-profile/share/man"
[[ -e "$NIXMAN" ]] && MANPATH="$NIXMAN:$MANPATH"
unset NIXMAN

unset addToPath






###############################################################################
###  History  #################################################################
###############################################################################

zshLoadLog 4 "History configuration"

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/history
setopt APPEND_HISTORY # Append instead of overwrite
setopt HIST_IGNORE_ALL_DUPS # Don't store *any* duplicates in history
setopt HIST_IGNORE_DUPS # Don't store consecutive duplicates in history
setopt SHARE_HISTORY # Share history between shells
setopt HIST_VERIFY # When using a hist thing, make a newline show the change before executing it.
setopt HIST_IGNORE_SPACE # Don’t add files with leading space to history





###############################################################################
###  Completion  ##############################################################
###############################################################################

zshLoadLog 4 "Autocompletion"

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

zshLoadLog 4 "Key bindings"

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
[[ -n "${key[Home]}"     ]]  && bindkey "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey "${key[PageDown]}" end-of-buffer-or-history

unset key

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
###  Command customization  ###################################################
###############################################################################

zshLoadLog 4 "Command customization"

# ZSH »time« builtin (!)
TIMEFMT=$'CPU seconds %U\nReal time   %E'



###############################################################################
###  Count subshells  #########################################################
###############################################################################

if [[ -z "$ZSH_SUBSHELL_COUNT" ]]; then
    ZSH_SUBSHELL_COUNT=0
else
    ((ZSH_SUBSHELL_COUNT++))
fi
export ZSH_SUBSHELL_COUNT



###############################################################################
###  Dirstack  ################################################################
###############################################################################

zshLoadLog 4 "Dirstack"

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

zshLoadLog 4 "Colored manpages"

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

zshLoadLog 4 "Prompt"

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

isset() {
    eval [ ! -z '${'$1'+x}' ]
}
prompt_dir() {
    prompt_segment black white '%~' # pwd with $HOME abbreviated as ~
}

PROMPT_TAGS:=
prompt_tags() {
    isset "AWS_ACCESS_KEY_ID" && isset "AWS_SECRET_ACCESS_KEY" && PROMPT_TAGS+=('AWS')
    isset "B2_APPLICATION_KEY_ID" && isset "B2_APPLICATION_KEY" && PROMPT_TAGS+=('B2')

    local restic_tags=''
    isset "RESTIC_PASSWORD" && restic_tags+=p
    isset "RESTIC_REPOSITORY" && restic_tags+=r
    [[ -n "$restic_tags" ]] && PROMPT_TAGS+="Restic[$restic_tags]"

    [[ "$ZSH_SUBSHELL_COUNT" -gt 0 ]] && PROMPT_TAGS+="zsh($ZSH_SUBSHELL_COUNT)"

    if [[ ${#PROMPT_TAGS[@]} -gt 0 ]]; then
        # Unique+sort array. Source: https://unix.stackexchange.com/a/167194/23666
        eval "PROMPT_TAGS=($(
            printf "%s\0" "${PROMPT_TAGS[@]}" |
            LC_ALL=C sort -zu |
            xargs -r0 bash -c 'printf "%q\n" "$@"' sh
        ))"
        local joined
        printf -v 'joined' '%s, ' "${PROMPT_TAGS[@]}"
        prompt_segment white black "${joined%, }"
    fi
}
prompt_time() {
    prompt_segment black blue "$(date "+%H:%M:%S")"
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
    prompt_whoami
    prompt_dir
    prompt_tags
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
# RPROMPT='%{%f%b%k%}$(build_rprompt)'



###############################################################################
###  Plugins  #################################################################
###############################################################################

zshLoadLog 4 "Plugins"

fzf-autojump-widget() {
    cd "$(cat "$HOME/.local/share/autojump/autojump.txt" | sort -nr | awk -F '\t' '{print $NF}' | fzf +s)"
    local ret=$?
    zle reset-prompt
    return $ret
}

::() {
    cd "$(
        while [ "$(pwd)" != / ]; do
            pwd
            cd ..
        done | fzf +s --ansi
    )"
}

loadPlugins() {
    local plugin

    plugin="$HOME/.autojump/etc/profile.d/autojump.sh"
    if [[ -s "$plugin" ]]; then
        zshLoadLog 8 "Autojump"
        AUTOJUMP_INSTALLED=true
        source "$plugin"
        # Alias to disable autojump, useful to call before running cd in shell
        # one-liners that would pollute the Autojump db
        alias jno='{ chpwd_functions=(${chpwd_functions[@]/autojump_chpwd}) }'
    else
        zshLoadLog 8 "(Autojump plugin configured in .zshrc, but not found)"
    fi

    plugin="$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ -s "$plugin" ]]; then
        zshLoadLog 8 "Syntax highlighting"
        source "$plugin"
    else
        zshLoadLog 8 "(ZSH syntax highlghting plugin configured in .zshrc, but not found)"
    fi

    plugin="$HOME/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    if [[ -s "$plugin" ]]; then
        zshLoadLog 8 "Better vi mode"
        source "$plugin"
    else
        zshLoadLog 8 "(ZSH vi plugin configured in .zshrc, but not found)"
    fi

    plugin="$HOME/.fzf.zsh"
    if [[ -s "$plugin" ]]; then
        zshLoadLog 8 "fzf – Fuzzy Finder"
        FUZZYFINDER_INSTALLED=true
        source "$plugin"

        FZF_DEFAULT_OPTS='--prompt="λ. "'

        # Search history with ^R
        bindkey '^R' fzf-history-widget
        # Insert files
        bindkey '^K' fzf-file-widget
        # cd to subdir (»J«oin)
        bindkey '^J' fzf-cd-widget

        LIST_DIR_CONTENTS='ls --almost-all --group-directories-first --color=always {}'
        LIST_FILE_CONTENTS='head -n128 {}'
        FZF_ALT_C_OPTS="--preview '$LIST_DIR_CONTENTS'"
        FZF_CTRL_T_OPTS="--preview 'if [[ -f {} ]]; then $LIST_FILE_CONTENTS; elif [[ -d {} ]]; then $LIST_DIR_CONTENTS; fi'"
    else
        zshLoadLog 8 "(Fuzzy Finder plugin configured in .zshrc, but not found)"
    fi

    plugin="$HOME/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
    if [[ -s "$plugin" ]]; then
        zshLoadLog 8 "ZSH+FZF autocompletion"
        source "$plugin"
    else
        zshLoadLog 8 "(ZSH+FZF plugin configured in .zshrc, but not found)"
    fi

    if "${FUZZYFINDER_INSTALLED-false}" && "${AUTOJUMP_INSTALLED-false}"; then
        zshLoadLog 8 "Fuzzyfinder + Autojump <3"
        zle -N fzf-autojump-widget
        bindkey '^P' fzf-autojump-widget
    fi

}
loadPlugins && unset loadPlugins




###############################################################################
###  Installed programs  ######################################################
###############################################################################

zshLoadLog 4 "Installed programs"
checkInstalled() {
    local programExecutable=$1
    local installationCommand=$2
    local installed
    if which "$programExecutable" > /dev/null; then
        installed="[x]"
    else
        installed="[ ]"
    fi
    zshLoadLog 8 "$installed $programExecutable ($installationCommand)"
}

checkInstalled "jq" "jq"
checkInstalled "inotifywait" "apt install inotify-tools"
unset isInstalled
unset checkInstalled




###############################################################################
###  Aliases  ################################################################
###############################################################################

zshLoadLog 4 "Aliases"

# Autocompletion for aliases
unsetopt COMPLETE_ALIASES # Yes, *un*set. Wat

# "multi-.. aliases"
# ..2 = cd ../..
# ...= cd ../../..
dots=..
command=..
for i in {2..5}; do
    alias "$dots=cd $command"
    alias "..$i=cd $command"
    dots="$dots."
    command="$command/.."
done
unset dots
unset command


# Modifiers
alias -g G=" | grep -iP "
alias -g L=" | less "
alias -g LC=" | wc -l "
alias -g C=" | sponge >(clipboard)"
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
alias ze="$EDITOR $HOME/.zshrc && zz"

md() {
    mkdir -p "$@" && cd "$1"
}


echo "╭──────╮"
echo "│ Done │"
echo "╰──────╯"
