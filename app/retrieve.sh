#!/bin/bash
server_status=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "animepahe.com")
var=$1

if ! ps ax | grep -v grep | grep transmission-daemon > /dev/null; then
	runuser -l root -c 'transmission-daemon'; sleep 2
else
	PROCESS_DT=$(ps -C transmission-daemon -o ruser=)
	if [[ $PROCESS_DT == "debian-transmission" ]]; then
		echo "transmission-daemon not running as root - restarting"
		killall transmission-daemon
		runuser -l root -c 'transmission-daemon'; sleep 2
	fi		
fi
if [ $server_status == 301 ]; then
	#if [[ $var=="keep" ]]; then
	#	echo "no delete"
	#else
	#	echo "delete"
		if [ -f '/var/www/downloading.txt' ]; then
			rm '/var/www/downloading.txt'
		fi
	#fi
	sudo node /root/app/app.js; sleep 1
else
	echo "Connection failed:" $server_status
fi
