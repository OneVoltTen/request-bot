#!/bin/bash

INSTALL="/root"
WWW="/media/yubikiri/bot"
SORT="$WWW/sort"
DOWNLOAD="$WWW/downloads"
KOMARU="$WWW/komaru"
QUEUE="$WWW/queue"
VERIFY="$WWW/verify"
ENCODED="$WWW/encoded"
UPLOADED="$WWW/uploaded"

TRASH="$WWW/trash"
LOG="$WWW/logs"
GROUP="AnimePahe"

die() { echo "$@" 1>&2 ; exit 1; }
cd ${INSTALL}