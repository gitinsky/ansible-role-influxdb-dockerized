#!/bin/bash

chown -R influxdb:influxdb /var/opt/influxdb

# Dynamically change the value of 'max-open-shards' to what 'ulimit -n' returns
sed -i "s/^max-open-shards.*/max-open-shards = $(ulimit -n)/" /config/config.toml

if [ "${PRE_CREATE_DB}" == "**None**" ]; then
    unset PRE_CREATE_DB
fi

if [ "${SSL_CERT}" == "**None**" ]; then
    unset SSL_CERT
fi

if [ "${SSL_SUPPORT}" == "**False**" ]; then
    unset SSL_SUPPORT
fi

# Pre create database on the initiation of the container
API_URL="http://localhost:8086"
if [ -n "${PRE_CREATE_DB}" ]; then
    echo "=> About to create the following database: ${PRE_CREATE_DB}"
    if [ -f "/data/.pre_db_created" ]; then
        echo "=> Database had been created before, skipping ..."
    else
        echo "=> Starting InfluxDB ..."
        exec /opt/influxdb/influxd -config=/config/config.toml &
        PASS=${INFLUXDB_INIT_PWD:-root}
        arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

        #wait for the startup of influxdb
        RET=1
        while [[ RET -ne 0 ]]; do
            echo "=> Waiting for confirmation of InfluxDB service startup ..."
            sleep 3 
            curl -k ${API_URL}/ping 2> /dev/null
            RET=$?
        done
        echo ""

        for x in $arr
        do
            echo "=> Creating database: ${x}"
            /opt/influxdb/influx -host=localhost -port=8086 -username=root -password="${PASS}" -execute="create database \"${x}\""
        done
        echo ""

        touch "/data/.pre_db_created"
        fg
        exit 0
    fi
else
    echo "=> No database need to be pre-created"
fi

echo "=> Starting InfluxDB ..."

exec /opt/influxdb/influxd -config=/config/config.toml
