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

#Install PHP7.4
  echo "Install PHP 7.4"
  DEBIAN_FRONTEND=noninteractive apt-get -qq install apt-transport-https lsb-release ca-certificates
  wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
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

#MySQL
echo "Install MySQL"

# debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select mysql-8.0"
# debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-tools select Enabled"
# debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-preview select Disabled"
# debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-product select Ok"


export DEBIAN_FRONTEND=noninteractive
apt-get -qq install gnupg
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
dpkg -i mysql-apt-config*
apt-get -qq update
apt-get -qq install mariadb-server-10.3

# https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
mysql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${mysql_root_pass}'),plugin='mysql_native_password' WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

#NodeJS
apt-get -qq update
# apt-get install -qq nodejs npm
# curl -sL https://deb.nodesource.com/setup_14.x | bash -
curl -sL https://deb.nodesource.com/setup_14.x -o ~/nodesource_setup.sh
bash ~/nodesource_setup.sh
rm ~/nodesource_setup.sh
install_package nodejs
#Unzip
install_package unzip
