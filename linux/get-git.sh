#!/bin/bash
#----------------------------------------------------------------------
#
#----------------------------------------------------------------------
# This is an attempt to automate my web site(app) publishing
# process.  
# Source files originate on a windows system.  
# Primary creation and editing occurs in sublime text
# The project(s) are archived, under source control, on github
#
# My general process is to use a VM to provide a Linux environment
# running an apache httpd server, php, mysql.  This server then provides
# access to the web app under development, allowing a browswer client to
# connect and test the different aspects and appearances of the application.
#
# Since the server and development system are "separate" there needs to 
# be a publishing process.
#repo and localdir from commandline, (use getopt?)
#----------------------------------------------------------------------
#       https://github.com/rgreen1010/site-tools.git
#  initialized by: 
# echo "# site-tools" >> README.md
# git init
# git add README.md
# git commit -m "first commit"
# git branch -M main
# git remote add origin https://github.com/rgreen1010/site-tools.git
# git push -u origin main
#----------------------------------------------------------------------
#----------------------------------------------------------------------
git="/usr/bin/git"
repo="https://github.com/rgreen1010/site-tools.git"
siteHome=""
localDir=""
backupDir="/var/www/Backup"
#----------------------------------------------------------------------
inrepo=""
while getopts "r:m:" opt; do
    case $opt in
    r)
    #Repo
    inrepo="$OPTARG"
    echo "The repo name is $inrepo" >&2
    ;;
    m)

    #Reading second argument
    echo " and the marks is $OPTARG" >&2
    ;;
    *)

    #Printing error message
    echo "invalid option or argument $OPTARG"
    ;;
    esac
done
#----------------------------------------------------------------------
if [ -z "$inrepo"]; then
fi

#----------------------------------------------------------------------
# save any existing localdir (tarball)
mdate="/usr/bin/date"

if [ -d "$backupDir" ]; then
    if [ -d "$localDir" ]; then
        # not the first site backup
        tag=0;
        mark=`$mdate '+-%m%d%y-%H%M%S'`
        newArchive="${localDir}${mark}${tag}"
        while [ -e "$newArchive" ]; do
            echo "IN newArchive: $newArchive  tag: $tag"
            tag++ 
            newArchive="${localDir}${mark}${tag}"
        done
        echo "Completed- newArchive: $newArchive  tag: $tag"
    fi
fi

# git clone the repo and save or rename it as localdir
# force the SELinux file contexts to make the foreign file accessable
# chcon -R -t httpd_sys_content_t <path to file>
