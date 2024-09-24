FROM php:8.1-fpm-bookworm

WORKDIR /var/www
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="/var/www/vendor/bin:$PATH"

RUN --mount=type=bind,source=fs,target=/mnt apt update && \
    apt install -y \
        nginx \
        supervisor \
        wget \
        nano \
        libgmpxx4ldbl \
        libgmp-dev \
        libwebp-dev \
        libxpm-dev \
        libavif-dev \
        libicu-dev \
        libxml2 \
        libxml2-dev \
        libzip4 \
        libzip-dev \
        libfreetype6 \
        libfreetype6-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
        libpng-tools \
        libpng16-16 \
        libpng-dev \
        libbz2-dev \
        bzip2 \
        libmemcached-dev \
        zlib1g-dev \
        libssl-dev \
        libssh2-1 \
        libssh2-1-dev && \
    pecl install inotify && \
    pecl install redis-6.0.2 && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure gd --with-jpeg --with-webp --with-xpm --with-avif --with-freetype && \
    docker-php-ext-enable redis && \
    docker-php-ext-install \
        opcache \
        mysqli \
        pdo \
        pdo_mysql \
        sockets \
        intl \
        gd \
        exif \
        xml \
        bz2 \
        pcntl \
        zip \
        soap \
        gmp \
        bcmath && \
    apt remove -y \
        libgmp-dev \
        libxml2-dev \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev && \
    pecl install memcached-3.2.0 && \
    pecl install -a ssh2 && \
    docker-php-ext-enable \
        memcached \
        exif \
        redis \
        ssh2 \
        inotify && \
    apt remove -y \
        libgmp-dev \
        libxml2-dev \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libmemcached-dev \
        libbz2-dev \
        libssl-dev \
        libbz2-dev \
        libssh2-1-dev && \
    curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer && \
    mkdir -p /run/php /run/nginx && \
    rm -f /var/log/nginx/access.log /var/log/nginx/error.log && \
    ln -s /dev/stdout /var/log/nginx/access.log && \
    ln -s /dev/stderr /var/log/nginx/error.log && \
    wget -O /tmp/tasker.tar.gz https://github.com/adhocore/gronx/releases/download/v1.8.0/tasker_1.8.0_linux_amd64.tar.gz && \
    tar xvzfC /tmp/tasker.tar.gz /tmp/ && \
    mv /tmp/tasker_1.8.0_linux_amd64/bin/tasker /usr/local/bin/tasker && \
    rm -fr /tmp/tasker.tar.gz /tmp/tasker_1.8.0_linux_amd64 && \
    wget -O /tmp/ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xvzfC /tmp/ioncube.tar.gz /tmp/ && \
    rm -f /tmp/ioncube.tar.gz && \
    php_ext_dir="$(php -i | grep extension_dir | head -n1 | awk '{print $3}')" && \
    mv /tmp/ioncube/ioncube_loader_lin_8.1.so "${php_ext_dir}/" && \
    echo "zend_extension = ioncube_loader_lin_8.1.so" > /usr/local/etc/php/conf.d/00-ioncube.ini && \
    rm -rf /tmp/ioncube && \
    cp -Rv /mnt/* / && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/supervisord"]
