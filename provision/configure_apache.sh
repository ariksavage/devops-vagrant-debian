#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Configure Apache"
root="$1"
url="$2"
admin="$3"
ssl="$4"
if [ ! -d "$root" ]; then
  echo "create $root directory"
  mkdir -p "$root"
fi

function regex_replace () {
  find="$1"
  replace="$2"
  file="$3"
  echo "Replace '${find}' with '${replace}' in ${file}"
  if [ -f "$file" ]; then
    perl -p -i -e "s~${find}~${replace}~g" $file
    return 0
  else
    echo "${file} is not a file"
    return 1
  fi
}

function set_host_value () {
  key="$1"
  value="$2"
  file="$3"
  find="(^\s*${key}\s*)(.*)$"
  replace="\1 ${value}"
  regex_replace "$find" "$replace" "$file"
}

echo "Writing host..."

if [ "$ssl" == "true" ]; then
  echo "Enabling SSL..."
  a2enmod ssl
  certificates_dir="/home/vagrant/certificates"
  mkdir -p "${certificates_dir}"
  cd "${certificates_dir}"

  # Generate the SSL Key and Certificate
  openssl genrsa -out "${url}".key 2048  >/dev/null 2>&1
  openssl req -new -x509 -key "${url}".key -out "${url}".cert -days 3650 -subj /CN="${url}" >/dev/null 2>&1
  ssl_hostfile="/etc/apache2/sites-available/default-ssl.conf"
  set_host_value "SSLCertificateFile" "${certificates_dir}/${url}.cert" "$ssl_hostfile"
  set_host_value "SSLCertificateKeyFile" "${certificates_dir}/${url}.key" "$ssl_hostfile"
  a2ensite default-ssl.conf
fi

hostfile="/etc/apache2/sites-available/000-default.conf"


if [ ! -f $root ]; then
  mkdir -p "$root"
fi

echo "Set DocumentRoot"
set_host_value "DocumentRoot" "$root" "$hostfile"

if [ ! -z "$ssl_hostfile" ]; then
  set_host_value "DocumentRoot" "$root" "$ssl_hostfile"
fi
        
directory="        <Directory ${root}>
          Options +Indexes +FollowSymLinks
          DirectoryIndex index.php index.html
          Order allow,deny
          Allow from all
          AllowOverride All
        </Directory>
"

echo "Write <Directory> into host"
perl -p -i -e "s~(\s*<\/VirtualHost>)~${directory}\1~s" "$hostfile"

if [ ! -z "$ssl_hostfile" ]; then
  perl -p -i -e "s~(\s*<\/VirtualHost>)~${directory}\1~s" "$ssl_hostfile"
fi



echo "Enable mod_rewrite"
a2enmod rewrite
echo "restart Apache"
service apache2 restart