#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## check what users exist, logs them, then prints any non-standard users
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# need to "manually" check all $HOME/.bashrc    $HOME/.bash_profile    $HOME/.bash_aliases
	# and check for anything in     /etc/profile    /etc/bashrc    /etc/profile.d
	# check any temporary aliases
	# clean up syntax and what not
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
#### global backup var ####
backupDir=$HOME"/ccdc_backups/$(echo $(basename "$0") | sed 's/\.sh//')"
###########################################################################################
# builds the 2 files for diff to check and copies them to a backup archive
###########################################################################################
buildEmUp(){
	#### creating backup stuff ############################
	if [ ! -d $backupDir ]; then
		command mkdir -p $backupDir
	fi
	#### building files ############################
	defList="alias ls='ls --color=auto' alias grep='grep --color=auto' alias fgrep='fgrep --color=auto' alias egrep='egrep --color=auto' alias ll='ls -alF' alias la='ls -A' alias l='ls -CF' alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\\''s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert\$//'\\'')\"'"
	defListPath="$backupDir/defList.bak"
	testList=$(cat "$HOME/.bashrc" | grep -P "^[\t ]*alias.+" )
	testListPath="$backupDir/testList.bak"

	echo $defList > $defListPath
	echo $testList > $testListPath
	echo ""
	#### formating files ############################
	command sed -i 's/alias/\n\nalias/g' $defListPath
	command sed -i 's/alias/\n\nalias/g' $testListPath
	#### copying current states ############################
	command cp $HOME/.bashrc $backupDir/bashrc.bak
	if [ -f $HOME/.bash_aliases ]; then
		command cp $HOME/.bash_aliases $backupDir/bash_aliases.bak
	fi
	}
###########################################################################################
# comparing defined list and generated list
###########################################################################################
whoDat(){
	#### comparing lists ############################
	printf "\n----- List of Non-Standard Alias in Use -----\n"
	command diff $defListPath $testListPath | grep ">"
	printf "\n====== original files backed up to $backupDir--$(date +"%Y-%m-%d_%H-%M") ======\n"
	}
###########################################################################################
# zipping and removing old files
###########################################################################################
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
