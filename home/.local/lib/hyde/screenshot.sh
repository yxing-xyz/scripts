#!/usr/bin/env bash

# shellcheck source=$HOME/.local/bin/hyde-shell
# shellcheck disable=SC1091
if ! source "$(which hyde-shell)"; then
	echo "[wallbash] code :: Error: hyde-shell not found."
	echo "[wallbash] code :: Is HyDE installed?"
	exit 1
fi

USAGE() {
	cat <<"USAGE"

	Usage: $(basename "$0") [option]
	Options:
		p     Print all outputs
		s     Select area or window to screenshot
		sf    Select area or window with frozen screen
		m     Screenshot focused monitor

USAGE
}


pre_cmd

case $1 in
p) # print all outputs
	# timeout 0.2 slurp # capture animation lol
	# shellcheck disable=SC2086
	echo 123
	;;
s) # drag to manually snip an area / click on a window to print it
	# shellcheck disable=SC2086
	echo 123
	;;
sf)                                                                                                               # frozen screen, drag to manually snip an area / click on a window to print it
	# shellcheck disable=SC2086
	grim -g "$(slurp -d)" - | swappy -f -
	;;
m)                                                                                                                                  # print focused monitor
	# timeout 0.2 slurp                                                                                                                  # capture animation lol
	# shellcheck disable=SC2086
	grim - | swappy -f -
	;;
*) # invalid option
	USAGE ;;
esac
