FROM ubuntu:latest 
MAINTAINER Anton Belov anton4@bk.ru

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
# Use source.list with all repositories and Yandex mirrors.


RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get clean && \
	apt-get -y install \
	pwgen python-setuptools software-properties-common && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
	LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
	apt-get update -y && \
	apt-get -y install  \
	ssmtp ca-certificates curl php7.0 php7.0-fpm php-apcu-bc php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php-pear php7.0-imagick \
	php7.0-imap php7.0-zip php7.0-mbstring php7.0-mcrypt php7.0-memcache \
 	php7.0-ps php7.0-pspell php7.0-cli php7.0-dev \ 
	php7.0-recode php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-xdebug wget pkg-config &&\
        apt-get clean && \
        rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /download/directory

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get clean && \
	apt-get -y install \	
	wget python python-pip python-dev libfreetype6 libfontconfig1 \
	build-essential zlib1g-dev libpcre3 libpcre3-dev unzip &&\
	apt-get clean && \
	rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /download/directory

WORKDIR /tmp

#install newrelic
RUN apt-key adv --fetch-keys http://download.newrelic.com/548C16BF.gpg && \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list && \
    apt-get -y update && \
    apt-get -y install newrelic-php5 && \
    rm -rf /var/lib/apt/lists/*



RUN wget https://github.com/alanxz/rabbitmq-c/archive/v0.7.0.tar.gz &&\
	 tar -xzvf v0.7.0.tar.gz &&\
	 cd rabbitmq-c-0.7.0/ &&\ 
	 autoreconf -i && ./configure && make && make install                 
RUN pecl install amqp-1.6.0beta3.tgz 
RUN pecl install oauth
RUN mkdir /run/php/ && chmod 777 /run/php/

RUN sed -i '/daemonize /c \
daemonize = no' /etc/php/7.0/fpm/php-fpm.conf

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/7.0/fpm/pool.d/www.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/7.0/fpm/pool.d/www.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/7.0/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/7.0/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/7.0/fpm/pool.d/www.conf && \
echo "date.timezone = \"Europe/London\"" >> /etc/php/7.0/fpm/php.ini

# fix ownership of sock file for php-fpm
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.0/fpm/pool.d/www.conf && \
find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;


RUN sed -i '/^listen /c \
listen = 9000' /etc/php/7.0/fpm/pool.d/www.conf

RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php/7.0/fpm/pool.d/www.conf

#installing cron
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive \
	apt-get -y install  \
	rsyslog &&\
	touch /etc/crontab &&\
        apt-get clean && \
        rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /download/directory
        
EXPOSE 9000


VOLUME ["/etc/php-fpm.d", "/var/log/php-fpm", "/var/www"]

CMD ["php-fpm7.0"]
