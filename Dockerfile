FROM php:7.2-fpm-alpine
MAINTAINER Thiago Menezes <thimico@gmail.com>

ENV PHP_XDEBUG_REMOTE_HOST ${PHP_XDEBUG_REMOTE_HOST:-"127.0.0.1"}
ENV PHP_XDEBUG_REMOTE_PORT ${PHP_XDEBUG_REMOTE_PORT:-9000}

RUN apk --update add wget \
  curl \
  git \
  grep \
  nginx \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  zlib-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  libjpeg-turbo-dev libpng-dev freetype-dev \
  libpng-dev \
  autoconf curl g++ gcc imagemagick-dev libtool make tar \
  supervisor

RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install mysqli gd mbstring pdo pdo_mysql tokenizer xml 
RUN pecl channel-update pecl.php.net && pecl install memcached && docker-php-ext-enable memcached
RUN pecl install xdebug && docker-php-ext-enable xdebug 

RUN rm /var/cache/apk/* && \
    mkdir -p /var/www

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug-dev.ini
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]