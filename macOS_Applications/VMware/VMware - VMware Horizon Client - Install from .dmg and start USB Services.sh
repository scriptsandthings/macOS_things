#!/bin/zsh
#
######################################################################################## 
# VMware - VMware Horizon Client - Install from .dmg and start USB Services.sh
# Version 1.0
# Greg Knackstedt
# 8.31.2021
# https://github.com/gknackstedt/macos_things
# shitttyscripts@gmail.com
######################################################################################## 
############################# About This Script ########################################
######################################################################################## 
#
# Kills the VMware Horizon Client process (vmware-view) and related USB services.
# Removes VMware Horizon Application Support files from /Library/Application Support/ and 
# from /Users/$CurrentUser/Library/Application Support/.
# Mounts the VMware Horizon.dmg from a pre-stage located in /Users/Shared/
# Uses Jamf's $4 variable to define the name of the .dmg in the pre-stage package
# Calls the InitUsbServices.tool to rebuild Application Support files and set permissions
# Runs the services.sh script within the VMware Horizon Client.app bundle to start USB
# redirection services for the current user.
#
#
######################################################################################## 
############################# Variables ################################################
######################################################################################## 
#
# Find currently logged in user
CurrentUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
#
# .dmg name that will be placed in /Users/Shared via pre-stage package
InstallDMGName="$4"
#
######################################################################################## 
############################# Functions ################################################
######################################################################################## 
# Defines functions to be called by the script when it's ready for them
#
# Kill the process vmware-view if it's still running
function KillVMwareHorizon
	{
		echo "Closing the Horizon View Client by killing the vmware-view process..."
		killall "vmware-view"
		sleep 5
	}
#
# Stop Horizon Client services
function StopVMwareHorizonServices
	{
		echo "Running services.sh --stop to stop background services..."
		sh /Applications/VMware\ Horizon\ Client.app/Contents/Library/services.sh --stop
		sleep 5
	}
#
# Start Horizon Client services
function StartVMwareHorizonServices
	{
		echo "Running services.sh --start to start background services..."
		sh /Applications/VMware\ Horizon\ Client.app/Contents/Library/services.sh --start
		sleep 5
	}
#
# Call InitUsbServices.tool to set the rights of the USB kexts and support files so they may be loaded by unprivileged users
function CallInitUsbServicesTool
	{
		echo "Calling /Applications/VMware Horizon Client.app/Contents/Library/InitUsbServices.tool to set permissions..."
		/Applications/VMware\ Horizon\ Client.app/Contents/Library/InitUsbServices.tool
		sleep 5
	}
#
# Kill the process vmware-usbarbitrator if it's still running
function KillVMwareHorizonUSBArb
	{
		echo "Killing vmware-usbarbitrator service..."
		killall "vmware-usbarbitrator"
		sleep 5
	}
#
# Remove system level LaunchDaemons
function DeleteLibraryLaunchDaemon
	{
		echo "Deleting: /Library/LaunchDaemons/com.vmware.horizon.CDSHelper.plist"
		rm -Rf /Library/LaunchDaemons/com.vmware.horizon.CDSHelper.plist
		echo "Deleting: /Library/LaunchDaemons/com.vmware.CDSHelper.plist"
		rm -Rf /Library/LaunchDaemons/com.vmware.CDSHelper.plist
	}
# Remove system level Application Support files for Horizon Client
function DeleteLibraryAppSupport 
	{
		echo "Deleting /Library/Application Support/VMware/VMware Horizo*"
		rm -Rf /Library/Application\ Support/VMware/VMware\ Horizo*
	}
#
# Remove system level preference files for Horizon Client
function DeleteLibraryPreferences
	{
		echo "Deleting /Library/Preferences/com.vmware.horiz*"
		rm -Rf /Library/Preferences/com.vmware.horiz*
	}
#
# Remove user level Application Support files for Horizon Client for the currently logged in user
function DeleteUserLibraryAppSupport 
	{
		echo "Deleting /Users/$CurrentUser/Library/Application Support/VMware Horizo*"
		rm -Rf /Users/"$CurrentUser"/Library/Application\ Support/VMware\ Horizo*
	}
#
# Remove user level preference files for Horizon Client for the currently logged in user
function DeleteUserLibraryPreferences
	{
		echo "Deleting /Users/$CurrentUser/Library/Preferences/com.vmware.horiz*"
		rm -Rf /Users/"$CurrentUser"/Library/Preferences/com.vmware.horiz*
	}
#
# Delete the VMware Horizon Client.app
function DeleteHorizonClient
	{
		echo "Deleting VMware Horizon Client.app from /Applications"
		rm -Rf /Applications/VMware\ Horizon\ Client.app
	}
#
# Install Horizon Client.app from .dmg in /Users/Shared/ and filename defined with $4
function InstallVMwareHorizonClient
	{
		hdiutil attach /Users/Shared/"$InstallDMGName" -nobrowse
		sleep 10
		cp -Rf /Volumes/VMware\ Horizon\ Client/VMware\ Horizon\ Client.app /Applications/
		sleep 10
		hdiutil detach /Volumes/VMware\ Horizon\ Client
		sleep 5
		rm -Rf /Users/Shared/"$InstallDMGName"
	}
######################################################################################## 
############################# Script ################################################### 
######################################################################################## 
# Functions defined above are called to execute in order
#
echo "##############################################"
echo "############### Installing ###################"
echo "######### VMware Horizon Client ##############"
echo "##############################################"
KillVMwareHorizon
StopVMwareHorizonServices
KillVMwareHorizonUSBArb
DeleteLibraryAppSupport
DeleteUserLibraryAppSupport
InstallVMwareHorizonClient
CallInitUsbServicesTool
echo "##############################################"
echo "######### VMware Horizon Client ##############"
echo "######### Installation Complete! #############"
echo "##############################################"
exit 0
