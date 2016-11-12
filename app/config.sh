#!/bin/bash

INSTALL="/root"
WWW="/run/media/onevoltten/bot"
SORT="$WWW/sort"
DOWNLOAD="$WWW/downloads"
KOMARU="$WWW/komaru"
QUEUE="$WWW/queue"
VERIFY="$WWW/verify"
UPLOAD="$WWW/upload"
UPLOADED="$INSTALL/uploaded"

# log message
ERW="execute retieve worker..."
QCF="queue contain files..."
ER="execute rename..."
FR="ffmpeg running..."
PR="php running..."
EE="execute encode..."
FR="ffmpeg running..."
SY="sabishī yo..."

TRASH="$WWW/trash"
LOG="$INSTALL/log"
GROUP="AnimePahe"

lastlog=`tail -1 "${LOG}/main.log" | head -1`

die() { echo "$@" 1>&2 ; exit 1; }

#arrayr=("ffmpeg" "transmission-daemon" "php" "node" "mkvmerge")
#for i in "${arrayr[@]}"; do
#    $i -v foo >/dev/null 2>&1 || {
#        die "$i komaru!";
#    }
#done

cd ${INSTALL}