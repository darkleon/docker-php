FROM centos:latest
MAINTAINER http://www.kt-team.de

RUN yum -y update && \
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
	rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
	rpm -Uvh https://yum.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm && \
	yum clean all

RUN yum -y install freetds && \
	yum  --enablerepo=remi-php70 -y install \
	php-cli \
	php-fpm \
	php-opcache \
	php-pecl-apcu \
	php-pecl-apcu-bc \
	php-pecl-memcache \
	php-pecl-memcached \
	php-pecl-redis \
	php-gd \
	php-pecl-imagick \
	php-intl \
	php-mcrypt \
	php-mbstring \
	php-xml \
	php-json \
	php-soap \
	php-mysqlnd \
	php-pdo-dblib \
	php-pecl-zip \
	php-process \
	php-pecl-xdebug && \
	yum -y install ssmtp cronie newrelic-php5 && \
	yum clean all && mkdir -p /var/www

RUN	cd /tmp && \
	curl http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube_loaders_lin_x86-64.tar.gz && \
	tar xvfz ioncube_loaders_lin_x86-64.tar.gz &&\
	rm ioncube_loaders_lin_x86-64.tar.gz &&\
	PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") && \
	PHP_EXT_PATH=$(php -i | grep extension_dir | grep usr | cut -d' ' -f 3) && \
	echo ioncube/ioncube_loader_lin_${PHP_VERSION}.so $PHP_EXT_PATH &&\
	cp ioncube/ioncube_loader_lin_${PHP_VERSION}.so $PHP_EXT_PATH && rm -rf ioncube && \
	echo zend_extension=ioncube_loader_lin_${PHP_VERSION}.so >> /etc/php.d/10-ioncube.ini && \
	rm -rf /tmp/ioncube

RUN groupadd --gid 33 www-data && useradd --uid 33 --gid 33 www-data

WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm", "-F"]


