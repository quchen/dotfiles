###############################################################################
###  Utilities for later :-)  #################################################
###############################################################################

isset() {
    eval [ ! -z '${'$1'+x}' ]
}

is_installed() {
    which "$1" >/dev/null
}


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

{
    declare -Ux PATH # U = no duplicates, x = export
    PATH=""
    add_to_path() { [[ -d "$1" ]] && PATH="$1:$PATH" }
    add_to_path "/usr/local/sbin"
    add_to_path "/usr/local/bin"
    add_to_path "/usr/sbin"
    add_to_path "/usr/bin"
    add_to_path "/sbin"
    add_to_path "/bin"
    add_to_path "/usr/games"
    add_to_path "/usr/local/games"
    for bindir in $(find "$HOME/bin" -type d); add_to_path "$bindir"
    add_to_path "$HOME/.local/bin"
    add_to_path "$HOME/.cargo/bin"
    add_to_path "$HOME/.cabal/bin"
    add_to_path "$HOME/.local/bin"
    add_to_path "$HOME/.stack/bin"
    add_to_path "$HOME/.fzf/bin"
    unfunction add_to_path
}

(){
    local NIXPROFILE="$HOME/.nix-profile/etc/profile.d/nix.sh"
    [[ -e "$NIXPROFILE" ]] && source "$NIXPROFILE"
}

{
    declare -Ux MANPATH
    MANPATH=':' # see `man manpath`: suffix colon means $MANPATH is prepended to /etc/manpath.config
    add_to_manpath() { [[ -d "$1" ]] && MANPATH="$1:$MANPATH" }
    add_to_manpath "$HOME/.nix-profile/share/man"
    add_to_manpath "$HOME/Programs/zoxide/man"
    for mandir in $(find "$HOME/Programs" -type d -name man); add_to_manpath "$mandir"
    unfunction add_to_manpath
}




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
setopt HIST_IGNORE_SPACE # Don’t add files with leading space to history





###############################################################################
###  Completion  ##############################################################
###############################################################################

# I don't understand this section very well.

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

# ZSH »time« builtin (!)
TIMEFMT=$'CPU seconds %U\nReal time   %E'

if is_installed bat; then
    export BAT_THEME='Solarized (light)'
fi

if is_installed rg; then
    export RIPGREP_CONFIG_PATH=~/.config/ripgrep/ripgreprc
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
###  Prompt  ##################################################################
###############################################################################

autoload -Uz promptinit
promptinit

# Run parameter expansion in prompt variables before interpreting them
setopt PROMPT_SUBST

# Fancy arrows supported by some fonts supported by WhatTheFont
RIGHT_ARROW=""       # echo -e "\xEE\x82\xB0"
RIGHT_ARROW_EMPTY="" # echo -e "\xEE\x82\xB1"
RIGHT_ARROW_EMPTY_2="❯"
LEFT_ARROW=""        # echo -e "\xEE\x82\xB2"
LEFT_ARROW_EMPTY=""  # echo -e "\xEE\x82\xB3"




PROMPT_CURRENT_BG='NONE'
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $PROMPT_CURRENT_BG != 'NONE' && $1 != $PROMPT_CURRENT_BG ]]; then
        echo -n " %{$bg%F{$PROMPT_CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    PROMPT_CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $PROMPT_CURRENT_BG ]]; then
        echo -n " %{%k%F{$PROMPT_CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi
        echo -n "%{%f%}"
    PROMPT_CURRENT_BG=''
}

prompt_colorize() {
    local fcolor=$1
    local content=$2
    echo -n "%{%F{$fcolor}%}$content%{%f%}"
}

