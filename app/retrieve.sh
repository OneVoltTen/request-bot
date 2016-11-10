#!/bin/bash
. /root/app/config.sh
server_status=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "$GROUP.com")

# if transmission-daemon not running as root restart
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
# if destination server connects
if [ $server_status == 301 ]; then
	if [ -f "$LOG/torrent.log" ]; then
		rm "$LOG/torrent.log"
	fi
	sudo node /root/app/app.js; sleep 1
else
	echo "Connection failed:" $server_status
fi
