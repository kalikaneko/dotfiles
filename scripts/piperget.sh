#!/bin/sh
# automated retrieval of pipermail archives & conversion to mbox file
# https://mail.python.org/pipermail/mailman-users/2012-October/074208.html
# Last edit: 2012/10/09 Tue 23:16 PDT
listname=$(echo "$1" | sed 's:^\(http.*\)/\([^/]*\)/$:\2:')
cd /tmp
wget -r -l 1 -nH -A *.txt.gz "$1"
touch /tmp/pipermail/$listname/$listname.mbox
chmod 600 /tmp/pipermail/$listname/$listname.mbox
cd /tmp/pipermail/$listname
for f in $(ls |sort)
do zcat $f | iconv -f iso8859-15 -t utf-8 | sed 's/\(^From.*\)\ at\ /\1@/' >> "$listname.mbox"
done
rm /tmp/pipermail/$listname/*.gz
mutt -f /tmp/pipermail/$listname/$listname.mbox
