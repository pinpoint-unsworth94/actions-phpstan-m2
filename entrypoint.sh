#!/bin/bash
set -e

PHP_FULL_VERSION=$(php -r 'echo phpversion();')

if [ -z "$1" ]; then
  ARGUMENTS="analyse ."
else
  ARGUMENTS="$1"
fi

if [ -z "$(ls)" ]; then
  echo "No code have been found.  Did you checkout with «actions/checkout» ?"
  exit 1
fi

if [[ ! "$ARGUMENTS" =~ ^analyse* ]]; then
  echo "INFO: no mode have been detected.  Setting mode to «analyse»"
  ARGUMENTS="analyse ${ARGUMENTS}"
fi

echo "PHP Version : ${PHP_FULL_VERSION}"

echo "Installing composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

echo "Running composer install..."
php -d memory_limit=-1 composer.phar global require hirak/prestissimo
php -d memory_limit=-1 composer.phar install

echo "Installing linters..."
# php -d memory_limit=-1 composer.phar require --dev phpstan/phpstan
# php -d memory_limit=-1 composer.phar require --dev bitexpert/phpstan-magento

echo "## Running PHPStan with arguments «${ARGUMENTS}»"

php -d memory_limit=-1 ./vendor/bin/phpstan ${ARGUMENTS}
