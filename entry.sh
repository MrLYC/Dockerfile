#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

if [ ! -r /data/snmpd.conf ]; then
    cat /etc/snmp/snmpd.conf | sed \
        -e "s/agentAddress  udp:127.0.0.1:161/agentAddress  ${AGENT_ADDRESS}/g" \
        -e "s/rocommunity public  default    -V systemonly/rocommunity ${COMMUNITY}  default    -V systemonly/g" \
        ${CONFIG_SED_COMMAND} /etc/snmp/snmpd.conf | tee /data/snmpd.conf
fi

snmpd -Ls${LOG_LEVEL}d -Lf "${LOG_FILE}" -C -c /data/snmpd.conf "$@"
tail -f "${LOG_FILE}"