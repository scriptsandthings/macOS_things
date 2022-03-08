#!/bin/zsh
#########################
#########################
# Script to set the system's time zone setting based on it's current approximate location, as determined by the system's current external IP address
#
# Set System Time Zone Based On Current Approximate Location From External IP.sh
# v1.0
# 3.7.2022
#
# Greg Knackstedt
# shitttyscripts@gmail.com
# https://github.com/gknackstedt/
#########################
#########################
#
# Find the system's current external IP address
myIP=$(curl -L -s --max-time 10 http://checkip.dyndns.org | egrep -o -m 1 '([[:digit:]]{1,3}.){3}[[:digit:]]{1,3}')
#
# Use the external IP address and bump it against ip-api.com to identify the time zone the system is most likely in
timeZone=$(curl -L -s --max-time 10 "http://ip-api.com/line/$myIP?fields=timezone")
#
# Set the time zone using the time zone previously defined using the IP address
sudo systemsetup -settimezone "$timeZone"
#
exit 0
