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
    echo ""
    echo ""
    echo "$package is already installed."
    echo ""
    echo ""
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

# Install Apache
echo ""
echo ""
echo ""
echo "Install Apache2"
echo "================================================================================"
install_package apache2
service apache2 status

# Install PHP 8.1
echo ""
echo ""
echo ""
echo "Installing PHP 8.1..."
echo "================================================================================"
# https://www.linuxcapable.com/how-to-install-php-8-1-on-debian-11-bullseye/
apt-get -qq install ca-certificates apt-transport-https software-properties-common lsb-release -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >/dev/null 2>&1
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get -qq update
install_package php8.1
install_package libapache2-mod-php8.1
service apache2 restart
install_package php8.1-cli
install_package php8.1-common
install_package php8.1-curl
install_package php8.1-gd
install_package php8.1-mbstring
install_package php8.1-mysql
install_package php8.1-xdebug
install_package php8.1-xml
install_package php8.1-zip

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
ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_pass}';
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

  EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
  then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
  fi

  php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1
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
  echo "================================================================================"
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  chmod +x /usr/local/bin/composer
  sudo composer self-update
else
  echo "Composer is already installed"
fi
