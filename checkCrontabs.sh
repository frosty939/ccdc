#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	## lists all cronjobs for all users
	##
	##
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# check atjobs				cat /var/spool/cron/atjobs
	# check timers				systemctl list-timers --all
	# check 'at' jobs			atq
	####
	# this one should have		/var/spool/cron/
	#everything
	#### cronjobs
	#							/etc/default/cron
	#							/etc/init.d/cron
	#							/etc/cron.d/
	#							/etc/cron.daily/
	#							/etc/cron.hourly/
	#							/etc/cron.monthly/
	#							/etc/crontab
	#							/etc/cron.weekly/
	#### at jobs
	#							/var/spool/cron/atjobs
	#							/var/spool/cron/atspool
	#							/proc/loadavg
	#							/var/run/utmp
	#							/etc/at.allow
	#							/etc/at.deny
	######
	# unfuck the crontab &> loop thing
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
main(){
#	backupTheWorld
#	jailer
	testOmatic
	}
# If error, give up
# set -e
#### global backup var ####
backupDir=$HOME"/ccdc_backups/$(basename "$0" | tr -d ".sh")"

###########################################################################################
# testing if the user has a crontab, then sends it to the filter
###########################################################################################
function testOmatic(){
	# making seemingly pointless variable
	#crontab refuses to play nice otherwise
	cronVar=$(mktemp) || exit 1
	# gathering users
	userList=$(command compgen -u)
	userListEmpty=""
	#------------------------------
	# looping through the list of users
	for user in $userList; do
		#sending the command output to cronVar, without sending it.. somehow.. magically..
		command crontab -u $user -l &> "$cronVar"
		#testing if there is a crontab or not
		if grep -sq "no crontab" "${cronVar}" ; then
			#adding user to list without a crontab
			userListEmpty+=${user}$'\n'
		else	#crontab found
			printf "\n[Found crontab for $user]\n$(cat ${cronVar} |
					sed -ne '/For more in/,$p' |
					tail -n +3 |
					sed 's/^/\t/g'
					)"
		fi
	done
	#------------------------------
	printf "\n\n\n============================================================\n"
	printf "\n\t[The users below did NOT have a crontab]\n"
	# display users with empty crontabs
	echo "${userListEmpty}" | column
}


###########################################################################################
# locks down cron use so none run (maybe)
###########################################################################################
jailer(){
	#### PART 1 ############################
	command echo ALL > /etc/cron.deny
	}
###########################################################################################
# backs everything up into a box and puts a bow on it
###########################################################################################
backupTheWorld(){
	# creating the dir if it doesn't exist
	if [[ ! -d $backupDir ]]; then
		command mkdir -p "$backupDir"
	fi
	# creating backups
	if [[ -f /etc/cron.deny ]]; then
		command cp /etc/cron.deny $backupDir
	fi
	}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

main
