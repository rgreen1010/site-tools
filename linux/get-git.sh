#!/usr/bin/bash
#set -x
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

# [ $debug == true ] && echo " "

#----------------------------------------------------------------------
GIT="/usr/bin/git"
mdate="/usr/bin/date"
MKDIR="/usr/bin/mkdir"
TAR="/usr/bin/tar"
SUFIX=".tar.gz"
#defaultRepo="https://github.com/rgreen1010/site-tools.git"
defaultRepo="https://github.com/rgreen1010/webdev_portfolio.git"


#------------------------------------------
# Default production site(s) location
#------------------------------------------
#siteHome="/var/www/html"
#siteHome="."
#siteDir="TESTsite"
#target="${siteHome}/${siteDir}"


#------------------------------------------
# Default Backup location
#------------------------------------------
defaultBackupDir="./TESTsiteBackups"
siteBackupDir=$defaultBackupDir
backupDir="${siteBackupDir}/${siteDir}"


#----------------------------------------------------------------------
inrepo=""
inBackupDir=""
inMark=""
inHome=""
inSiteName=""
argError=false
debug=false


#----------------------------------------------------------------------
mark=`$mdate '+-%m%d%y'` #default

#----------------------------------------------------------------------

function usage() {
    echo -e "\n Usage: "
    echo -e "\t`basename $0` -n <sitename> "
    echo -e "\t\t[-m <mark>] [-r <repo>] [-h <site home>]"
    echo -e "\t\t[-b <site backup dir>] [-D] \n"
    #echo -e "********************************\n"
    return
}
while getopts "r:m:h:b:n:D" opt; do
    case $opt in
        D) #Debug flag
            debug=true
            echo -e "\n--- DEBUG MODE ENABLED ---"
            ;;
        r) #Repo
                inRepo="$OPTARG"
            #echo "The repo name is $inrepo"
            ;;
        n) # site name (a basename directory excluding path)
            inSiteName="$OPTARG"
            
            inSiteName=`basename $inSiteName`
            ;;
        m) #user specified mark
            inMark="$OPTARG"
            # simple validation   length, basic chars 
            mark=${inMark}     
            #echo " and the mark is $OPTARG"
            ;;
        h)
            inHome="$OPTARG"
            #site home

            if [ ! -d ${inHome} ]; then
                echo -e "\nERROR - Invalid site home: $inHome\n"
                argError=true
                break
            else
                siteHome=${inHome}
            fi
            ;;
        b) #site backup dir
            inBackupDir="$OPTARG"
            
            #echo "The site backup home is $inBackupDir"
            ;;
        *)
            echo -e "\nERROR - Invalid option or argument $OPTARG\n"
            argError=true
            break
            ;;
    esac
done

#[ $debug == true ] && echo "--- DEBUG MODE ENABLED ---"

#----------------------------------------------------------------------
if [ $argError == false ]; then
    if [ -z ${inSiteName} ]; then
        #required
        echo -e "\nERROR - Missing required site name argument\n"
        argError=true
    fi
    [ -z $inHome ] && siteHome="."

    target="${siteHome}/${inSiteName}"
    if [ ! -d ${target} ] || [ ! -r ${target} ]; then
        echo -e "\nERROR - Invalid target directory: $target\n"
        argError=true
    fi
fi

if [ -z ${inBackupDir} ]; then
    siteBackupDir=${defaultBackupDir}
else
    #Validate/create(ask/warn)
    siteBackupDir=${inBackupDir}
fi


if [ $argError == true ]; then
    usage
    echo -e "\n----- Errors encountered, Exiting -----\n"
    exit 1
fi


[ $debug == true ] && echo "Using target: ${target}"


[ $debug == true ] && echo "Using backup directory: ${siteBackupDir}"
#------------------------------
if [ -z ${inRepo} ]; then
    #Validate/create(ask/warn)
    repo=${defaultRepo}
else
    repo=${inRepo}
fi
[ $debug == true ] && echo "Using git Repo: ${repo}"
#------------------------------


#------------------------------
[ $debug == true ] && echo "Using Mark: ${mark}"
[ $debug == true ] && echo "Using site home directory: ${siteHome}"
#------------------------------

#----------------------------------------------------------------------
# Backup current targeted site
#----------------------------------------------------------------------

( $MKDIR -pv $siteBackupDir ) #force it, no error if existing
# need more care on files...


newArchive="${siteBackupDir}/${inSiteName}${mark}${SUFIX}"
tag=0
while [ -e "$newArchive" ]; do
    ((tag++))
    newArchive="${siteBackupDir}/${inSiteName}${mark}-${tag}${SUFIX}"
    [ $debug == true ] && echo "IN newArchive: $newArchive  tag: $tag"
done
 #tar off the site, store the tarball in the backup location
tstat=`$TAR -czf ${newArchive} ${target}`
if [ $tstat ]; then
    echo "Archiving failed. status: $tstat"
    exit $tstat
else
    echo "Completed- newArchive: $newArchive  tag: $tag  status: $tstat"
fi

# delete contents of target dir
(rm -rf ${target})
# git clone the repo and save or rename it as the target (permissions?)
[ $debug == true ] && echo -e " \n -- retrieving git repo: ${repo} into: ${target} "
 (${GIT} clone ${repo} ${target})
 if [ "$?" == "0" ]; then
    echo -e " Done.\n"
    echo -e "\n--- Showing contents of ${target} : "
    (ls -l `basename ${target}`)
else
    echo -e " ** ERROR while attempting to retrieve git repo **\n"
    echo -e " \nlocal target: ${target} archived in: ${newArchive}\n"
    exit 1
fi
#--------------------
# IF NEEDED ---
# force the SELinux file contexts to make the foreign file accessable
# chcon -R -t httpd_sys_content_t <path to file>
#--------------------
