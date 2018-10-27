#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
	## check what users exist, logs them, then prints any non-standard users
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# need to "manually" check all ~/.bashrc    ~/.bash_profile    ~/.bash_aliases
	# and check for anything in     /etc/profile    /etc/bashrc    /etc/profile.d
	# check any temporary aliases
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
# global var
backupDir="/tmp/backup-checkAlias"
###########################################################################################
# builds the 2 files for diff to check and copies them to a backup archive
###########################################################################################
#TS: troubleshooting hint
#----------------------
buildEmUp(){
	#### building files ############################
	defList="alias ls='ls --color=auto' alias grep='grep --color=auto' alias fgrep='fgrep --color=auto' alias egrep='egrep --color=auto' alias ll='ls -alF' alias la='ls -A' alias l='ls -CF' alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\\''s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert\$//'\\'')\"'"
	testList=$(cat ~/.bashrc | grep -P "^[\t ]*alias.+" )
	file1="/tmp/.1"
	file2="/tmp/.2"

	echo $defList > $file1
	echo $testList > $file2
	echo ""
	#### formating files ############################
	"sed" -i 's/alias/\n\nalias/g' $file1
	"sed" -i 's/alias/\n\nalias/g' $file2
	#### creating backup stuff ############################
	backup1=$file1".bk"
	backup2=$file2".bk"

	if [ ! -d $backupDir ]; then
		"mkdir" $backupDir
	fi
	"cp" $file1 $backupDir/.defList
	"cp" $file2 $backupDir/.generatedList
	"cp" ~/.bashrc $backupDir/.orig-bashrc
	if [ -f ~/.bash_aliases ]; then
		"cp" ~/.bash_aliases $backupDir/.orig-bash_aliases
	fi
	}

###########################################################################################
# comparing defined list and generated list
###########################################################################################
#TS: troubleshooting hint
#----------------------
whoseNew(){
	#### comparing lists ############################
	printf "\n----- List of Non-Standard Alias in Use -----\n"
	"diff" $file1 $file2 | grep ">"
	printf "\n====== original files backed up to ~/backup-checkAlias--$(date +"YMD,%Y-%m-%d_%H-%M") ======\n"
	}

###########################################################################################
# zipping and removing old files
###########################################################################################
#TS: troubleshooting hint
#----------------------
breakEmDown(){
	"tar" -zcf ~/backup-checkAlias--$(date +"YMD,%Y-%m-%d_%H-%M").tar.gz -C /tmp backup-checkAlias
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