prompt_color_picker() {
    local query=$(tr -dc '[:print:]' <<<"$*")
    if [[ $query == "main" ]]; then
        echo -n 'blue'
    elif [[ $query == "pi" ]]; then
        echo -n 'green'
    else
        local colors=(red blue green cyan yellow magenta)
        local hash=$( md5sum <<<"x$query" | tr -dc '[0-9]' | head -c8 )
        local index=$(( ${hash} % ${#colors[*]} + 1))
        echo -n "$colors[$index]"
    fi
}

prompt_color_word_by_hash() {
    prompt_colorize "$(prompt_color_picker "$1")" "$1"
}

prompt_dir() {
    prompt_segment black white ""
    {
        # pwd
        print -Pn '%~'
    } | {
        # Remove leading / (root dir)
        sed -e "s/^\///"
    } | {
        if "${colorize_prompt_segments:-false}"; then
            # Colorize path components by hash
            dir=$(cat)
            result=()
            dir_segments=("${(@s,/,)dir}")
            for segment in "${dir_segments[@]}"; do
                result+=("$(prompt_color_word_by_hash "$segment")")
            done
            echo -n ${(j:/:)result}
        else
            cat
        fi
    } | {
        # Intersperse with fancy symbol
        sed -e "s/\// %{%F{blue}%}${RIGHT_ARROW_EMPTY_2}%{%F{white}%} /g"
    }
}

prompt_tags() {
    isset "PROMPT_TAGS" || PROMPT_TAGS=()

    isset "AWS_ACCESS_KEY_ID" && isset "AWS_SECRET_ACCESS_KEY" && PROMPT_TAGS+=('AWS')
    isset "B2_APPLICATION_KEY_ID" && isset "B2_APPLICATION_KEY" && PROMPT_TAGS+=('B2')

    local restic_tags=''
    isset "RESTIC_PASSWORD" && restic_tags+=p
    isset "RESTIC_REPOSITORY" && restic_tags+=r
    [[ -n "$restic_tags" ]] && PROMPT_TAGS+=("Restic[$restic_tags]")

    if [[ ${#PROMPT_TAGS[@]} -gt 0 ]]; then
        # Unique+sort array. Source: https://unix.stackexchange.com/a/167194/23666
        eval "PROMPT_TAGS=($(
            printf "%s\0" "${PROMPT_TAGS[@]}" |
            LC_ALL=C sort -zu |
            xargs -r0 bash -c 'printf "%q\n" "$@"' sh
        ))"
        local joined
        printf -v 'joined' '%s, ' "${PROMPT_TAGS[@]}"
        echo -n "${joined%, }$SEGMENT_SEPARATOR"
    fi
}
prompt_time() {
    echo -n "%*"
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
        prompt_color_word_by_hash "$USER"
        echo -n '@'
        prompt_color_word_by_hash "$HOST"
        echo -n "$SEGMENT_SEPARATOR"
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
    SEGMENT_SEPARATOR=" $LEFT_ARROW_EMPTY "
    prompt_tags
    prompt_whoami
    prompt_time
}

# f/b/k: reset foreground/bold/background
NEWLINE=$'\n'
PROMPT='%{%f%b%k%}$(build_prompt) %{%f%b%k%}'
if ! isset "TMUX"; then
    RPROMPT='%{%f%b%k%}$(build_rprompt)%{%f%b%k%}'
fi

# TMOUT=1
TRAPALRM() {
    if ! [[ "$WIDGET" =~ ^(complete-word|fzf-)  ]]; then
        zle reset-prompt
        # echo "[$WIDGET]" # To find out what to add to the pattern above :-)
    fi
}



###############################################################################
###  Plugins  #################################################################
###############################################################################

__load_plugin() {
    local plugin=${1?"Plugin name parameter missing"}
    [[ -s "$plugin" ]] && source "$plugin" || return 1
}

__load_plugin "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if __load_plugin "$HOME/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"; then
    ZVM_LINE_INIT_MODE="$ZVM_MODE_INSERT"
    ZVM_INSERT_MODE_CURSOR="$ZVM_CURSOR_BEAM"
    ZVM_NORMAL_MODE_CURSOR="$ZVM_CURSOR_BLOCK"
    ZVM_VI_HIGHLIGHT_BACKGROUND="black"
    ZVM_VI_HIGHLIGHT_FOREGROUND="white"
    ZVM_VI_HIGHLIGHT_EXTRASTYLE="bold,underline"
fi

if __load_plugin "$HOME/.fzf/shell/key-bindings.zsh"; then
    FUZZYFINDER_INSTALLED=true

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
    # Fall back to ZSH’s standard history search. Ugh
    bindkey '^R' history-incremental-search-backward
fi


if is_installed zoxide; then
    eval "$(zoxide init zsh --cmd j)"

    j+() { [ $# -eq 0 ] && zoxide add . || zoxide add "$@" }
    j-() { [ $# -eq 0 ] && zoxide remove -- . || zoxide remove -- "$@" }
elif __load_plugin "$HOME/.autojump/etc/profile.d/autojump.sh"; then
    # Alias to disable autojump, useful to call before running cd in shell
    # one-liners that would pollute the Autojump db
    alias jno='{ chpwd_functions=(${chpwd_functions[@]/autojump_chpwd}) }'

    j+() { [ $# -eq 0 ] && autojump --increase 100 || autojump --increase "$1" }
    j-() { [ $# -eq 0 ] && autojump --decrease 100 || autojump --decrease "$1" }

    if "${FUZZYFINDER_INSTALLED-false}"; then
        ji() {
            cd "$(cat "$HOME/.local/share/autojump/autojump.txt" | sort -nr | awk -F '\t' '{print $NF}' | fzf +s)"
        }
    fi
fi

__load_plugin "$HOME/.fzf/shell/completion.zsh"

unfunction __load_plugin



###############################################################################
###  Installed programs  ######################################################
###############################################################################

check_tooling() {
    __check_tooling_single() {
        local program=$1; shift
        local howToInstall=$1; shift

        if is_installed "$program"; then
            echo "[x] $program"
        else
            echo "[ ] $program – $howToInstall"
        fi
    }
    __check_tooling_single exa         "apt-get install exa"
    __check_tooling_single fzf         "sudo apt-get install fzf"
    __check_tooling_single inotifywait "apt-get install inotify-tools"
    __check_tooling_single jq          "apt-get install jq"
    __check_tooling_single rg          "apt-get install ripgrep"
    __check_tooling_single sponge      "apt-get install moreutils"
    __check_tooling_single zoxide      "DL manually from https://github.com/ajeetdsouza/zoxide, the webinstaller is a dotfile-modifying shitscript"
    unfunction __check_tooling_single
}




###############################################################################
###  Aliases  #################################################################
###############################################################################

# Autocompletion for aliases
unsetopt COMPLETE_ALIASES # Yes, *un*set. Wat

(){
    # "multi-.. aliases"
    # ...= cd ../../..
    local dots=..
    local dir=..
    for i in {2..5}; do
        alias "$dots=cd $dir"
        dots="$dots."
        dir="$dir/.."
    done
}

if is_installed rg; then
    alias -g G=" | rg --smart-case "
else
    alias -g G=" | grep --ignore-case --perl-regexp "
fi
alias -g L=" | less "
alias -g LC=" | wc -l "
alias -g C=" | sponge >(clipboard)"
alias -g RED="2> >(sed $'s,.*,\e[31m&\e[m,'>&2)"

(){
    if is_installed exa; then
        local exa_common="--long --classify --header --time-style long-iso --group-directories-first --group"
        alias l="exa $exa_common"
        alias ll="exa $exa_common --all"
    else
        local ls_common="-l --group-directories-first --color=always --human-readable --file-type"
        alias l="ls $ls_common"
        alias ll="ls $ls_common --almost-all"
    fi
}

alias g=git
alias depp=git
alias pped=tig
alias s=subl
alias r=ranger
alias ta="tig --all"
alias df='df -h' # Disk free, human readable
alias du='du -shc' # Disk usage for folder, human readable
alias zz="source ~/.zshrc"
alias ze="\"$EDITOR\" ~/.zshrc && zz"

o() { [[ "$#" -ne 0 ]] && xdg-open "$@" || xdg-open . }
jq() { command jq --indent 4 "$@" }
sa() { [[ "$#" -ne 0 ]] && subl -a "$@" || subl -a . }
ca() { [[ "$#" -ne 0 ]] && code -a "$@" || code -a . }
::() {
    cd "$(
        while [ "$(pwd)" != / ]; do
            pwd
            cd ..
        done | fzf +s --ansi
    )"
}
+x() { chmod +x "$@" }
md() { mkdir -p "$@" && cd "$1" }
trash() { gio trash "$@" }
tmux() {
    if [[ $# -eq 0 ]] && petname=$(petname --separator '-'); then
        command tmux new -s "_$petname"
    else
        command tmux "$@"
    fi
}
man() {
    # Colored manpages! Credits to http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
    # mb: Start blinking
    # md: Start bold mode
    # me: End all mode like so, us, mb, md and mr
    # so: Start standout mode
    # se: End standout mode
    # us: Start underlining
    # ue: End underlining

    local reset=$'\e[0m'
    local bold=$'\e[1m'
    local underline=$'\e[4m'
    local black=$'\e[30m' red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' blue=$'\e[34m' cyan=$'\e[35m' magenta=$'\e[36m' white=$'\e[37m'
    local black_bg=$'\e[40m' red_bg=$'\e[41m' green_bg=$'\e[42m' yellow_bg=$'\e[43m' blue_bg=$'\e[44m' cyan_bg=$'\e[45m' magenta_bg=$'\e[46m' white_bg=$'\e[47m'

    LESS_TERMCAP_mb=$bold$red             \
    LESS_TERMCAP_md=$bold$red             \
    LESS_TERMCAP_me=$reset                \
    LESS_TERMCAP_so=$bold$yellow$white_bg \
    LESS_TERMCAP_se=$reset                \
    LESS_TERMCAP_us=$bold$blue$underline  \
    LESS_TERMCAP_ue=$reset                \
    command man "$@"
}


###############################################################################
###  Tmux  ####################################################################
###############################################################################

export TERM="xterm-256color"
