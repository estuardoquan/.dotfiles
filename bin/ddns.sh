#!/bin/bash

IP_ADDR=$(hostname -I)
HOST=$(hostname)
NSUPDATE_SERVER=bind9.pi.local
NSUPDATE_KEY=~/.ddns/acme-update.key

printf "%s\n" \
    "server ${NSUPDATE_SERVER}" \
    "update delete ${HOST} A" \
    "update add ${HOST} 20 A ${IP_ADDR}" \
    "show" \
    "send"
