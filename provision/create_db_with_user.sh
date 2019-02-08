#!
rootpasswd="$1"
db="$2"
user="$3"
pass="$4"

mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${db} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -uroot -p${rootpasswd} -e "CREATE USER ${user}@% IDENTIFIED BY '${pass}';"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'%';"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"