#!/bin/bash
. /root/config.sh
server_status=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "animepahe.com")

if ! ps ax | grep -v grep | grep transmission-daemon > /dev/null; then
	runuser -l root -c 'transmission-daemon'; sleep 2
else
	PROCESS_DT=$(ps -C transmission-daemon -o ruser=)
	if [[ $PROCESS_DT == "debian-transmission" ]]; then
		echo "restarting transmission-daemon as root"
		killall transmission-daemon
		runuser -l root -c 'transmission-daemon'; sleep 2
	fi		
fi
if [ $server_status == 301 ]; then
	if [[ $1 = "keep" ]]; then
		echo "keep"
	else
		echo "delete"
		if [ -f "${WWW}/downloading.txt" ]; then
			rm "${WWW}/downloading.txt"
		fi
	fi
	sudo node /root/app/app.js; sleep 1
else
	echo "Connection failed:" $server_status
fi
