#!/bin/bash

# Destenation of config file
CONFIG_PATH="./.librarian/config"

# Read parameters
read DESTINATION GATHER_POINTS FORMAT BUFFER <<< "$(bash $CONFIG_PATH)"

# Is Destenetion and Buffer exist. If it not, create it
if [ ! -d $DESTENATION ]; then 
	mkdir --parents $DESTENATION
fi
if [ ! -d $BUFFER ]; then
        mkdir --parents $BUFFER
fi

# Found files in FORMAT
OLD_IFS="$IFS"
IFS=":"
str=
for exten in $FORMAT; do
	if [ ! -z $str ]; then str+="|"; fi
        str+="(\.$exten)"
done
regex="($str){1}(\.zip)?"

for path in $GATHER_POINTS; do
	IFS="$OLD_IFS"
	if [ ! -d $path ]; then # Is Gather Point exist, if it not return error
		echo "Error: \'$path\' directory is not exist" >&2
		exit 1
	fi
	for file in $path/*; do
		grep --perl-regex --silent $regex <<< "$file"
		if [ $? -eq 0 ]; then
			grep --perl-regex --silent ".zip$" <<< "$file"
			if [ $? -eq 0 ]; then
				unzip -q $file -d $BUFFER
				if [ $? -eq 0 ]; then 
					rm $file 
				else
					echo "Error: unzip $file -d $BUFFER" >&2
				fi
			else
				mv $file $BUFFER
				if [ ! $? -eq 0 ]; then
                                        echo "Error: mv $file $BUFFER" >&2
                                fi

			fi
		fi
	done
	IFS=":"
done
IFS="$OLD_IFS"
unset OLD_IFS
