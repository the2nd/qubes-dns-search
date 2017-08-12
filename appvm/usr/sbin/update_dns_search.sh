#!/bin/bash

RESOLV_CONF="/etc/resolv.conf"
DNS_SEARCH="$(qubesdb-read /qubes-dns-search)"

RESOLV_CONFIG="$(cat "$RESOLV_CONF" | grep -v "^search ")"
echo "$RESOLV_CONFIG" > "$RESOLV_CONF"
if [ "$DNS_SEARCH" != "" ] ; then
	echo "search $DNS_SEARCH" >> "$RESOLV_CONF"
fi
