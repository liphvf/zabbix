#!/bin/bash
set -e
psql zabbix zabbix < schema.sql && \
psql zabbix zabbix < data.sql && \
psql zabbix zabbix < images.sql
# exec "/bin/bash"
