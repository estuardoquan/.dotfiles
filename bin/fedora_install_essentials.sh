#!/bin/sh

dnf check-update
dnf update -y
dnf install -y \
	git \
	iperf3 \
	wireguard-tools \
	tmux \
	neovim \
	stow

