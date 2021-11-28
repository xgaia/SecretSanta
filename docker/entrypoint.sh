#! /bin/bash

# configure apache
envsubst < /var/www/docker/apache.conf > /config/httpd/conf.d/site.conf

# init DB
/var/www/bin/console doctrine:schema:update --force

# create .env file
rm /var/www/.env
cat > /var/www/.env <<EOL
###> Symfony ###
APP_ENV=$APP_ENV
APP_SECRET=$APP_SECRET
APP_SALT=$APP_SALT
HOST=$HOST
TRUSTED_PROXIES=$TRUSTED_PROXIES
TRUSTED_HOSTS=$TRUSTED_HOSTS
###< symfony/framework-bundle ###

###> Mailer ###
MAILER_DSN=$MAILER_DSN
MANDRILL_DSN=$MANDRILL_DSN
NOREPLY_EMAIL=$NOREPLY_EMAIL
CONTACT_EMAIL=$CONTACT_EMAIL
MAIL_FROM_ADDRESS=$MAIL_FROM_ADDRESS
MAIL_FROM_NAME=$MAIL_FROM_NAME
###< Mailer ###

###> doctrine/doctrine-bundle ###
DATABASE_URL=$DATABASE_URL
###< doctrine/doctrine-bundle ###

###> Marketing ###
ADWORDS_PASSWORD=$ADWORDS_PASSWORD
GA_VIEW_ID=$GA_VIEW_ID
###< Marketing ###

###> Misc ###
GEO_IP_DB_PATH=/usr/local/share/GeoIP/GeoLite2-City.mmdb
###< Misc ###
EOL

# Run apache
/init.sh
