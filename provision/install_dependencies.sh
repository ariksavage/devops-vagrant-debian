#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
mysql_root_pass="$1"

#Functions
install_package() {
  package="$1"
  apt-get -qq update
  if [ $(dpkg-query -W -f='${status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo "Install $package..."
    apt-get install -qq "$package"
  else
    echo "$package is already installed."
  fi
}

# Install dependencies
install_package curl
install_package git
install_package unzip
install_package apt-transport-https
install_package lsb-release
install_package ca-certificates
install_package gnupg

# Install PHP 7.3
wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >/dev/null 2>&1
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
install_package php7.3
install_package php7.3-cli
install_package php7.3-common
install_package php7.3-curl
install_package php7.3-gd
install_package php7.3-mbstring
install_package php7.3-mysql
install_package php7.3-xdebug
install_package php7.3-xml
install_package php7.3-zip

# Install Apache
install_package apache2
service apache2 status

# MySQL
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb >/dev/null 2>&1
dpkg -i mysql-apt-config* >/dev/null 2>&1
install_package mariadb-server-10.3

# https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
mysql --user=root -p${mysql_root_pass} <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${mysql_root_pass}'),plugin='mysql_native_password' WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

# NodeJS
curl -sL https://deb.nodesource.com/setup_14.x -o ~/nodesource_setup.sh  >/dev/null 2>&1
bash ~/nodesource_setup.sh  >/dev/null 2>&1
rm ~/nodesource_setup.sh 
install_package nodejs

# Composer

if [ $(dpkg-query -W -f='${status}' composer 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Install Composer"

  EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
  then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
  fi

  php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
  RESULT=$?
  rm composer-setup.php
  # download keys
  echo "Create config directory"
  mkdir -p /home/vagrant/.config/composer
  echo "Download latest Composer dev keys"
  wget -q https://composer.github.io/snapshots.pub -o /home/vagrant/.config/composer/keys.dev.pub
  echo "Download latest Composer tags keys"
  wget -q https://composer.github.io/releases.pub -o /home/vagrant/.config/composer/keys.tags.pub

  chmod -R 644 /home/vagrant/.config/composer/*.pub
  chown -R vagrant:vagrant /home/vagrant/.config
else
  echo "Composer is already installed"
fi
