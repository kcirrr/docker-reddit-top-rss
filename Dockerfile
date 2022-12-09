FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update \
    && apt-get install -qq -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && c_rehash

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /var/www/html/ \
    && curl -SL https://github.com/johnwarne/reddit-top-rss/archive/master.tar.gz \
    | tar -xzC /var/www/html/ --strip-components=1


FROM php:8.2.0-apache

ENV USER reddittoprss
ENV UID 1000
ENV GID 1000

ENV APACHE_RUN_USER "${USER}"
ENV RUN_APACHE_GROUP "${USER}"

WORKDIR /var/www/html/

RUN apt-get update \
    && apt-get upgrade -y \
    && groupadd -r "${USER}" --gid="${GID}" \
    && useradd --no-log-init -r -g "${GID}" --uid="${UID}" "${USER}" \
    && sed -s -i -e "s/80/8080/" /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf \
    && rm -rf /var/lib/apt/lists/*

COPY --chown="${USER}" --from=builder /var/www/html/ .

USER "${UID}"

EXPOSE 8080
