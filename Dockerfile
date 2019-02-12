FROM ubuntu:18.04

#generic apache2/php7.3 LAMP platform
MAINTAINER Tomsoft IT <info@tomsoft-it.sk>

ENV TZ=Europe/Bratislava
ENV LANG en_US.utf8

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y locales software-properties-common && rm -rf /var/lib/apt/lists/* \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Install apache, PHP, and supplimentary programs
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ondrej/php && add-apt-repository ppa:ondrej/apache2 && apt-get -y install \
php7.3 php-cli php-mysql php7.3-gd php7.3-readline php7.3-apcu php7.3-curl php7.3-intl php7.3-common php7.3-json \
php7.3-gettext php7.3-memcached php7.3-memcache php7.3-zip php7.3-mbstring curl

# Enable apache mods.
RUN a2enmod php7.3 && a2enmod rewrite && a2enmod headers

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.3/apache2/php.ini

# default timezone for php
RUN echo "date.timezone='Europe/Bratislava'" >> /etc/php/7.3/apache2/php.ini && \
echo "date.timezone='Europe/Bratislava'" >> /etc/php/7.3/cli/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.3/apache2/php.ini && \
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/apache2/php.ini && \
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 200M/" /etc/php/7.3/apache2/php.ini && \
sed -i "s/post_max_size = .*/post_max_size = 200M/" /etc/php/7.3/apache2/php.ini && \
echo opcache.enable=1 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.enable_cli=1 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.interned_strings_buffer=8 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.max_accelerated_files=10000 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.memory_consumption=128 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.save_comments=1 >> /etc/php/7.3/apache2/php.ini && \
echo opcache.revalidate_freq=1 >> /etc/php/7.3/apache2/php.ini

RUN phpenmod mbstring && apt-get clean

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND

# set this folder as working for composer,etc...
WORKDIR /var/www/web
