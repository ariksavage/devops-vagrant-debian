#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
mysql_root_pass="$1"


#Functions
install_package() {
  package="$1"
  if [ $(dpkg-query -W -f='${status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo "Installing $package..."
    DEBIAN_FRONTEND=noninteractive apt-get install -qq "$package"
  else
    echo "$package is already installed."
  fi
}

#Install dependencies
install_package curl
install_package git

#Install PHP7.3
PHPVERSION=$(php -v | grep -P -o '(?<=PHP )[0-9\.]*')
if [[ $PHPVERSION == *"7.3"* ]]; then
  echo "PHP 7.3 Already installed."
else
  echo "Install PHP 7.3"
  DEBIAN_FRONTEND=noninteractive apt-get -qq install apt-transport-https lsb-release ca-certificates
  wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
  install_package php7.3
  install_package php7.3-cli
  install_package php7.3-common
  install_package php7.3-curl
  install_package php7.3-mbstring
  install_package php7.3-mysql
  install_package php7.3-xml
fi

# Install Apache
install_package apache2
service apache2 status

#MySQL
echo "Install MySQL"

debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select mysql-8.0"
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-tools select Enabled"
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-preview select Disabled"
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-product select Ok"


export DEBIAN_FRONTEND=noninteractive
wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb >/dev/null 2>&1
dpkg -i mysql-apt-config_0.8.13-1_all.deb >/dev/null 2>&1
apt-get -qq update >/dev/null 2>&1
install_package mysql-server >/dev/null 2>&1
# debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_pass"
# debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_pass"
# mysql_secure_installation ???



#NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash -
install_package nodejs
#Unzip
install_package unzip
