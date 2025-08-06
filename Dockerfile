# syntax=docker/dockerfile:1

ARG WP_IMAGE_VERSION=latest

FROM wordpress:$WP_IMAGE_VERSION AS base


FROM base AS dev

USER root

# Install development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Install XDebug from source as described here:
# https://xdebug.org/docs/install
# Available branches of XDebug could be seen here:
# https://github.com/xdebug/xdebug/branches
# Since this Dockerfile extends the official Docker image `wordpress`,
# and since `wordpress`, in turn, extends the official Docker image `php`,
# the helper script docker-php-ext-enable (defined for image `php`)
# works here, and we can use it to enable xdebug.
RUN set -eux; \
    cd /tmp; \
    git clone --depth 1 --branch xdebug_3_4 https://github.com/xdebug/xdebug.git; \
    cd xdebug; \
    phpize; \
    ./configure --enable-xdebug; \
    make; \
    make install; \
    rm -rf /tmp/xdebug; \
    docker-php-ext-enable xdebug

COPY ./xdebug.ini /usr/local/etc/php/conf.d/