#!/bin/bash

#
# Author: Sami Barakat <sami@sbarakat.co.uk>
# Date: 21/11/2011
#
# This script is used on a mail server to collect email messages from the Junk
# and Trash folders. Emails that are over 30 days old are moved to /bak/spam/
# then archived into a date and time stamped tar.gz file. Ideally this script
# should be executed every so often from a cron job.
#

cd /bak/;
mkdir /bak/spam;

find /srv/vmail -regex '.*/\.\(Trash\|Junk\)\(/.*\)?\/\(cur\|new\)/.*' -type f -mtime +30 | while read line
do
    mkdir -p /bak/spam`dirname ${line} | sed -e 's/srv\/vmail\///'`;
    mv ${line} /bak/spam`echo ${line} | sed -e 's/srv\/vmail\///'`;
done

tar -cvpzf "`date +"%F %H%M"` Spam Backup.tar.gz" /bak/spam/;
rm -r /bak/spam/;
