#!/bin/bash
# Greg Knackstedt
# https://github.com/ShitttyScripts/Shittty_macOS
# ShitttyScripts(AT)gmail.com
# 2.2.2020
# v1.0
#
# macOS management scripts
# Tested on macOS 10.12-10.15
#
# Turns on/activates network service
# Sets network service as the highest priority serice.
#
# This script is set to be used with Jamf's built in script parameters
# These are defined/located in the Script Parameters region, lines 36-42.
#
ScriptName="macOSPreferredNetworkServiceJamf.sh"
#
# This script has a standardized logging function for debugginging/troubleshooting
# Lines 43-124.
# The standard parameters for the logging function are located
# in the Log File Parameters region lines 43-72.
#
# The logging functions are located in the Log Files Functions region lines 73-124.
# To enable local logging, call the LocalScriptLoggingEnabled function
# at the beginning of the script.
#
# To enable logging to the JSS , call the JSSScriptLoggingEnabled function
# at the beginning of the script.
# By Default, these are the first 2 functions called. You may leave them in place,
# and comment out with # to disable logging. Called on lines 144-145 respectively.
#
# The default 3rd function called in the script is ARDField, called on line 146.
# Located in the Log Files Functions section. It may also be commented out with # to bypass.
#
################### Script Parameters ###################
#
# Use Jamf Script Parameter 4 to define name of company for common directory in /Library/
CompanyName="$4"
#
# Use Jamf Script Parameter 5 to define which network service you want to target
NetworkService="$5"
################### Log File Parameters ###################
#
# Current date and time to seconds
# $DateTimeStampFull - Date time stamp - 01-26-2020_09:53:52
DateTimeStampFull=$(date "+%m.%d.%Y_%H.%M.%S")
#
# Name of log file - Script name + Date time stamp.txt
LogFileName="$ScriptName_$DateTimeStampFull.txt"
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
#
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
function LocalScriptLoggingEnabled
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
function EnableNetworkService
	{
	networksetup -setairportpower Wi-Fi on
	networksetup -setnetworkserviceenabled "$NetworkService" on
	}
#
function ListNetworkServicePriority
	{
		networksetup -listnetworkserviceorder
	}
#
# Set wifi as the highest priority network service
function SetPriorityNetworkService
	{
		echo "networksetup -ordernetworkservices "$NetworkService" `networksetup -listallnetworkservices | grep -v 'An asterisk ' |  sed s/\^'*'// | grep -v NetworkService | sed 's/.*/\"&\"/' | tr '\n' ' '` "| bash
	}
################### Script ###################
LocalScriptLoggingEnabled
JSSScriptLoggingEnabled
EnableNetworkService
ListNetworkServicePriority
SetPriorityNetworkService
ListNetworkServicePriority
