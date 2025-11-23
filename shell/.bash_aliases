#!/bin/bash

IPINFO_TOKEN=''

# my aliases
alias ls='eza --icons --group-directories-first --group'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ipp='curl -s -4 icanhazip.com | xargs -I{} -- curl ipinfo.io/{}?token=${IPINFO_TOKEN} && echo'
alias dotlink="pushd ${HOME}/.dotfiles/; ls -I extra | xargs -I{} -- stow -v {} ; popd"
alias ll='ls -lh'
alias cat='bat -p'
alias sshsocks='autossh -M 0 -f -q -N -D ${SOCKS_PORT} root@${SERVER}'
alias u='pkg-update'
alias c='pkg-clean'
alias p='ping 8.8.8.8'
alias pb='ping bbc.com'
alias se='edit-scripts'
alias ssh-vpn='sshuttle --dns -v --exclude ${SERVER} --exclude 192.168.0.0/16 --exclude 10.0.0.0/8 --exclude 172.16.0.0/12 -r root@${SERVER} 0/0'
alias d='axel -a -n 10 -o ~/Downloads'
alias bb='curl rate.sx/?n=15'
alias b='btop'
alias t='tmux'
alias http-server='python3 -m http.server'
alias http-proxy='ssh -f -N -n -L0.0.0.0:8080:127.0.0.1:8888 root@${SERVER}'
alias s='autossh -M 0 -l root'
alias ports='netstat -tupln'
alias v='nvim'
alias brc='vim ~/.bashrc'
alias mount='sudo mount'
alias umount='sudo umount'
alias us="pacman -Quq | xargs expac -S -H M '%k\t%n' | sort -rsh"
alias h='htop'
alias pssh='ps -fC ssh'
alias mgg='mgraftcp --http_proxy 127.0.0.1:8000 --select_proxy_mode only_http_proxy '
alias mgs='mgraftcp --socks5 127.0.0.1:8888 '
alias mgp='mgraftcp --socks5 127.0.0.1:9999 '
alias "check-cert"='openssl x509 -text -noout -in <(wl-paste)'
alias df="df -h"
alias pxc="proxychains -q "
alias yt="youtube-dl"
alias nb="newsboat"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias y="yay -Syu"
alias yn="yay -Syu --noconfirm"
alias yyn="yay -Syyu --noconfirm"
alias srsync="time rsync -auvP --info=progress2"
alias fj="firejail --dns=1.1.1.1 --net=$(ls /sys/class/ieee80211/*/device/net/)"
alias fjn="firejail --net=none"
alias rm='rm -i'
alias load-nvm="[ -f /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh"
alias tdp='toggle-dnscrypt-proxy'
alias ff='fastfetch'
alias nt="notes"
alias tb='toggle-bluetooth'
alias vd='vnstat -d'
alias update-mirror-list='sudo reflector --latest 20 --country US --protocol https --sort rate --score 10 --save /etc/pacman.d/mirrorlist'
alias polkit-gnome="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
alias i='sudo intel_gpu_top'
alias toggle-dunst='dunstctl set-paused toggle'
alias zj='zellij'
alias set-timezone='timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"'
alias ts-cp='tailscale file cp'
alias ts-list='tailscale switch --list'

# docker related aliases
alias dp='docker ps'
alias dpa='docker ps -a'
alias dv='docker volume ls'
alias di='docker images'
alias ddf='docker system df'
alias drm='docker rm -f $(docker ps -aq); docker volume rm $(docker volume ls -q)'
alias sds='sudo systemctl start docker.service; systemctl status --no-pager docker.service'
alias tds='sudo systemctl stop docker.service; sudo systemctl stop docker.socket'

# my functions
dssh() {
    ssh-keygen -R "$1"
}

ds() {
    dssh "$1"
    s "$1"
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

expose_port() {
    socat TCP-LISTEN:8080,fork,reuseaddr TCP:127.0.0.1:"$1"
}

# bash completion
source /usr/share/bash-complete-alias/complete_alias
complete -F _complete_alias "${!BASH_ALIASES[@]}"
