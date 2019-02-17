#!
name="$1"
host="$2"
url="$3"
root="$4"
ssh_user="$5"
mysql_username="$6"
mysql_password="$7"
mysql_port="$8"
mysql_database="$9"


env="name=${name}
host=${host}
url=${url}
web_root=${root}

#SSH
ssh_user=${ssh_user}

#MySQL
mysql_username=${mysql_username}
mysql_password=${mysql_password}
mysql_port=${mysql_port}
mysql_database=${mysql_database}
"
echo "$env" > /home/vagrant/config/.env.local
