FROM debian:buster-slim AS builder

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

FROM php:7.4-apache
COPY --chown=nobody --from=builder /var/www/html/ .
