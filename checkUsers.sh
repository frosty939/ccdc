#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
	## check what users exist, logs them, then prints any non-standard users
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# fix the things
	# check /etc/shadow and make sure the proper accounts are locked still
	# stop using tmp files. STOP IT!! use mktmp or sed variables
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
# global var setting $backupDir to ccdc_backups/SCRIPTNAME
backupDir=$HOME"/ccdc_backups/$(echo $(basename "$0") | sed 's/\.sh//')"
###########################################################################################
# builds the 2 files for diff to check and copies them to a backup archive
###########################################################################################
#TS: troubleshooting hint
#----------------------
buildEmUp(){
	defList="root daemon bin sys sync games man lp mail news uucp proxy www-data backup list irc gnats nobody systemd-network systemd-resolve syslog messagebus _apt lxd uuidd dnsmasq landscape pollinate sshd"
	defListPath="$backupDir"/defList.bak""
	testList="$(compgen -u)"
	testListPath="$backupDir"/testList""
	# creating the dir if it doesn't exist
	if [ ! -d $backupDir ]; then
		command mkdir -p "$backupDir"
	fi
	# building files
	echo $defList > $defListPath
	echo $testList > $testListPath
	echo ""
	command sed -i 's/ /\n/g' $defListPath
	command sed -i 's/ /\n/g' $testListPath
	# creating backups
	command cp /etc/passwd $backupDir/origPasswd.bak
	}

###########################################################################################
# comparing defined list and generated list
###########################################################################################
#TS: troubleshooting hint
#----------------------
whoDat(){
	#### comparing lists ############################
	printf "\n----- Non-Standard Users on this Box -----\n"
	command diff $defListPath $testListPath | grep ">"
	printf "\n====== original files backed up to $backupDir--$(date +"%Y-%m-%d_%H-%M") ======\n"
	}

###########################################################################################
# zipping and removing old files
###########################################################################################
#TS: troubleshooting hint
#----------------------
breakEmDown(){
	command tar -zcf $HOME/ccdc_backups/$(basename "$0" | sed 's/\.sh//')--$(date +"%Y-%m-%d_%H-%M").tar.gz -C $HOME/ccdc_backups $(basename "$0" | sed 's/\.sh//')
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
