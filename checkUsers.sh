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
# global var
backupDir="/tmp/backup-checkUsers"
###########################################################################################
# builds the 2 files for diff to check and copies them to a backup archive
###########################################################################################
#TS: troubleshooting hint
#----------------------
buildEmUp(){
	#### building files ############################
	defList="root daemon bin sys sync games man lp mail news uucp proxy www-data backup list irc gnats nobody systemd-network systemd-resolve syslog messagebus _apt lxd uuidd dnsmasq landscape pollinate sshd"
	testList=$(compgen -u)
	file1="/tmp/.1"
	file2="/tmp/.2"

	echo $defList > $file1
	echo $testList > $file2
	echo ""
	#### formating files ############################
	"sed" -i 's/ /\n/g' $file1
	"sed" -i 's/ /\n/g' $file2
	#### creating backup stuff ############################
	backup1=$file1".bk"
	backup2=$file2".bk"

	if [ ! -d $backupDir ]; then
		"mkdir" $backupDir
	fi
	"cp" $file1 $backupDir/.defList
	"cp" $file2 $backupDir/.generatedList
	"cp" /etc/passwd $backupDir/.origPasswd
	}

###########################################################################################
# comparing defined list and generated list
###########################################################################################
#TS: troubleshooting hint
#----------------------
whoseNew(){
	#### comparing lists ############################
	printf "\n----- List of Non-Standard Users on this Box -----\n"
	"diff" $file1 $file2 | grep ">"
	printf "\n====== original files backed up to ~/backup-checkUsers--$(date +"YMD,%Y-%m-%d_%H-%M") ======\n"
	}

###########################################################################################
# zipping and removing old files
###########################################################################################
#TS: troubleshooting hint
#----------------------
breakEmDown(){
	"tar" -zcf ~/backup-checkUsers--$(date +"YMD,%Y-%m-%d_%H-%M").tar.gz -C /tmp backup-checkUsers
	"rm" -rf $backupDir $file1 $file2
}



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
main(){
	buildEmUp
	whoseNew
	breakEmDown
	}
main
