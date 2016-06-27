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


WORKDIR /var/www

EXPOSE 9000

RUN php-fpm

