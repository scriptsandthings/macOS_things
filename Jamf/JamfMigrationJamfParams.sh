#!/bin/bash
# Greg Knackstedt
# https://github.com/ShitttyScripts/Shittty_macOS
# ShitttyScripts(AT)gmail.com
# 2.9.2020
# v1.0a
#
# macOS management scripts
# Targeted for macOS 10.12-10.15
#
# Install system config profile for jump network
# Verify profile is installed
# Verify system is connected to jump network SSID
# Remove current jamf binary
# Verify jamf binary was removed/system has been unenrolled
# Run QuickAdd.pkg to enroll in new Jamf instance
# Verify jamf binary present and connection to new JSS sucessfull
#
ScriptName="JamfMigrationJamfParams.sh"
#
################### Jamf Script Parameters ###################
#
# Company Name for /Library/CompanyName/ standard directory
# Set with Jamf Script Parameter #4
CompanyName="$4"
#
# Name of configuration profile
# Set with Jamf Script Parameter #5
ProfileName="$5"
#
# Name of jump network WiFi SSID
# Set with Jamf Script Parameter #6
JumpNetworkName="$6"
#
# Name of .pkg to be installed
# Set with Jamf Script Parameter #7
PKGName="$7"
#
################### Script Parameters ###################
#
# Path to directory containing config profiles
ProfilePath="/Library/"$CompanyName"/profiles"
#
# Path to directory containing pkg files
PKGPath="/Library/"$CompanyName"/pkg"
#
# Path to jamf Binary
JamfBinary="/usr/local/jamf/bin/jamf"
#
################### Log File Parameters ###################
#
# Current date and time to seconds
# $DateTimeStampFull - Date time stamp - 01-26-2020_09:53:52
DateTimeStampFull=$(date "+%m.%d.%Y_%H.%M.%S")
#
# Name of log file - Script name + Date time stamp.txt
LogFileName=""$ScriptName"_"$DateTimeStampFull".txt"
#
# Log file directory
LogDir=/Library/"$CompanyName"/logs
#
# Log file name
LogFile=""$LogDir"/"$LogFileName""
#
# Identify currently logged in user
CurrentUser=$(stat -f "%Su" /dev/console)
#
# System Serial Number
SystemSN=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#
################### Log File Functions ###################
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
################### SetARDField Script Parameters ###################
#
# Flag="Text1" Text2 Text3 Text4
Flag="Text1"
Flag2="Text2"
Flag3="Text3"
Flag4="Text4"
#
# ARD Kickstart binary path
KickstartBinary="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
#
# ARD Plist
ARDPrefPlist="/Library/Preferences/com.apple.RemoteDesktop.plist"
# ARD plist and computer info field
ARDPlistFlag=$(defaults read $ARDPrefPlist "$Flag")
ARDPlistFlag2=$(defaults read $ARDPrefPlist "$Flag2")
ARDPlistFlag3=$(defaults read $ARDPrefPlist "$Flag3")
ARDPlistFlag4=$(defaults read $ARDPrefPlist "$Flag4")
#
# JSS Address
JSSAddress=$($JamfBinary checkJSSConnection | sed -e 's/:*//' | awk -F "/" '{print $3}')
#
# Jamf Binary Version
JamfBinaryVersion=$($JamfBinary version)
#
# macOS Airport/WiFi binary
AirportBinary="/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport"
#
# Identify Current SSID
CurrentConnectedSSID=$($AirportBinary -I | awk -F: '/ SSID/{print $2}')
#
# Top console user for system
SystemTopConsoleUser=$(ac -p | sort -nk 2 | grep -v reboot | grep -v shutdown | awk '/total/{print x};{x=$1}')
#
################### SetARDField Script Functions ###################
#
# Sets ARD field 1 to the jss address the system is currently enrolled with
function SetARD1CurrentJSSAddress
	{
		if [ -z $ARDPlistFlag ]; then
		  echo "ARD flag $ARDPlistFlag is blank. Setting flag to: $JSSAddress"
		  $KickstartBinary -configure -computerinfo -set1 -1 "$JSSAddress"
		else
		  if [ "$Flag" != "$ARDPlistFlag" ];
		  	then
				echo "ARD flag $ARDPlistFlag, is outdated. Updating flag to: $JSSAddress."
				$KickstartBinary -configure -computerinfo -set1 -1 "$JSSAddress"
		  fi
		fi
	}
