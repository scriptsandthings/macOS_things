#!/bin/bash
# Greg Knackstedt
# https://github.com/ShitttyScripts/Shittty_macOS
# gknackstedt(AT)gmail.com
# 2.2.2020
# v1.0
#
# macOS management scripts
#
# Set ARD Field via script
# Tested on macOS 10.12-10.15
#
ScriptName="SetARDField.sh"
LibraryContentLocker="DirectoryName"
#
################### Script Parameters ###################
#
# Flag="Text1" Text2 Text3 Text4
Flag="Text1"
# ARD Kickstart binary path
Binary="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
#
# ARD plist and computer info field
ARDPlistFlag=$(defaults read /Library/Preferences/com.apple.RemoteDesktop $Flag)
#
# JSS Address
SetARDFlag=$(usr/local/jamf/bin/jamf checkJSSConnection | sed -e 's/:*//' | awk -F "/" '{print $3}')
#
################### Log File Functions ###################
#
# Functions to write a local log file
#
# Establish the name of the log file to be created
# $DateTimeStampFull - M.D.Y_01.26.2020_09:53:52
DateTimeStampFull=$(date "+%m.%d.%Y_%H.%M.%S")
#
# Name of log file - Script name + Date time stamp.txt
LogFileName="$ScriptName - $DateTimeStampFull.txt"
#
# Name content locker /Library/DirectoryName
LibraryContentLocker="DirectoryName"
#
# Log file directory
LogDir="/Library/$LibraryContentLocker/logs"
#
# Log file name
LogFile="$LogDir"/"$LogFileName"
#
# Identify currently logged in user
CurrentUser=$(stat -f "%Su" /dev/console)
#
# Write Local Log file to /Library/LibraryContentLocker/logs/LogFileName_DateTime.txt
function LocalScriptLoggingEnabled
	{
		mkdir -p "$LogDir"
		touch "$LogFile"
		exec 3>&1 4>&2 # Save standard output and standard error
		exec 1>>"$LogFile"	# Redirect standard output to logFile
		exec 2>>"$LogFile"	# Redirect standard error to logFile
		echo "########################## Begin Log ##########################" >> "$LogFile"
		echo "$ScriptName" >> "$LogFile"
		echo "$LibraryContentLocker" >> "$LogFile"
		echo "$DateTimeStampFull" >> "$LogFile"
		echo "Current Console User: $CurrentUser" >> "$LogFile"
		echo "System Serial Number: $SystemSN" >> "$LogFile"
	}
	#
################### Script Functions ###################
#
function SetARDComputerInfoField
	{
		if [ -z $ARDPlistFlag ]; then
		  echo "ARD flag $ARDPlistFlag is blank. Setting flag to: $SetARDFlag"
		  $Binary -configure -computerinfo -set1 -1 "$SetARDFlag"
		else
		  if [ $jss != $ARDPlistFlag ]; then
			echo "ARD flag $ARDPlistFlag, is outdated. Updating flag to: $SetARDFlag."
			$Binary -configure -computerinfo -set1 -1 "$SetARDFlag"
		  fi
		fi
	}
#
################### Script ###################
#
LocalScriptLoggingEnabled
SetARDComputerInfoField
