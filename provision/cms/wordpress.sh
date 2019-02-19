#!/bin/bash
source /home/vagrant/tools/common.sh
title "Installing WordPress to $1"
root_dir="$1"
db_name="$2"
db_user="$3"
db_pass="$4"

cd "$root_dir"

wget https://wordpress.org/latest.zip . >/dev/null 2>&1
unzip latest.zip >/dev/null 2>&1
rm latest.zip
mv wordpress/* .
rm -rf wordpress
#mv

function wp_define(){
  key="$1"
  pattern="\\'$key\\', *'\K.*(?=\\')"
  val="$2"
  perl -pi -e "s~$pattern~$val~g" wp-config.php
}

#update wp-config
cp wp-config-sample.php wp-config.php
wp_define 'DB_NAME'     "$db_name"
wp_define 'DB_USER'     "$db_user"
wp_define 'DB_PASSWORD' "$db_pass"

# add random salts
function salt(){
  echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
}

salt=$(salt)
wp_define 'AUTH_KEY'         "$salt"
salt=$(salt)
wp_define 'SECURE_AUTH_KEY'  "$salt"
salt=$(salt)
wp_define 'LOGGED_IN_KEY'    "$salt"
salt=$(salt)
wp_define 'NONCE_KEY'        "$salt"
salt=$(salt)
wp_define 'AUTH_SALT'        "$salt"
salt=$(salt)
wp_define 'SECURE_AUTH_SALT' "$salt"
salt=$(salt)
wp_define 'LOGGED_IN_SALT'   "$salt"
salt=$(salt)
wp_define 'NONCE_SALT'       "$salt"
#Update permissions
info "WORDPRESS HAS BEEN INSTALLED IN $root_dir"
