#!
name="$1"
host="$2"
ssh_user="$3"
mysql_username="$4"
mysql_password="$5"
mysql_port="$6"
mysql_database="$7"

env="name=${name}
host=${host}
#SSH
ssh_user=${ssh_user}
#MySQL
mysql_username=${mysql_username}
mysql_password=${mysql_password}
mysql_port=3306
mysql_database=default_db
"
echo "$env" > /home/vagrant/config/.env.local
