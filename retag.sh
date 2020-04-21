#!/bin/bash

# Dest of project dir
PR_DIR="$HOME/Projects/librarian"

# Destenation of config file
CONFIG_PATH="$PR_DIR/.config"

# Read parameters
read DESTINATION GATHER_POINTS FORMAT BUFFER <<< "$(bash $CONFIG_PATH)"
unset GATHER_POINTS FORMAT

read -p "Are your shoure want to retag all files (Y|n) -> "
if [ ! $REPLY == 'Y' ]; then
	echo "Cancel retag programm"
	exit
fi

echo "The program is continue"

dir_before=
mover () {
	for dir in $1/*; do
		if [ -d "$dir" -a ! "$dir" == "$BUFFER" ]; then
			#echo $dir
			dir_before+=":$dir"
			mover "$dir"
			rm -d "${dir_before##*:}"
			#echo rm -d $(basename "${dir_before##*:}")
			dir_before=${dir_before%:*}
		elif [ ! "$dir" == "$BUFFER" ]; then
			#echo move $(basename "$dir") 
			mv "$dir" "$BUFFER"
		fi
	done
}

mover $DESTINATION
