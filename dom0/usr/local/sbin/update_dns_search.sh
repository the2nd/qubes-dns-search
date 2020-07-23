#!/bin/bash
QREXEC_REMOTE_DOMAIN="sys-net"
#CHECK_VMS="$QREXEC_REMOTE_DOMAIN"
CHECK_VMS="personal office"
VM_UPDATE_SCRIPT="/usr/sbin/update_dns_search.sh"
DNS_SEARCH="$(qubesdb-read -d "$QREXEC_REMOTE_DOMAIN" "/qubes-netvm-dns-search")"

get_net_vm () {
	local VM="$1"
	local X_VM="$VM"
	local Y_VM="$VM"
	while true ; do
		X_VM="$(qvm-ls --raw-data --fields name,netvm "$Y_VM" 2> /dev/null | cut -d '|' -f 2)"
		if [ "$X_VM" = "-" ] ; then
			echo "$Y_VM"
			break
		fi
		Y_VM="$X_VM"
	done
}

vm_is_running () {
	qvm-check --running "$1" > /dev/null 2>&1
}

MODIFY_VMS=""
for VM in $CHECK_VMS ; do
	NET_VM="$(get_net_vm "$VM")"
	if [ "$NET_VM" != "$QREXEC_REMOTE_DOMAIN" ] ; then
		continue
	fi
	MODIFY_VMS="$MODIFY_VMS $VM"
done

for VM in $MODIFY_VMS ; do
	if ! vm_is_running "$VM" ; then
		continue
	fi
	echo "Updating DNS search for VM $VM..."
	qubesdb-write -d "$VM" "/qubes-dns-search" "$DNS_SEARCH"
	qvm-run "$VM" "sudo $VM_UPDATE_SCRIPT"
done
