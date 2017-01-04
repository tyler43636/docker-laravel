FROM ubuntu:16.04

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN locale-gen en_US.UTF-8 \
	&& export LANG=en_US.UTF-8 \
	&& apt-get update \
	&& apt-get install -y software-properties-common curl apt-transport-https \
	&& LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php \
	&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& curl -O https://deb.nodesource.com/setup_7.x \
	&& bash setup_7.x \
	&& apt-get -y install \
		nodejs \
		yarn \
		apache2 \
		vim \
		git-core \
		build-essential \
		php7.1 \
		php7.1-cli \
		php7.1-mbstring \
		php7.1-mysql \
		php7.1-gd \
		php7.1-json \
		php7.1-curl \
		php7.1-sqlite3 \
		php7.1-intl \
		php7.1-xml \
		php7.1-zip \
	&& php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& php -r "unlink('composer-setup.php');" \
	&& a2enmod headers \
	&& a2enmod rewrite

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
ln -sf /dev/stderr /var/log/apache2/error.log

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

RUN sed -i ':a;N;$!ba;s/AllowOverride None/AllowOverride All/3' /etc/apache2/apache2.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/' /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

USER www-data

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
