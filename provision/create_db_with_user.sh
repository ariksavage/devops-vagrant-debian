#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Create default database and user"
rootpasswd="$1"
db="$2"
user="$3"
pass="$4"

echo "Create ${db}"
mysql -u root -p${rootpasswd} -e "CREATE DATABASE IF NOT EXISTS ${db} /*\!40100 DEFAULT CHARACTER SET utf8 */;";

echo "Create ${user}"
mysql -u root -p${rootpasswd} -e "CREATE USER IF NOT EXISTS ${user}@'localhost' IDENTIFIED BY '${pass}';"

echo "Grant privileges on ${db} to ${user}"
mysql -u root -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost';"

echo "Flush privileges"
mysql -u root -p${rootpasswd} -e "FLUSH PRIVILEGES;"