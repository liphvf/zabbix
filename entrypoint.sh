#!/bin/bash
set -e
/etc/init.d/nginx start &
/etc/init.d/php5-fpm start &
/etc/init.d/zabbix-agent start &
/etc/init.d/zabbix-server start &
exec "/bin/bash"
