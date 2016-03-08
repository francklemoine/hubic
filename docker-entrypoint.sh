#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="${BASH_SOURCE[0]##*/}"
__bas0="${__base%.sh}"


HUBIC_MAILFILE="/root/.hubicmail"
HUBIC_PASSFILE="/root/.hubicpass"
HUBIC_DATAS="/hubiC"
HUBIC_INIT="/usr/local/bin/hubic-init.sh"
DBUS_LAUNCH_INIT="/usr/local/bin/dbus-launch.sh"
DBUS_LAUNCH_ENV="/usr/local/bin/dbus-launch-env.sh"


function check_args() {
	if [[ -z "${EMAIL}" ]]; then
		if is_file ${HUBIC_MAILFILE}; then
			EMAIL=$(<${HUBIC_MAILFILE})
		else
			echo "hubic: undefined login email address"
			exit 1
		fi
	else
		echo "${EMAIL}" >${HUBIC_MAILFILE}
		chmod 400 ${HUBIC_MAILFILE}
	fi

	if [[ -z "${PASSWORD}" ]]; then
		is_file ${HUBIC_PASSFILE} || ( echo "hubic: undefined password"; exit 1; )
	else
		echo "${PASSWORD}" >${HUBIC_PASSFILE}
		chmod 400 ${HUBIC_PASSFILE}
		unset ${PASSWORD}
	fi
}



function hubic_init() {
	/etc/init.d/dbus start
	eval $(dbus-launch --sh-syntax)
	hubic login --password_path=${HUBIC_PASSFILE} ${EMAIL} ${HUBIC_DATAS}
}



function is_file() {
	local f="$1"
	[[ -f "$f" ]] && return 0 || return 1
}



function message_bus_init() {
	[[ -f "${DBUS_LAUNCH_INIT}" ]] && return 0

	cat <<-EOF > ${DBUS_LAUNCH_INIT}
	#!/bin/bash
	dbus-launch --sh-syntax | tee ${DBUS_LAUNCH_ENV}
	chmod +x ${DBUS_LAUNCH_ENV}
	EOF

	chmod +x ${DBUS_LAUNCH_INIT}
}



function hubic_login_init() {
	[[ -f "${HUBIC_INIT}" ]] && rm -f ${HUBIC_INIT}

	cat <<-EOF > ${HUBIC_INIT}
	#!/bin/bash
	sleep 5
	. ${DBUS_LAUNCH_ENV}
	hubic login --password_path=${HUBIC_PASSFILE} ${EMAIL} ${HUBIC_DATAS}
	EOF

	chmod +x ${HUBIC_INIT}
}



check_args

#hubic_init

message_bus_init
hubic_login_init
export DBUS_LAUNCH_INIT
export HUBIC_INIT
supervisord -c /etc/supervisor/supervisord.conf

