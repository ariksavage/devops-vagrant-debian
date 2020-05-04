#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Create default database and user"
rootpasswd="$1"
db="$2"
user="$3"
pass="$4"

echo "Create ${db}"
echo "Create ${user}"
echo "Grant privileges on ${db} to ${user}"
echo "Flush privileges"
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${db} /*\!40100 DEFAULT CHARACTER SET utf8 */;CREATE USER ${user}@'localhost' IDENTIFIED BY '${pass}';GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost';FLUSH PRIVILEGES;"
