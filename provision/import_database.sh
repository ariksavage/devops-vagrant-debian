#!
export DEBIAN_FRONTEND=noninteractive

username="$1"
password="$2"
database_name="$3"

db_dir="/home/vagrant/db"
db_file=$(ls -Art  "$db_dir" | grep '.sql' | tail -n 1)
mysql_file="${db_dir}/${db_file}"

if [ -f $mysql_file ]; then
  echo "IMPORT $db_file INTO $database_name"
  mysql -u "$username" -p${password} "$database_name" < "$mysql_file"
else
  echo "NOTHING TO IMPORT"
fi
