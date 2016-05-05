FROM ubuntu:latest 
MAINTAINER Anton Belov anton4@bk.ru

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get clean && \
	apt-get -y install \
	pwgen python-setuptools \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
	LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php5-5.6 && \
	apt-get update -y && \
	apt-get -y install  \
	php5-fpm php5-mysql php-apc \
	ssmtp ca-certificates curl php5-curl php5-gd php5-intl php-pear php5-imagick \
	php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-cli php5-dev \ 
	php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xdebug wget pkg-config &&\
        apt-get clean && \
        rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /download/directory

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get clean && \
	apt-get -y install \	
	wget python python-pip python-dev libfreetype6 libfontconfig1 \
	build-essential zlib1g-dev libpcre3 libpcre3-dev unzip &&\
	apt-get clean && \
	rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /download/directory

#ioncube
WORKDIR /tmp
RUN	wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
	tar xvfz ioncube_loaders_lin_x86-64.tar.gz &&\
	rm ioncube_loaders_lin_x86-64.tar.gz &&\
	echo ioncube/ioncube_loader_lin_${PHP_VERSION}.so `php-config --extension-dir` &&\
	PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") && \
	cp ioncube/ioncube_loader_lin_${PHP_VERSION}.so `php-config --extension-dir` && rm -rf ioncube && \
	echo zend_extension=`php-config --extension-dir`/ioncube_loader_lin_${PHP_VERSION}.so >> /etc/php5/fpm/php.ini 	

#install newrelic
RUN apt-key adv --fetch-keys http://download.newrelic.com/548C16BF.gpg && \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list && \
    apt-get -y update && \
    apt-get -y install newrelic-php5 && \
    rm -rf /var/lib/apt/lists/*


# mcrypt enable Enabling session files
RUN ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini &&\
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini &&\
    mkdir -p /tmp/sessions/ &&\
    chown www-data.www-data /tmp/sessions -Rf &&\
    sed -i -e "s:;\s*session.save_path\s*=\s*\"N;/path\":session.save_path = /tmp/sessions:g" /etc/php5/fpm/php.ini

RUN wget https://github.com/alanxz/rabbitmq-c/archive/v0.7.0.tar.gz &&\
	 tar -xzvf v0.7.0.tar.gz &&\
	 cd rabbitmq-c-0.7.0/ &&\ 
	 autoreconf -i && ./configure && make && make install                 
RUN pecl install amqp-1.6.0beta3.tgz 
RUN pecl install oauth

ADD /php5 /etc/php5

WORKDIR /var/www

EXPOSE 9000

CMD ["php5-fpm", "-F", "-O"]
