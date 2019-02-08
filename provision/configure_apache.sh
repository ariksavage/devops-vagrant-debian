#!
root="$1"

echo "Configure Apache"
# Write hostfile
echo "Writing default host..."
echo "<VirtualHost *:80>
    DocumentRoot ${root}
    AllowEncodedSlashes On
    <Directory ${root}>
        Options +Indexes +FollowSymLinks
        DirectoryIndex index.php index.html
        Order allow,deny
        Allow from all
        AllowOverride All
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf
echo "Enable mod_rewrite"
a2enmod rewrite
echo "restart Apache"
service apache2 restart
