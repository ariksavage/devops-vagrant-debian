#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Configure Apache"
root="$1"
url="$2"
admin="$3"
ssl="$4"

echo "Writing host..."
if [ "$ssl" == "true" ]; then
  echo "Enabling SSL..."
  a2enmod ssl
  certificates_dir="/home/vagrant/certificates"
  mkdir -p "${certificates_dir}"
  cd "${certificates_dir}"
  # Generate the SSL Key and Certificate
  openssl genrsa -out "${url}".key 2048
  openssl req -new -x509 -key "${url}".key -out "${url}".cert -days 3650 -subj /CN="${url}"
  hostfile="<VirtualHost *:443>\n"
else
  hostfile="<VirtualHost *:80>\n"
fi
hostfile="${hostfile}
  ServerName ${url}
  ServerAdmin ${admin}
  DocumentRoot ${root}
  "
if [ "$ssl" == "true" ]; then
  hostfile="${hostfile}
  #adding custom SSL cert
  SSLEngine on
  SSLCertificateFile ${certificates_dir}/${url}.cert
  SSLCertificateKeyFile ${certificates_dir}/${url}.key
  "
fi
  hostfile="${hostfile}
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
"
if [ "$ssl" == "true" ]; then
hostfile="${hostfile}
#redirect http to https
<VirtualHost *:80>
  ServerName ${url}
  DocumentRoot ${root}
  Redirect permanent / https://${url}
</VirtualHost>"
fi
echo "$hostfile" > "/etc/apache2/sites-available/${url}.conf"
a2ensite "${url}.conf"
echo "Enable mod_rewrite"
a2enmod rewrite
echo "restart Apache"
service apache2 restart