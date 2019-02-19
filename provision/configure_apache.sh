#!
root="$1"
ssl="$2"
url="$3"
echo "$ssl"
echo "Configure Apache"
# Write hostfile
echo "Writing default host..."
if [ "$ssl" == "true" ]; then

  a2enmod ssl
  mkdir /home/vagrant/certs/
  cd /home/vagrant/certs/
  # Step 1: Generate the SSL Key and Certificate
  openssl genrsa -out "${url}".key 2048
  openssl req -new -x509 -key "${url}".key -out "${url}".cert -days 3650 -subj /CN="${url}"

  #Step 2: Install Certificate on Vagrant’s Apache
  ## Add SSL Certificate and Key to Apache

  hostfile="
<VirtualHost *:443>
  ServerName ${url}
  DocumentRoot ${root}

  #adding custom SSL cert
  SSLEngine on
  SSLCertificateFile /home/vagrant/certs/${url}.cert
  SSLCertificateKeyFile /home/vagrant/certs/${url}.key

  Redirect permanent / https://${url}/

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
  DocumentRoot ${root}
  Redirect permanent / https://${url}
</VirtualHost>"
else
  hostfile="
<VirtualHost *:80>
  ServerName ${url}
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
echo "$hostfile" > "/etc/apache2/sites-available/000-default.conf"
echo "Enable site"
echo "Enable mod_rewrite"
a2enmod rewrite
echo "restart Apache"
service apache2 restart
