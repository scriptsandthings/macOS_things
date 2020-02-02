#!/bin/bash
# Greg Knackstedt
# https://github.com/ShitttyScripts/Shittty_macOS
# gknackstedt(AT)gmail.com
# 2.2.2020
# v1.0
#
# macOS management scripts
# Tested on macOS 10.12-10.15
#
# Turn Ethernet on
# Set Ethernet as the highest priority network service.
#
#
ScriptName="macOSEthernetPreferredNetworkService.sh"
#
################### Log File Parameters ###################
#
# Current date and time to seconds
# $DateTimeStampFull - Date time stamp - 01-26-2020_09:53:52
DateTimeStampFull=$(date "+%m.%d.%Y_%H.%M.%S")
#
# Name of log file - Script name + Date time stamp.txt
LogFileName="$ScriptName_$DateTimeStampFull.txt"
#
# Name of company for common directory in /Library/
CompanyName="CompanyName"
#
# Log file directory
LogDir="/Library/$CompanyName/logs"
#
# Log file name
LogFile="$LogDir"/"$LogFileName"
#
# Identify currently logged in user
CurrentUser=$(stat -f "%Su" /dev/console)
#
# System Serial Number
SystemSN=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#
# ARD Kickstart path
KickstartBinary='/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/KickstartBinarystart'
#
# ARD plist and computer info field
ARDPlist=$(defaults read /Library/Preferences/com.apple.RemoteDesktop Text1)
# JSS Address
JSSAddress=$(/usr/local/jamf/bin/jamf checkJSSConnection | sed -e 's/:*//' | awk -F "/" '{print $3}')
#
################### Log File Functions ###################
#
# Populate ARD field with JSS address
function ARDField
	{
		if [ -z $field ]; then
		  $log "ARD flag is blank. Setting flag to: $jss"
		  $KickstartBinary -configure -computerinfo -set1 -1 "$jss"
		else
		  if [ $jss != $field ]; then
			$log "ARD flag $ARDPlistFlag, is outdated. Updating flag to: $jss"
			$KickstartBinary -configure -computerinfo -set1 -1 "$jss"
		  fi
		fi
	}
#
# Write Local Log file to /Library/CompanyName/logs/LogFileName_DateTime.txt
	{
		mkdir -p "$LogDir"
		touch "$LogFile"
		echo "$LogFile"
		exec 3>&1 4>&2 # Save standard output and standard error
		exec 1>>"$LogFile"	# Redirect standard output to logFile
		exec 2>>"$LogFile"	# Redirect standard error to logFile
		echo "########################## Begin Log ##########################" >> "$LogFile"
		echo "$ScriptName" >> "$LogFile"
		echo "$ScriptName" >> "$LogFile"
		echo "$CompanyName" >> "$LogFile"
		echo "$DateTimeStampFull" >> "$LogFile"
		echo "Current Console User: $CurrentUser" >> "$LogFile"
		echo "System Serial Number: $SystemSN" >> "$LogFile"
	}
# Log Jamf script paramaters
function LogJamfParams
	{
		ARDField
		echo "$4" >> "$LogFile"
		echo "$5" >> "$LogFile"
		echo "$6" >> "$LogFile"
		echo "$7" >> "$LogFile"
		echo "$8" >> "$LogFile"
		echo "$9" >> "$LogFile"
		echo "$10" >> "$LogFile"
		echo "$11" >> "$LogFile"
	}
function JSSScriptLoggingEnabled
	{ # Re-direct logging to the JSS
		JssLoggingEnabled "${1}"
		exec 1>&3 2>&4
		echo >&1 ${1}
	}
#
################### Script Functions ###################
#
function EnableEthernet
	{
	networksetup -setnetworkserviceenabled Ethernet on
	}
#
function ListNetworkServicePriority
	{
		networksetup -listnetworkserviceorder
	}
#
# Set Ethernet as the highest priority network service
function SetEthernetPriorityNetworkService
	{
		echo "networksetup -ordernetworkservices "Ethernet" `networksetup -listallnetworkservices | grep -v 'An asterisk ' |  sed s/\^'*'// | grep -v Ethernet | sed 's/.*/\"&\"/' | tr '\n' ' '` "| bash
	}
################### Script ###################
LocalScriptLoggingEnabled
EnableEthernet
ListNetworkServicePriority
SetEthernetPriorityNetworkService
ListNetworkServicePriority
