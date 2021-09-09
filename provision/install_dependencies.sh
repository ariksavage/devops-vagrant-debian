#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
mysql_root_pass="$1"

#Functions
install_package() {
  package="$1"
  apt-get -qq update
  if [ $(dpkg-query -W -f='${status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo ""
    echo ""
    echo ""
    echo "Installing $package..."
    echo "================================================================================"
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

# Install PHP 7.4
echo ""
echo ""
echo ""
echo "Installing PHP 7.4..."
echo "================================================================================"
sudo apt-get -y install lsb-release apt-transport-https ca-certificates
curl -fsSL https://packages.sury.org/php/apt.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/php.gpg add

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
apt-get -qq update
install_package php7.4
install_package php7.4-cli
install_package php7.4-common
install_package php7.4-curl
install_package php7.4-gd
install_package php7.4-mbstring
install_package php7.4-mysql
install_package php7.4-xdebug
install_package php7.4-xml
install_package php7.4-zip

# Install Apache
echo ""
echo ""
echo ""
echo "Install Apache2"
echo "================================================================================"
install_package apache2
service apache2 status

# MySQL
echo ""
echo ""
echo ""
echo "Install MySQL"
echo "================================================================================"
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb >/dev/null 2>&1
dpkg -i mysql-apt-config* >/dev/null 2>&1
install_package mariadb-server

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
echo ""
echo ""
echo ""
echo "Install Node JS"
echo "================================================================================"
curl -sL https://deb.nodesource.com/setup_14.x -o ~/nodesource_setup.sh  >/dev/null 2>&1
bash ~/nodesource_setup.sh  >/dev/null 2>&1
rm ~/nodesource_setup.sh 
install_package nodejs

# Composer

if [ $(dpkg-query -W -f='${status}' composer 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo ""
  echo ""
  echo ""
  echo "Install Composer"
  echo "================================================================================"
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  chmod +x /usr/local/bin/composer
  sudo composer self-update
else
  echo "Composer is already installed"
fi
