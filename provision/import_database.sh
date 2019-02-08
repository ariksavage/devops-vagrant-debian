#!

username="$1"
password="$2"
database_name="$3"
filename="$4"
echo "IMPORT $filename INTO $database_name"
mysql_file="/home/vagrant/db/${filename}"
mysql -u "$username" -p${password} "$database_name" < "$mysql_file"
