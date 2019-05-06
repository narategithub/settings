#!/bin/bash

# Expecting DDNS_USERNAME
#           DDNS_PASSWORD
#           DDNS_HOST
# in the CFG_FILE

CFG_FILE=$PWD/.ddns.env

log() {
	logger "ddns_update.sh -" $@
}

expect() {
	VAR=$1
	if test -z "${!VAR}"; then
		log "Variable $VAR is not defined."
		exit -1
	fi
}

if ! test -f $CFG_FILE; then
	log "$CFG_FILE not found."
	exit -1
fi

source $CFG_FILE

expect DDNS_USERNAME
expect DDNS_PASSWORD
expect DDNS_HOSTNAME
expect DDNS_FROM
expect DDNS_TO

DIG=$(dig -4 +short narate.taerat.net @8.8.8.8)
MY_ADDR=$(wget -4 -q -O - https://domains.google.com/checkip)

if test "$DIG" = "$MY_ADDR"; then
	# no need to update.
	log "same addr."
	exit 0
fi

URL="https://${DDNS_USERNAME}:${DDNS_PASSWORD}@domains.google.com/nic/update"
DATA="hostname=$DDNS_HOSTNAME&myip=$MY_ADDR"

UPDATE=$(wget -4 -q -O - --post-data="$DATA" $URL)
log "ddns update: " $UPDATE

sendmail -t <<EOM
From: $DDNS_FROM
To: $DDNS_TO
Subject: IP address changed.

IP address has been changed:

previous: $DIG
current: $MY_ADDR

update output: $UPDATE

Cheers,
Z
EOM
