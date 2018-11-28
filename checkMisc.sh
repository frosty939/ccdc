#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
#=======================================================================================
	##
	##
	##
########################################################################################
########################################################################################
	#
	#*************** NEED TO DO/ADD ***********************
	# check apt install history		/var/log/apt/history.log
	# check apt install stuff		apt-mark showmanual
	# check apt manual installs		grep -i "Commandline" /var/log/apt/history.log
	#### startup stuff
	# https://askubuntu.com/questions/218/command-to-list-services-that-start-on-startup
	# check startup services		ls /lib/systemd/system/*.service /etc/systemd/system/*.service
	# 								systemctl list-unit-files --type=service
	#								ls /etc/init.d/
	#								ls /etc/rc*.d/
	#								initctl list
	# check init script				/lib/init/init-d-script
	# check vars script				/lib/init/vars.sh
	# fstab							/etc/fstab
	#### systemctl stuff
	# check sockets					systemctl list-sockets --all
	# check units					systemctl list-units
	#### firewall stuff
	# check ufw script				vim /lib/ufw/ufw-init
	#### network stuff
	# check resolv file				/lib/systemd/network/*
	#### drivers
	# dirty confs and such			/etc/modules
	#								/etc/modprobe.d/*.conf
	#								/lib/modprobe.d
	#								/lib/modules
	#								/lib/modules-load.d
	#### user agents
	# check user agents trying to connect, most/all kali tools will have their name as their user agent
	#### sudoers file				/etc/sudoers
	#								/etc/sudoers.d
	# check for any weird changes, you know the drill
	#### default files
	# debconf						/etc/debconf.conf
	# deluser						/etc/deluser.conf
	#								/etc/default/*
	# keyboard						/etc/default/keyboard
	#### bash completion
	#								/usr/share/bash-completion/*
	#******************************************************
	#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
# If error, give up
# set -e
###########################################################################################
#FUNCTION1 description
###########################################################################################
function1(){
	#### PART 1 ############################
	}
###########################################################################################
#FUNCTION2 description
###########################################################################################
function2(){
	#### PART 1 ############################
	}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
main(){
	function1
	function2
	}
main
