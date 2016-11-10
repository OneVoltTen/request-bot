#!/bin/bash

INSTALL="/root"
WWW="/media/yubikiri/bot"
SORT="$WWW/sort"
DOWNLOAD="$WWW/downloads"
KOMARU="$WWW/komaru"
QUEUE="$WWW/queue"
VERIFY="$WWW/verify"
UPLOAD="$WWW/upload"
UPLOADED="$INSTALL/uploaded"

TRASH="$WWW/trash"
LOG="$INSTALL/log"
GROUP="AnimePahe"

lastlog=`tail -1 "${LOG}/main.log" | head -1`

die() { echo "$@" 1>&2 ; exit 1; }
cd ${INSTALL}