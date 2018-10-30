#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## randomly generates passwords for all non-locked accounts
	## locks ALL accounts except for the one you are using
	## will require manual unlocking after infection is purged, almost certainly
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# clean this shit up
	# figure out how to import lists of passwords without using plaintext..
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
#### global backup var ####
backupDir=$HOME"/ccdc_backups/$(echo $(basename "$0") | sed 's/\.sh//')"
###########################################################################################
# If error, give up
set -e
###########################################################################################
#are you root? no? well, try again
###########################################################################################
neo() {
	if [[ $EUID -ne 0  ]]; then
	echo "you forgot to run as root again... "
	echo "Current dir is "$(pwd)
	exit 1
	fi
	}
###########################################################################################
# copies everything to the backupDir
###########################################################################################
antiFuckUp(){
	# creating the dir if it doesn't exist
	if [ ! -d $backupDir ]; then
		command mkdir -p "$backupDir"
	fi
	# copying current states
	command cp /etc/passwd $backupDir/passwd.bak
	command cp /etc/shadow $backupDir/shadow.bak
	}
###########################################################################################
# Locks all accounts except for the one you are on and makes you change password
###########################################################################################
jailer(){
	# allow ctrl+c
	trap "exit" INT
	#### Locking accounts ############################
	users=$(cat /etc/shadow | grep -oP "^.+?(?=:)" | sed "/$(logname)/d" )
    for i in ${users[*]}; do
        command passwd -lq $i
		command printf "\nDisabled Login for: $i"
    done
	#### Changing Password ############################
	command printf "\n\n========== All Accounts Now Locked Except for: $(logname) ==========\n"
	command printf "Changing [$(logname)'s] Password\n\n"
	command passwd $(logname)
	#### Announcing Backup Location ############################
	printf "\n====== original files backed up to $backupDir--$(date +"%Y-%m-%d_%H-%M") ======\n"
	}
###########################################################################################
# zips it all up
###########################################################################################
coldOutside(){
	#### compressing ############################
	command tar -zcf $HOME/ccdc_backups/$(basename "$0" | sed 's/\.sh//')--$(date +"%Y-%m-%d_%H-%M").tar.gz -C $HOME/ccdc_backups $(basename "$0" | sed 's/\.sh//')
	command rm -rf $backupDir
	}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
main(){
	neo
	antiFuckUp
	jailer
	coldOutside
	}
main
