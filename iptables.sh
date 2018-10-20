#!/bin/bash
#=======================================================================================
#=== DESCIPTION ========================================================================
##saves current iptables settings
##applies specified rules and config changes
##pay no attention to obvious fuckups.. im sure i had a reason and didn't just derp >.>
########################################################################################
########################################################################################
#
#*************** NEED TO DO/ADD ***********************
# test non-ubuntu18.04
# cry as you realize you have to redo everything for compatibility
# sed configs and make necessary changes
# add ipv6 support
# error checking for wrong read entry
# garbage collection for rules backups
# clean up how the iptable rules get applied. still very slow..
# add limits to port hits
# add options to skip the prompts
# install and configure fail2ban. probably should have done this first.. but meh
# netmask on intIP (trying $(hostname - I)/24 adds a trailing space "x.x.x.x /24" and causes some weirdness
# better exit info upon completion
# figure out why iptables -L is so slow after adding the INPUT drop rule
# find gateway and put it where it needs to be for allowing ntp
# deal wiht fuckups caused by launching with sh instead of bash
#******************************************************
#
#///////////////////////////////////////////////////////////////////////////////////////
#|||||||||||||||||||||||| Script Stuff Starts |||||||||||||||||||||||||||||||||||||||||
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#
#
###########################################################################################
#are you root? no? well, let me help
###########################################################################################
#TS:
#----------------------
neo() {
	if [[ $EUID -ne 0  ]]; then
	echo "you forgot to run as root again... "
	echo "Current dir is "$(pwd)
	exit 1
	fi
}
###########################################################################################
#checking for, and installing, iptables/persistence/fail2ban
###########################################################################################
#TS:
#----------------------
makeItSo() {
	if ! dpkg-query -W -f='${Status}' iptables | grep -q "ok installed"; then
		apt install iptables -y
		echo ""
	fi
	if ! dpkg-query -W -f='${Status}' iptables-persistent | grep -q "ok installed"; then
		apt install iptables-persistent -y
		echo ""
	fi
	#if ! dpkg-query -W -f='${Status}' fail2ban | grep -q "ok installed"; then
		#apt install fail2ban -y
		#echo ""
	#fi
}
###########################################################################################
#backing up whatever the current settings are
###########################################################################################
#TS:
#----------------------
backupTheWorld() {
	if [ ! -e /firewall/rules ]; then   #checking if /firewall/rules exists
		mkdir -p /firewall/rules          #creating it
	fi
		iptables-save > /firewall/rules/autoSaved--$(date +"YMD,%Y-%m-%d_%H-%M").rules
	echo ""
	echo "========================================================================|"
	echo "Saved current iptable to /firewall/rules/autosaved--$(date +"YMD,%Y-%m-%d_%H-%M")|"
	echo "========================================================================|"
}
###########################################################################################
#selecting our server type so we know which rules to use
###########################################################################################
#TS: if shit gets wonky, if you have mulTSle live interfaces, that is likely the cause.. working on it..
#----------------------
whatWeDoin() {
	#### Empty ############################
	empty()
	{
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT ACCEPT [0:0]
			:FORWARD ACCEPT [0:0]
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	#### Standard ############################
	standard()
	{
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT DROP [0:0]
			## allows ssh connections
			-A INPUT -p tcp --dport 22 -j ACCEPT
			## allows established connections
			-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			:FORWARD DROP [0:0]
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	#### Attacker ############################
	atk()
	{
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT DROP [0:0]
			## allows ssh connections
			#-A INPUT -p tcp --dport 22 -j ACCEPT
			## allows established connections
			-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			:FORWARD DROP [0:0]
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	#### Website ############################
	web()
	{
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT DROP [0:0]
			## allows ssh connections
			#-A INPUT -p tcp --dport 22 -j ACCEPT
			## open http/https web server port
			-A INPUT -p tcp --dport 80 -j ACCEPT
			-A INPUT -p tcp --dport 443 -j ACCEPT
			## allows ping replies
			-A INPUT -p icmp --icmp-type 8 -j ACCEPT
			## allows established connections
			-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			## logs... something?
			-A INPUT -m limit --limit 5/min -j LOG --log-prefix "FART-OVERLOAD " --log-level 7
			:FORWARD DROP [0:0]
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	#### Mail Server ############################
	mail()
	{
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT DROP [0:0]
			## allows ssh connections
			#-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
			## allows smtp
			-A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
			## allows imap
			-A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
			## allows pop3
			-A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
			## allows ping replies
			-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
			## allows established connections
			-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			## logs... something?
			-A INPUT -m limit --limit 5/min -j LOG --log-prefix "FART-OVERLOAD " --log-level 7
			:FORWARD DROP [0:0]
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	#### Router ############################
	router()
	{
		read -p "Mail Server IP: " mailIP
		read -p "Web Server IP: " webIP
		read -p "Allowed SOURCE for SSH connections[192.168.0.0/24]: " sshIP
		: ${sshIP:="192.168.0.0/24"}
		"cat" <<-EOF > /etc/iptables/rules.v4
			*filter
			:INPUT DROP [0:0]
			## allows ssh connections
			-A INPUT -s $sshIP -p tcp --dport 22 -j ACCEPT
			## allows ping replies
			-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
			## allows established connections
			-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			## logs... something?
			-A INPUT -m limit --limit 5/min -j LOG --log-prefix "FART-OVERLOAD " --log-level 7
			:FORWARD DROP [0:0]
			-A FORWARD -p tcp -d $mailIP --dport 25 -j ACCEPT
			-A FORWARD -p tcp -d $mailIP --dport 110 -j ACCEPT
			-A FORWARD -p tcp -d $mailIP --dport 143 -j ACCEPT
			-A FORWARD -p tcp -d $webIP --dport 443 -j ACCEPT
			-A FORWARD -p tcp -d $webIP --dport 80 -j ACCEPT
			-A FORWARD -p icmp --icmp-type 8 -j ACCEPT
			## allows established connections
			-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
			## logs... something
			-A FORWARD -m limit --limit 5/min -j LOG --log-prefix "FART-OVERLOAD " --log-level 7
			:OUTPUT ACCEPT [0:0]
			COMMIT
			EOF
		"iptables-restore" /etc/iptables/rules.v4
	}
	####################
	#sending the selection forward
	####################
	printf " q|quit      =   Cancels the script                                     |\n"
	printf " 0|empty     =   Rules are cleared, everything is accepted              |\n"
	printf " 1|standard  =   SSH and Established Input. Drop the rest               |\n"
	printf " 2|atk       =   Only established Input                                 |\n"
	printf " 3|web       =   Allow ping, http(gross), and https                     |\n"
	printf " 4|mail      =   Allow pop, imap, smtp                                  |\n"
	printf " 5|router    =   Forward pop/imap/smtp/pings/http/https. Allow SSH/Ping |"
	printf "\n------------------------------------------------------------------------|\n"
	read -p "what kind of server are we?[standard]: " host
	: ${host:="standard"}    # setting the starting value to apply default settings

	case $host in
		q|quit)
			exit 1;;
		0|empty)
			empty;;
		1|standard)
			standard;;
		2|ATK|atk|attacker|attack)
			atk;;
		3|WEB|web|website)
			web;;
		4|MAIL|mail|email|e-mail)
			mail;;
		5|ROUTER|router)
			router;;
	esac
}

summary(){
	printf "\n\n"
	printf "\n******************************************************************"
	printf "\nHopefully everything went as planned.. Here is the current iptable"
	printf "\n******************************************************************\n\n"
	iptables -L
}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++ FIGHT!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
main() {  #runs stuff, sometimes even in order
	neo
	makeItSo
	backupTheWorld
	whatWeDoin
	summary
	printf "\n\n"
}
main
