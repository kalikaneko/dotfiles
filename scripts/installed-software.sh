#!/bin/sh
dpkg --get-selections > installed-software
touch top_dependents # create file to list top dependents
while read PAK # read installed-software file, line-by-line
do
           if [ "$(apt-cache rdepends $PAK | tail -1)" != "Reverse Depends:" ] # is the reverse depends (i.e. dependents) list empty? (can also be implemented using sed instead of tail)
           then echo "$PAK has dependents" # user feedback. can be commented out
           else
                      echo "$PAK is top dependent" # user feedback. can be commented out
                      echo $PAK >> top_dependents # append to top dependents list
fi
done < installed-software
