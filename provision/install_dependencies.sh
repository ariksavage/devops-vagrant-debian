#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
mysql_root_pass="$1"

#Functions
install_package() {
  package="$1"
  apt-get -qq update
  if [ $(dpkg-query -W -f='${status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo "Instal $package..."
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
wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >/dev/null 2>&1
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
install_package php7.4
install_package php7.4-cli
install_package php7.4-common
install_package php7.4-curl
install_package php7.4-mbstring
install_package php7.4-mysql
install_package php7.4-xml
install_package php7.4-zip

# Install Apache
install_package apache2
service apache2 status

# MySQL
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb >/dev/null 2>&1
dpkg -i mysql-apt-config* >/dev/null 2>&1
install_package mariadb-server-10.3

# https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
mysql --user=root <<_EOF_
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
