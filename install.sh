#!/usr/bin/env sh

function get_os() {
    local OS=$(uname -s)

    case "$OS" in
        Linux)
            if [ -f /etc/os-release ]; then
                source /etc/os-release
                echo $ID
            fi
            ;;
        FreeBSD)
            echo "FreeBSD"
            ;;
        Darwin)
            echo "macOS"  # also BSD-ish, in case you care
            ;;
        *)
            echo "Unknown OS: $OS"
            ;;
    esac
}

TARGET=$(get_os)

P=t:dhr
Q=target:delete,reset,help

if ! O=$(getopt --options $P --longoptions $Q -- "$@"); then
        return 1;
fi

eval set -- "$O"

DEL=2#10
RUN=2#01

ACTION=0

while true; do
	case "$1" in
        -t|--target)
        	TARGET=$2
		shift 2
		;;
        -d|--delete)
		(( ACTION |= DEL ))
		shift
		;;
        -r|--reset)
		(( ACTION |= DEL|RUN ))
		shift
		;;
        -h|--help)
		echo HELP: running "$TARGET"
		exit 0
		;;
        --)
		shift
		break;;
	esac
done

if ! (( ACTION & DEL )); then
	(( ACTION |= RUN ))
fi

TARGET="common $TARGET"


for t in $TARGET; do
	set -- -t /home/$USER
	
	if [ -d $t ]; then
		set -- $@ -d $t
	else
		echo fail ignoring $t
		continue
	fi

	if (( ACTION & DEL )); then
		stow $@ -D .
	fi

	if (( ACTION & RUN )); then
		stow $@ .
	fi
done
