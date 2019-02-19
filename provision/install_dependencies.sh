#!/bin/bash
source /home/vagrant/tools/common.sh
mysql_root_pass="$1"

#Install dependencies
title "Install Curl"
DEBIAN_FRONTEND=noninteractive apt-get install -qq curl
title "Install Git"
DEBIAN_FRONTEND=noninteractive apt-get install -qq git

#Install PHP7.3
title "Install PHP 7.3"
DEBIAN_FRONTEND=noninteractive apt-get -qq install apt-transport-https lsb-release ca-certificates
wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
DEBIAN_FRONTEND=noninteractive apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get -qq install php7.3 php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml

# Install Apache
title "Install Apache2"
DEBIAN_FRONTEND=noninteractive apt-get -qq install apache2
service apache2 status

#MySQL
title "Install MySQL"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_pass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_pass"
DEBIAN_FRONTEND=noninteractive apt-get -qq --force-yes install mysql-server

#NodeJS
title "Install Node JS"
curl -sL https://deb.nodesource.com/setup_11.x | /bin/bash -
DEBIAN_FRONTEND=noninteractive apt-get install -qq nodejs
#Unzip
title "Install unzip"
DEBIAN_FRONTEND=noninteractive apt-get install -qq unzip