#
# Sets ARD Field 2 to the currently installed jamf binary version
function SetARD2JamfBinaryVersion
	{
		if [ -z "$ARDPlistFlag2" ]; then
		  echo "ARD flag $ARDPlistFlag2 is blank. Setting flag to: $JamfBinaryVersion"
		  $KickstartBinary -configure -computerinfo -set2 -2 "$JamfBinaryVersion"
		else
		  if [ "$Flag2" != "$ARDPlistFlag2" ]; then
			echo "ARD flag $ARDPlistFlag2, is outdated. Updating flag to: $JamfBinaryVersion."
			$KickstartBinary -configure -computerinfo -set2 -2 "$JamfBinaryVersion"
		  fi
		fi
	}
#
# Sets ARD field 3 to the currently connected SSID
function SetARD3CurrentConnectedSSID
	{
		if [ -z "$ARDPlistFlag3" ]; then
		  echo "ARD flag $ARDPlistFlag3 is blank. Setting flag to: $CurrentConnectedSSID"
		  $KickstartBinary -configure -computerinfo -set3 -3 "$CurrentConnectedSSID"
		else
		  if [ "$Flag3" != "$ARDPlistFlag3" ]; then
			echo "ARD flag $ARDPlistFlag3, is outdated. Updating flag to: $CurrentConnectedSSID."
			$KickstartBinary -configure -computerinfo -set3 -3 "$CurrentConnectedSSID"
		  fi
		fi
	}
#
# Sets ARD field 4 to the systems top console user - identified locally, not 100% always
# but it's helpful to locate systems in ARD later if a user is not currently logged in
function SetARD4TopConsoleUser
	{
		if [ -z "$ARDPlistFlag4" ]; then
		  echo "ARD flag $ARDPlistFlag4 is blank. Setting flag to: $SystemTopConsoleUser"
		  $KickstartBinary -configure -computerinfo -set4 -4 "$SystemTopConsoleUser"
		else
		  if [ "$Flag4" != "$ARDPlistFlag4" ]; then
			echo "ARD flag $ARDPlistFlag4, is outdated. Updating flag to: $SystemTopConsoleUser."
			$KickstartBinary -configure -computerinfo -set4 -4 "$SystemTopConsoleUser"
		  fi
		fi
	}
#
################### Set Above In ARDField Function ###################
#
# Set all 4 ARD custom computer info fields from functions above.
function SetARDFields
	{
		SetARD1CurrentJSSAddress
		SetARD2JamfBinaryVersion
		SetARD3CurrentConnectedSSID
		SetARD4TopConsoleUser
	}
#
################### Jamf10Migration Script Functions ###################
#
# Import .mobileconfig profile for jump network
function ImportProfile
	{
		profiles -I -F "$ProfilePath"/"$ProfileName"
	}
#
# Verify that the jump network profile is installed before moving on with the reenrollment
function VerifyProfileInstalled
	{

	}
#
# Verify that system has connected to the jump network SSID successfully before removing
# old Jamf enrollment
function VerifySSIDConnected
	{
		$CurrentConnectedSSID | # pipe to something here to verify it is correct maybe
		# The var $JumpNetworkName set with Jamf $6 will be the correct SSID name
		# or another while loop until $CurrentConnectedSSID=$JumpNetworkName
	}
#
# Unenroll from JSS/Remove framework/binary
function JamfUnenroll
	{
		$JamfBinary removeFramework
	}
#
# A loop to see if jamf binary is installed and return version
# Probably a "$ if "[ -f "$FILE" ]; then else" to see if the binary exists
# followed by jamf version and storing that to a value
# figure out how to only use the first 5 charicters like 10.18 or 9.xx or something similar
function VerifyJamfUnenrollComplete
	{
		# do things here
	}
#
# A loop to see if jamf binary is installed and return version
# Probably a "$ if "[ -f "$FILE" ]; then else" to see if the binary exists
# followed by jamf version and storing that to a value or checkJSSConnection to verify address
# figure out how to only use the first 5 charicters like 10.18 or 9.xx or something similar
# JSSAddress function above finds current jss address system is reporting to
function VerifyJamfEnrollComplete
	{
		echo "$JamfBinaryVersion"
		echo "$JSSAddress"
	}
#
# Run QuickAdd.pkg
function InstallQuickAddPKG
	{
		installer -allowUntrusted -verbose -pkg "$PKGPath"/"$PKGName"
	}
#
################### Script ###################
LocalScriptLoggingEnabled
JSSScriptLoggingEnabled
SetARDFields
ImportProfile
VerifyProfileInstalled
VerifySSIDConnected
SetARDFields
JamfUnenroll
VerifyJamfUnenrollComplete
InstallQuickAddPKG
SetARDFields
VerifyJamfEnrollComplete
