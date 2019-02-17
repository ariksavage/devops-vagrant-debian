#!/bin/bash
source /home/vagrant/tools/common.sh
title "Create default database and user"
rootpasswd="$1"
db="$2"
user="$3"
pass="$4"

info "Create ${db}"
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${db} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
info "Create ${user}"
mysql -uroot -p${rootpasswd} -e "CREATE USER ${user}@'localhost' IDENTIFIED BY '${pass}';"
info "Grant privileges on ${db} to ${user}"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost';"
info "Flush privileges"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
