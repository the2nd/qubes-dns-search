#!/bin/bash
CHECK_VMS="$QREXEC_REMOTE_DOMAIN"
VM_UPDATE_SCRIPT="/usr/sbin/update_dns_search.sh"
DNS_SEARCH="$(qubesdb-read -d "$QREXEC_REMOTE_DOMAIN" "/qubes-netvm-dns-search")"

get_slave_vms () {
	qvm-ls --raw-data name netvm | tr -d '{}[]*=>' | grep "|$1" | cut -d '|' -f 1 | tr '\n' ' '
}

vm_is_running () {
	qvm-check --running "$1" > /dev/null 2>&1
}

ALL_SLAVE_VMS=""
while true ; do
	SLAVE_VMS=""
	for VM in $CHECK_VMS ; do
		X_SLAVE_VMS="$(get_slave_vms $VM)"
		if [ "$X_SLAVE_VMS" = "" ] ; then
			continue
		fi
		SLAVE_VMS="$SLAVE_VMS $X_SLAVE_VMS"
	done
	CHECK_VMS="$SLAVE_VMS"
	if [ "$CHECK_VMS" = "" ] ; then
		break
	fi
	for VM in $SLAVE_VMS ; do
		if ! vm_is_running "$VM" ; then
			continue
		fi
		ALL_SLAVE_VMS="$ALL_SLAVE_VMS $VM"
	done
done

for VM in $ALL_SLAVE_VMS ; do
	echo "Updating DNS search for VM $VM..."
	qubesdb-write -d "$VM" "/qubes-dns-search" "$DNS_SEARCH"
	qvm-run "$VM" "sudo $VM_UPDATE_SCRIPT"
done
