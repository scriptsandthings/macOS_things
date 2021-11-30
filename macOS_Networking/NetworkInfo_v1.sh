#!/bin/zsh
#
ScriptName="Network Info v1"
#
# This script displays an AppleScript dialog showing the IP addresses of the
# default Ethernet and Airport interfaces, as well as IP addresses for Cisco AnyConnect
# and Palo Alto GlobalProtect VPN
# Script also runs the "networkQuality" command to test upload/download speeds,
# displaying the results via an AppleScript dialog.

# Updated by Greg Knackstedt on 11.30.2021
# shitttyscripts@gmail.com
#
Timestamp=$(date)

CurrentConsoleUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')

GP_IP=$(ifconfig | grep -e "-->" | sed 's/\|/ /'|awk '{print $2}')

OSInfo=$(sw_vers)

HardwareInfo=$(/usr/sbin/system_profiler SPHardwareDataType)

SN=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' 2>&1`

en0=`ipconfig getifaddr en0 2>&1`

en1=`ipconfig getifaddr en1 2>&1`

en2=`ipconfig getifaddr en2 2>&1`

VPN=$(/sbin/ifconfig "utun0" 2>/dev/null | \
/usr/bin/sed -n -e 's|^[[:space:]]*inet \([0-9.]*\).*|\1|p' 2>&1)

VPN1=$(/sbin/ifconfig "utun1" 2>/dev/null | \
/usr/bin/sed -n -e 's|^[[:space:]]*inet \([0-9.]*\).*|\1|p' 2>&1)

VPN2=$(/sbin/ifconfig "utun2" 2>/dev/null | \
/usr/bin/sed -n -e 's|^[[:space:]]*inet \([0-9.]*\).*|\1|p' 2>&1)

GPD=$(/sbin/ifconfig "gpd0" 2>/dev/null | \
/usr/bin/sed -n -e 's|^[[:space:]]*inet \([0-9.]*\).*|\1|p' 2>&1)

GPD1=$(/sbin/ifconfig "gpd1" 2>/dev/null | \
/usr/bin/sed -n -e 's|^[[:space:]]*inet \([0-9.]*\).*|\1|p' 2>&1)

if [ "$en0" = "get if addr en0 failed, (os/kern) failure" ]; then

en0="unavailable"

fi

if [ "$en1" = "get if addr en1 failed, (os/kern) failure" ]; then

en1="unavailable"

fi

if [ "$en2" = "get if addr en1 failed, (os/kern) failure" ]; then

en2="unavailable"

fi


/usr/bin/osascript << EOF
set testResults to do shell script "networkQuality"

tell application "Finder"

activate

display dialog "$ScriptName" & return & return & "$Timestamp" & return & return & "Serial Number:" & return & "$SN" & return & return & "Current User:" & return & "$CurrentConsoleUser" & return & return & "$OSInfo" & return & return & "GlobalProtect VPN IP Address:" & return & "$GP_IP" & return & "$GPD" & return & "$GPD1" & return & return & "Wifi and Ethernet IP Addresses:" & return & "$en0" & return & "$en1" & return & "$en2" & return & return & "Cisco AnyConnect VPN IP Addresses:" & return &"$VPN" & return & "$VPN1" & return & "$VPN2" & return & return & "Network Speed Test Results:" & return & testResults buttons {"OK"} with icon caution

end tell

EOF


exit 0
