#!/bin/zsh
#
################################################
#
# Set_Computer_Name_to_Serial_Number.sh
# Version: 2.6
#
# Sets a Mac's computer name, locahost name, and host name to its serial number.
# Run with sudo or via MDM.
#
################################################
#
# Greg Knackstedt
# ShitttyScripts@gmail.com
#
################################################
#
jamfBinary="/usr/local/bin/jamf"
computer_name=$(ioreg -l | grep IOPlatformSerialNumber|awk '{print $4}' | cut -d '"' -f 2)
#
################################################
#
echo "Status: Naming computer '$computer_name'"

/usr/sbin/scutil --set ComputerName "$computer_name"
/usr/sbin/scutil --set LocalHostName "$computer_name"
/usr/sbin/scutil --set HostName "$computer_name"

# Uncomment if using Jamf Pro
# $jamfBinary setComputerName -useSerialNumber

exit 0
