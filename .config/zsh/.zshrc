GITSTATUS_LOG_LEVEL=DEBUG
# Commands
if test "$PWD" = "$HOME" && test "$0" !=  "$SHELL"; then
	neofetch --config $XDG_CONFIG_HOME/neofetch/config-short.conf
	task next limit:3
	timew | head -3
fi 2>/dev/null || return 0

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

DEFAULT_USER=$USER

ZSH_THEME="powerlevel10k/powerlevel10k"
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator context dir rbenv vcs) POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs time)
#ZSH_CUSTOM=$ZSH/custom

HIST_STAMPS="yyyy-mm-dd" # history command timestamps

# COMPLETION
# ENABLE_CORRECTION="true" # Correct command arguments
HYPHEN_INSENSITIVE="true" # - and _ interchangeable
COMPLETION_WAITING_DOTS="true" # Dots while waiting for completion
DISABLE_UNTRACKED_FILES_DIRTY="true" # DOn't mark untracked files as dirty - speeds up status check


# Plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
	#git
	gitfast
	#git-auto-fetch
	fast-syntax-highlighting
	zsh-autosuggestions
	zsh-vim-mode
	history-substring-search
)

_comp_options+=(globdots) # Show files starting with dot in autocomplete
fpath=($fpath "$CONFIG_ZSH/completion") # Custom completions
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION" # Cache completions
DISABLE_UPDATE_PROMPT=true
ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

## Functions

tab_list_files() {
  if [[ $#BUFFER == 0 ]]; then
    BUFFER="ls "
    CURSOR=3
    zle list-choices
    zle backward-kill-word
  elif [[ $BUFFER =~ ^[[:space:]][[:space:]].*$ ]]; then
    BUFFER="./"
    CURSOR=2
    zle list-choices
    [ -z ${TAB_LIST_FILES_PREFIX+x} ] && BUFFER="  " CURSOR=2
  elif [[ $BUFFER =~ ^[[:space:]]*$ ]]; then
    BUFFER="cd "
    CURSOR=3
    zle list-choices
    [ -z ${TAB_LIST_FILES_PREFIX+x} ] && BUFFER=" " CURSOR=1
  else
    BUFFER_=$BUFFER
    CURSOR_=$CURSOR
    zle expand-or-complete || zle expand-or-complete || {
      BUFFER="ls "
      CURSOR=3
      zle list-choices
      BUFFER=$BUFFER_
      CURSOR=$CURSOR_
    }
  fi
}
zle -N tab_list_files
bindkey '^I' tab_list_files

fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    bg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N fancy-ctrl-z
bindkey '^z' fancy-ctrl-z
bindkey '^q' push-line-or-edit

export KEYTIMEOUT=1

# Obsolete: zsh-vim-mode plugin - Custom VIM bindings {{{
#bindkey -v
#autoload -Uz history-search-end
#
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end
#
#bindkey -M vicmd '^[[A' history-beginning-search-backward-end \
#                 '^[OA' history-beginning-search-backward-end \
#                 '^[[B' history-beginning-search-forward-end \
#                 '^[OB' history-beginning-search-forward-end
#bindkey -M viins '^[[A' history-beginning-search-backward-end \
#                 '^[OA' history-beginning-search-backward-end \
#                 '^[[B' history-beginning-search-forward-end \
#                 '^[OB' history-beginning-search-forward-end
# }}}

# Obsolete: powerlevel10k - Show time on the right after executing command {{{
# strlen() {
#   FOO=$1
#   local zero='%([BSUbfksu]|([FB]|){*})'
#   LEN=${#${(S%%)FOO//$~zero/}}
#   echo $LEN
# }
# preexec() {
#   DATE=$( date +"[%H:%M:%S]" )
#   local len_right=$( strlen "$DATE" )
#   len_right=$(( $len_right+1 ))
#   local right_start=$(($COLUMNS - $len_right))
#
#   local len_cmd=$( strlen "$@" )
#   local len_prompt=$(strlen "$PROMPT" )
#   local len_left=$(($len_cmd+$len_prompt))
#
#   RDATE="\033[${right_start}C ${DATE}"
#
#   if [ $len_left -lt $right_start ]; then
#     # command does not overwrite right prompt - ok to move up one line
#     echo -e "\033[1A${RDATE}"
#   else
#     echo -e "${RDATE}"
#   fi
# }
# }}}

## User configuration

# turn on spelling correction
setopt correct
# don't save duplicates in command history
setopt histignoredups

setopt EXTENDED_GLOB
unsetopt CASE_GLOB

setopt pipefail

# Enable zmv (see ZSHCONTRIB(1))
autoload zmv
alias zmv='noglob zmv'
alias zmw='noglob zmv -W'
alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'
alias zsy='noglob zmv -Ls'

for file in $CONFIG_SHELLS/*; do source $file; done

# GENERATED SHIT

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
test -s $CONFIG_ZSH/.p10k.zsh && source $CONFIG_ZSH/.p10k.zsh

test -d /usr/share/fzf && source /usr/share/fzf/key-bindings.zsh && source /usr/share/fzf/completion.zsh

eval "$(zoxide init zsh)"

test -f $XDG_CONFIG_HOME/broot/launcher/bash/br && source $XDG_CONFIG_HOME/broot/launcher/bash/br

# Nix
test -e /home/janek/.nix-profile/etc/profile.d/nix.sh && source /home/janek/.nix-profile/etc/profile.d/nix.sh
which direnv >/dev/null && eval "$(direnv hook zsh)"

true
