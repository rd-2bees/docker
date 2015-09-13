FROM 2beesadmin/ubuntu
MAINTAINER admin <admin@2bees.com>
RUN apt-get update && apt-get install apache2 apache2-mpm-prefork fontconfig-config \
	fonts-dejavu-core libaio1 libapache2-mod-php5 libgd3 curl php5-sqlite \
	libdbi-perl libedit2 libfontconfig1 libfreetype6 libjpeg8 bzip2 \
	libhtml-template-perl libjbig0 libjpeg-turbo8 php5-json php5-readline \
	libterm-readkey-perl libtiff5 libvpx1 libxdmcp6 php5-cli php5-gd \
	libwrap0 libx11-6 libx11-data libxau6 libxcb1 lsof php5-common \
	ssl-cert -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN curl -k https://download.owncloud.org/community/owncloud-8.0.0.tar.bz2 | tar xj -C /var/www/ && \
	mkdir -p /var/www/owncloud/data/tmp && \
	chmod 770 /var/www/owncloud/data && \
	chown -R 33:33 /var/www
	
RUN make-ssl-cert generate-default-snakeoil --force-overwrite && \
	echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
	a2ensite default-ssl && \
	a2enmod ssl rewrite && \
	a2enconf servername

RUN sed -i -e 's/ErrorLog/#ErrorLog/' -e 's/CustomLog/#CustomLog/' -e '6i\\t\t\ErrorLog /dev/fd/1' -e '6i\\t\t\CustomLog /dev/fd/1 custom' \
	-e 's/www\/html/www\/owncloud/' /etc/apache2/sites-available/default-ssl.conf && \
	sed -i '6s/#//' /etc/apache2/conf-available/charset.conf && \
	sed -i '211iLogFormat "%t %h %>s %{Referer}i -> %U \\"%{User-Agent}i\\"" custom' /etc/apache2/apache2.conf

ADD 000-default.conf /etc/apache2/sites-available/
ADD php.ini /etc/php5/apache2/
VOLUME /var/www/owncloud/data
EXPOSE 80 443
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
