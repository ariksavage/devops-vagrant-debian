#!/bin/bash

echo "Configure Apache"
root="$1"
url="$2"
# Write hostfile
echo "Writing default host..."
if [ "$ssl" == "true" ]; then
  echo "Enabling SSL..."
  a2enmod ssl
  certificates_dir="/home/vagrant/certificates"
  mkdir "${certificates_dir}"
  cd "${certificates_dir}"
  # Generate the SSL Key and Certificate
  openssl genrsa -out "${url}".key 2048
  openssl req -new -x509 -key "${url}".key -out "${url}".cert -days 3650 -subj /CN="${url}"


  hostfile="
<VirtualHost *:443>
  ServerName ${url}
  ServerAlias www.${url}
  DocumentRoot ${root}

  #adding custom SSL cert
  SSLEngine on
  SSLCertificateFile ${certificates_dir}/${url}.cert
  SSLCertificateKeyFile ${certificates_dir}/${url}.key

  AllowEncodedSlashes On
  <Directory ${root}>
    Options +Indexes +FollowSymLinks
    DirectoryIndex index.php index.html
    Order allow,deny
    Allow from all
    AllowOverride All
  </Directory>
  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

#redirect http to https
<VirtualHost *:80>
  ServerName ${url}
  ServerAlias www.${url}
  DocumentRoot ${root}
  Redirect permanent / https://${url}
</VirtualHost>"
else
  hostfile="
<VirtualHost *:80>
  ServerName ${url}
  ServerAlias www.${url}
  DocumentRoot ${root}
  AllowEncodedSlashes On
  <Directory ${root}>
    Options +Indexes +FollowSymLinks
    DirectoryIndex index.php index.html
    Order allow,deny
    Allow from all
    AllowOverride All
  </Directory>
  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"
fi
echo "$hostfile" > /etc/apache2/sites-available/000-default.conf
echo "Enable mod_rewrite"
a2enmod rewrite
echo "restart Apache"
service apache2 restart
