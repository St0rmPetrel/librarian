#!/bin/bash

# Destenation of config file
CONFIG_PATH="./.config"

# Read parameters
read DESTINATION GATHER_POINTS FORMAT BUFFER <<< "$(bash $CONFIG_PATH)"
unset GATHER_POINTS FORMAT

# Function for making dir if it not exist
mkdir_ifne () {
        if [ ! -d $1 ]; then
                mkdir -p $1
        fi
}

# Destenation of tag storage file
TAG_PATH="$DESTINATION/history"

# If tag file or destonation dir of it don't exist, then make it
mkdir_ifne "$DESTENETION"
touch "$TAG_PATH"

# If is some book in buffer, befor procesing show 
# current time
FILES=$BUFFER/*
if [ -n "$FILES" ]; then
	echo "#$(date +"%R   %d %B %Y")" >> "$TAG_PATH"
fi
unset FILES

# Function wich can create and transfer books in main 
# tag directores
is_comment () {
        if [ ${1:0:1} = "#" ]; then
                return 0
        fi
        return 1
}
trans () {
        local HISTORY_PATH="$1/history"
        while read line; do
                is_comment $line
                if [ ! $? -eq 0 ]; then
                        local FUTER_PATH=${line%%[ ]*}
                        temp=${line##*/}
                        book_name=${temp%%[ ]*}
                        if [ -e "$BUFFER/$book_name" ]; then
                                mkdir_ifne "${FUTER_PATH%/*}"
                                mv $BUFFER/$book_name $FUTER_PATH
                        fi
                fi
        done < $HISTORY_PATH
        unset temp book_name
}


# Function for show exist directores and main tags
# in destenation dir (../Book)
has_dir () {
        for file in $1/*; do
                if [ -d "$file" ]; then
                        return 0
                fi
        done
        return 1
}
tabs=""
show () {
        for dir in $1/*; do
                if [ -d "$dir" ]; then
                        has_dir $dir
                        if [ $? -eq 0 ]; then # If dir has sub_dirs
                                echo -e "${tabs}x| $(basename $dir)"
                                tabs+="\t"
                                show $dir
                                tabs="${tabs:2}"
                        else
                                echo -e "${tabs}x| $(basename $dir)"
                        fi
                fi
        done
}


# At first make tags in cycle for every file in a buffer
# Creating history file
echo "#### It is tree of alrady exist main tags ####"
show "$DESTINATION"
echo "Now add tags for each book in form:
book -> main_tag[/subtag1...] [add_tag1:addtag2...]"
for book in $BUFFER/*; do
	read -p "$(basename $book) -> "
	grep -P -q "^([a-zA-Z][\w]*)(/[a-zA-Z][\w]*)*([ ]([\w]+)(:[\w]+)*)*$" <<< "$REPLY"
	if [ $? -eq 0 ]; then
		read main_tags add_tags <<< "$REPLY"
		echo "${DESTINATION}/$main_tags/$(basename $book) $add_tags" >> "$TAG_PATH"
	else
		echo "Syntax Error"
	fi
	echo
done
# Move files from Buffer, base on history file
trans "$DESTINATION"
