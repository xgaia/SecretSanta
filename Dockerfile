FROM jmilette/apache-phpfpm:php-8.0

ENV DEBIAN_FRONTEND=noninteractive

ENV SERVERNAME=localhost
# ENV APP_ENV=prod
ENV APP_SECRET=secret
ENV APP_SALT=secret
ENV HOST=localhost
ENV TRUSTED_PROXIES=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
ENV TRUSTED_HOSTS='^(localhost|example\.com)$'

ENV DATABASE_URL="mysql://secretsanta:secretsanta@localhost/secretsanta?serverVersion=5.7&charset=utf8mb4"
ENV MAILER_DSN=smtp://localhost:25
ENV MANDRILL_DSN=smtp://localhost
ENV NOREPLY_EMAIL=noreply@example.org
ENV CONTACT_EMAIL=info@example.org
ENV MAIL_FROM_ADDRESS=noreply@example.org
ENV MAIL_FROM_NAME="noreply@example.org"
ENV GEO_IP_DB_PATH=/usr/local/share/GeoIP/GeoLite2-City.mmdb

RUN apt-get update && apt-get install -y gettext-base git composer npm wget && \
    npm install -g n && \
    n v14 && \
    npm install -g yarn && \
    rm -rf /var/www && \
    mkdir -p /usr/local/share/GeoIP/ && \
    wget -O /usr/local/share/GeoIP/GeoLite2-City.mmdb https://git.io/GeoLite2-City.mmdb

COPY . /var/www
COPY docker/recaptcha_secrets.json /var/www/config/

WORKDIR /var/www

RUN composer install && \
    yarn install && \
    yarn build && \
    chown -R www-data:www-data /var/www && chmod 777 -R /var/www

RUN mkdir -p /config/httpd/conf.d
RUN envsubst < /var/www/docker/apache.conf > /config/httpd/conf.d/site.conf

ENTRYPOINT /var/www/docker/entrypoint.sh
