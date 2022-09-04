#!/bin/bash
# Greg Knackstedt
# https://github.com/ShitttyScripts/Shittty_macOS
# gknackstedt(AT)gmail.com
# 2.2.2020
# v2.0
#
# macOS management scripts
# Tested on macOS 10.12-10.15
# Set ARD Field via script
# SetARDField.sh
#
# 1 - Jss address
# 2 - Jamf binary version
# 3 - Current SSID
# 4 - Top console user
#
#
################### Script Parameters ###################
#
# Flag="Text1" Text2 Text3 Text4
Flag="Text1"
Flag2="Text2"
Flag3="Text3"
Flag4="Text4"
#
# ARD Kickstart binary path
Binary="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
#
# ARD plist and computer info field
ARDPlistFlag=$(defaults read /Library/Preferences/com.apple.RemoteDesktop.plist "$Flag")
ARDPlistFlag2=$(defaults read /Library/Preferences/com.apple.RemoteDesktop.plist "$Flag2")
ARDPlistFlag3=$(defaults read /Library/Preferences/com.apple.RemoteDesktop.plist "$Flag3")
ARDPlistFlag4=$(defaults read /Library/Preferences/com.apple.RemoteDesktop.plist "$Flag4")
#
# JSS Address
SetARDFlag=$(/usr/local/jamf/bin/jamf checkJSSConnection | sed -e 's/:*//' | awk -F "/" '{print $3}')
#
# Jamf Binary Version
SetARDFlag2=$(/usr/local/jamf/bin/jamf version)
#
# Current SSID
SetARDFlag3=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
#
# Top console user for system
SetARDFlag4=$(ac -p | sort -nk 2 | grep -v reboot | grep -v shutdown | awk '/total/{print x};{x=$1}')
#
################### Script Functions ###################
#
function SetARDComputerInfoField
	{
		if [ -z "$ARDPlistFlag" ]; then
		  echo "ARD flag $ARDPlistFlag is blank. Setting flag to: $SetARDFlag"
		  $Binary -configure -computerinfo -set1 -1 "$SetARDFlag"
		else
		  if [ "$Flag" != "$ARDPlistFlag" ];
		  	then
				echo "ARD flag $ARDPlistFlag, is outdated. Updating flag to: $SetARDFlag."
				$Binary -configure -computerinfo -set1 -1 "$SetARDFlag"
		  fi
		fi
	}
#
#
function SetARDComputerInfoField2
	{
		if [ -z "$ARDPlistFlag2" ]; then
		  echo "ARD flag $ARDPlistFlag2 is blank. Setting flag to: $SetARDFlag2"
		  $Binary -configure -computerinfo -set2 -2 "$SetARDFlag2"
		else
		  if [ "$Flag2" != "$ARDPlistFlag2" ]; then
			echo "ARD flag $ARDPlistFlag2, is outdated. Updating flag to: $SetARDFlag2."
			$Binary -configure -computerinfo -set2 -2 "$SetARDFlag2"
		  fi
		fi
	}
#
function SetARDComputerInfoField3
	{
		if [ -z "$ARDPlistFlag3" ]; then
		  echo "ARD flag $ARDPlistFlag3 is blank. Setting flag to: $SetARDFlag3"
		  $Binary -configure -computerinfo -set3 -3 "$SetARDFlag3"
		else
		  if [ "$Flag3" != "$ARDPlistFlag3" ]; then
			echo "ARD flag $ARDPlistFlag3, is outdated. Updating flag to: $SetARDFlag3."
			$Binary -configure -computerinfo -set3 -3 "$SetARDFlag3"
		  fi
		fi
	}
#
function SetARDComputerInfoField4
	{
		if [ -z "$ARDPlistFlag4" ]; then
		  echo "ARD flag $ARDPlistFlag4 is blank. Setting flag to: $SetARDFlag4"
		  $Binary -configure -computerinfo -set4 -4 "$SetARDFlag4"
		else
		  if [ "$Flag4" != "$ARDPlistFlag4" ]; then
			echo "ARD flag $ARDPlistFlag4, is outdated. Updating flag to: $SetARDFlag4."
			$Binary -configure -computerinfo -set4 -4 "$SetARDFlag4"
		  fi
		fi
	}
#
################### Script ###################
#
SetARDComputerInfoField
SetARDComputerInfoField2
SetARDComputerInfoField3
SetARDComputerInfoField4
