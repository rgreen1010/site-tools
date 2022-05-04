#!/bin/bash
set -x
#----------------------------------------------------------------------
#
#----------------------------------------------------------------------
GIT="/usr/bin/git"
MKDIR="/usr/bin/mkdir"
TAR="/usr/bin/tar"
SUFIX=".tar.gz"
repo="https://github.com/rgreen1010/site-tools.git"

#siteHome="/var/www/html"
siteHome="."
siteDir="siteTarget"
target="${siteHome}/${siteDir}"

#siteBackupDir="/var/www/Backup"
siteBackupDir="./siteBackups"
backupDir="${siteBackupDir}/${siteDir}"
mdate="/usr/bin/date"

# Does the tatget directory exist?  permissions?
if [ -r "${target}" ]; then
    ( $MKDIR -p $backupDir ) #force it, no error if existing
    # need more care on files...

    mark=`$mdate '+-%m%d%y'`
    echo $mark
    #exit 22
    newArchive="${backupDir}/${siteDir}${mark}${SUFIX}"
    tag=0
    while [ -e "$newArchive" ]; do
        ((tag++))
        newArchive="${backupDir}/${siteDir}${mark}-${tag}${SUFIX}"
        echo "IN newArchive: $newArchive  tag: $tag"
    done
     #tar off the site, store the tarball in the backup location
    tstat=`$TAR -czf ${newArchive} ${target}`
    echo "Completed- newArchive: $newArchive  tag: $tag  status: $tstat"
else
    echo "Unreadable/non-existant target: $target"
    exit 15
fi
exit 0

