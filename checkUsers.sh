#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
	## check what users exist, logs them, then prints any non-standard users
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# check /etc/profile (see what its doing when making a new profile)
	# check sudoer file (/etc/sudoer   || visudo)
	# fix the things
	# check /etc/shadow and make sure the proper accounts are locked still
	# stop using tmp files. STOP IT!! use mktmp or sed variables
	# check /etc/skel  (responsible for creating stuff for new users)
	# lslogins / last / lastb / lastlog
	# delete iffy users and all files owned by them ( find / -user USER -delete)
	##### FILES
	# Group account information.			/etc/group
	# Secure group account information.		/etc/gshadow
	# Default values for account creation.	/etc/default/useradd
	# Directory containing default files.	/etc/skel/
	# Per user subordinate group IDs.		/etc/subgid
	# Per user subordinate user IDs.		/etc/subuid
	# Shadow password suite configuration.	/etc/login.defs

	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
#### global backup var ####
backupDir=$HOME"/ccdc_backups/$(basename "$0" | tr -d ".sh")"
###########################################################################################
# builds the 2 files for diff to check and copies them to a backup archive
###########################################################################################
buildEmUp(){
	defList="root daemon bin sys sync games man lp mail news uucp proxy www-data backup list irc gnats nobody systemd-network systemd-resolve syslog messagebus _apt lxd uuidd dnsmasq landscape pollinate sshd"
	defListPath="$backupDir""/defList.bak"
	testList="$(compgen -u)"
	testListPath="$backupDir""/testList"
	# creating the dir if it doesn't exist
	if [ ! -d $backupDir ]; then
		command mkdir -p "$backupDir"
	fi
	# creating backups
	command cp -a /etc/passwd $backupDir/origPasswd.bak
	# building files
	echo $defList > $defListPath
	echo $testList > $testListPath
	echo ""
	command sed -i 's/ /\n/g' $defListPath
	command sed -i 's/ /\n/g' $testListPath

	}
###########################################################################################
# comparing defined list and generated list
###########################################################################################
whoDat(){
	#### comparing lists ############################
	printf "\n----- Non-Standard Users on this Box -----\n"
	command diff $defListPath $testListPath | grep ">"
	printf "\n====== original files backed up to $backupDir--$(date +"%Y-%m-%d_%H%M") ======\n"
	}
###########################################################################################
# zipping and removing old files
###########################################################################################
breakEmDown(){
	command tar -zcf $HOME/ccdc_backups/$(basename "$0" | sed 's/\.sh//')--$(date +"%Y-%m-%d_%H%M").tar.gz -C $HOME/ccdc_backups $(basename "$0" | sed 's/\.sh//')
	command rm -rf $backupDir
}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
main(){
	buildEmUp
	whoDat
	breakEmDown
	}
main
