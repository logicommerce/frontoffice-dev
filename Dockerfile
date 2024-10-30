FROM php:8.2-apache

# Set php.ini configuration
COPY ./php.ini /usr/local/etc/php/php.ini

# Modify policy-rc to allow services management (start/stop) correctly
RUN sed -i 's/exit 101/exit 0/g' /usr/sbin/policy-rc.d

# Update APT
RUN apt-get -y update --fix-missing
RUN apt-get upgrade -y

# Install useful tools
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -y install --fix-missing apt-utils build-essential curl libcurl4 zip openssl \
	wget dialog jq procps git redis awscli zlib1g-dev libzip-dev libicu-dev libonig-dev \
	libfreetype6-dev libjpeg62-turbo-dev libpng-dev

# Install PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP Extensions
RUN pecl install xdebug-3.2.0
RUN docker-php-ext-enable xdebug
RUN docker-php-ext-install zip
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install gettext
RUN docker-php-ext-install pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

# Enable apache and modules
RUN update-rc.d apache2 enable
RUN a2enmod rewrite headers

# Prepare Apache commerce configuration
COPY ./commerce.conf /etc/apache2/sites-available/commerce.conf
RUN a2ensite commerce.conf

# Remove default Apache configuration
RUN rm /etc/apache2/sites-enabled/000-default.conf

# Create and set /local folders as the default folder
RUN mkdir /local
RUN mkdir /local/logs
RUN mkdir /local/cache
RUN chown -R www-data:www-data /local/logs
RUN chown -R www-data:www-data /local/cache
WORKDIR /local

# Copy entrypoint script
COPY entrypoint.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
