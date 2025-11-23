#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# for setting history length
HISTSIZE=999999
HISTFILESIZE=999999

# append to the history file, don't overwrite it
shopt -s histappend

# save multi-line commands in history as single line
shopt -s cmdhist

# Allows you to cd into directory merely by typing the directory name.
shopt -s autocd

# autocorrects cd misspellings
shopt -s cdspell

# update the values of LINES and COLUMNS based on window size
shopt -s checkwinsize

# if interactive shell, ignore upper and lowercase when TAB completion
if [[ $- == *i* ]]; then
    bind "set completion-ignore-case on"
fi

#  colored prompt
# PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h\[\033[01;31m\]:\[\033[01;33m\]\w\[\033[01;35m\]\$ \[\033[00m\]'

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# fuzzy finder config
. /usr/share/fzf/key-bindings.bash
. /usr/share/fzf/completion.bash
export FZF_DEFAULT_OPTS='--extended --layout=reverse --height=50% --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
export FZF_DEFAULT_COMMAND='fd --type f'

# set default editor
export EDITOR=nvim

# bat env
export BAT_THEME="Dracula"

# custom environment variables
. ~/.local/bin/.env

# thfuck env
eval "$(thefuck --alias)"

# Color Manpages
export MANPAGER="less -R --use-color -Dd+g -Du+y"
export MANROFFOPT="-P -c"

# enable starship prompt
eval "$(starship init bash)"

# load pyenv
eval "$(pyenv init -)"

# Fetch alias definitions
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# init zoxide
eval "$(zoxide init bash)"
