#!/bin/zsh
#
######################################################################################## 
# VMware - VMware Horizon Client - Uninstall.sh
# Version 1.0
# Greg Knackstedt
# 8.31.2021
# https://github.com/gknackstedt/macos_things
# shitttyscripts@gmail.com
######################################################################################## 
############################# About This Script ########################################
######################################################################################## 
#
# Stops VMware Horizon related services and force closes the application
# Removes all User (currently logged in user only) and system level preferences 
# and Application Support files for VMware Horizon Client
# Deletes the VMware Horizon Client.app from /Applications
#
######################################################################################## 
############################# Variables ################################################
######################################################################################## 
#
# Find currently logged in user
CurrentUser=$(who | awk '/console/{print $1}')
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
		sleep 2
	}
#
# Stop Horizon Client services
function StopVMwareHorizonServices
	{
		echo "Running services.sh --stop to stop background services..."
		sh /Applications/VMware\ Horizon\ Client.app/Contents/Library/services.sh --stop
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
######################################################################################## 
############################# Script ################################################### 
######################################################################################## 
# Functions defined above are called to execute in order
#
echo "##############################################"
echo "############## Uninstalling ##################"
echo "######### VMware Horizon Client ##############"
echo "##############################################"
KillVMwareHorizon
StopVMwareHorizonServices
KillVMwareHorizonUSBArb
DeleteLibraryLaunchDaemon
DeleteLibraryAppSupport
DeleteLibraryPreferences
DeleteUserLibraryAppSupport
DeleteUserLibraryPreferences
DeleteHorizonClient
echo "##############################################"
echo "######### VMware Horizon Client ##############"
echo "######## Uninstallation Complete! ############"
echo "##############################################"
exit 0
