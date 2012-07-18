#!/usr/bin/env ksh
# Quick n'dirty mail count script

MAIL_BOX='mbox'
UNAME=`whoami`
SPOOL="/var/mail/$UNAME"
#SPOOL="~/mbox"
SCOUNT=0
TOTAL=0
UCOUNT=0


# Function mailfrom for seeing if there is mail I care about(sender)
# Usage: mailfrom 'email' 'name'
function mailfrom {
	UCOUNT=`grep -c $SPOOL -e "^From $1"`				#Check spool for new mail from $1
	if [[ $UCOUNT = 1 && $TOTAL = 1 ]]; then			
		print "And its from $2!"							#This mail is from $2
		exit 0													#Only message, exiting...
	elif [[ $UCOUNT = 1 && $TOTAL -gt 1 ]]; then		#Grammar police
		print "$UCOUNT of them is from $2"
	elif [[ $UCOUNT -gt 1 ]]; then
		print "$UCOUNT of them are from $2!."
	fi
}

SCOUNT=`grep -c $SPOOL -e '^From '`						#Check spool for all new mail
TOTAL=$(($SCOUNT))

case $1 in
	-h)
		echo "usage: $0 [-h | -s]"
		echo "   -h -- Is what you see here"
		echo "   -s -- Print small mail count"
		;;
	-s)
		print "mail: $TOTAL"
		;;
	*)
		if [[ $TOTAL = 0 ]]; then									#More grammar Police
			print "Looks like no mail for now."
		elif [[ $TOTAL = 1 ]]; then
			print "You have only $TOTAL new message."
		else
			print "You have $TOTAL new messages."
		fi

		# Filters for mail I want
		# example:
		#mailfrom email NameYouWantToDisplay
esac
exit 0
