# Nginx, Aplicação Zabbix-server 3.0.1
# Script docker desenvolvido por David Bezerra
# Data: 20-03-2016

FROM debian:jessie

ADD zabbix/ /usr/src/zabbix

# add webupd8 repository
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo "deb http://ftp.de.debian.org/debian jessie main non-free" | tee /etc/apt/sources.list.d/debian-no-free.list && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default \
	make flex gcc gpp libpq5 libpq-dev snmp automake snmpd libiksemel-dev libcurl4-gnutls-dev libssh2-1-dev libssh2-1 libopenipmi-dev libsnmp-dev curl fping \
	sudo libcurl3-gnutls libxml2-dev  php5 php5-pgsql php5-ldap php5-fpm php-apc php5-curl php5-xmlrpc php5-gd php-net-socket nano nginx pkg-config libldap2-dev snmp-mibs-downloader traceroute && \
    \
	\
    echo "===> clean up..."  && \
	rm -rf /var/cache/oracle-jdk8-installer && \
	apt-get clean  && \
    rm -rf /var/lib/apt/lists/*


RUN rm -v /etc/nginx/sites-available/default
ADD default /etc/nginx/sites-available/

WORKDIR /usr/src/zabbix
RUN chmod +x configure

# Compilando o zabbix
RUN ./configure --enable-server --enable-agent --enable-java --with-postgresql --with-net-snmp --with-libcurl --with-ssh2 \
--with-openipmi --with-libxml2 --with-openssl --with-jabber --with-ldap --with-iconv
RUN make && make install

RUN useradd -s /bin/false zabbix && \
    cp misc/init.d/debian/zabbix-* /etc/init.d/ && \
    chmod +x /etc/init.d/zabbix-*

#INSTALAR E CONFIGURAR A INTERFACE WEB

RUN mkdir /var/www/html/zabbix && \
    cp -r frontends/php/* /var/www/html/zabbix/ && \
    chown -R www-data:www-data /var/www/html/zabbix


RUN cp /usr/bin/fping /usr/sbin && chown root:zabbix /usr/sbin/fping
RUN rm /usr/local/etc/zabbix_server.conf
ADD zabbix_server.conf /usr/local/etc/


RUN rm /etc/php5/fpm/php.ini
ADD php.ini /etc/php5/fpm/

# Setup Volume
VOLUME ["/var/www/html/zabbix"]

ADD ./entrypoint.sh /
# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/entrypoint.sh"]
