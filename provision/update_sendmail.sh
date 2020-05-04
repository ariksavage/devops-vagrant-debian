#!
export DEBIAN_FRONTEND=noninteractive

account_type="$1"
email_addr="$2"
email_pass="$3"
test_recipent="$4"

echo "Configure PHP mail to send via ${account_type}"

echo "Install MSMTP..."
apt-get install -qq msmtp

echo "Create config for ${account_type}"
global_config="/etc/msmtprc"
root_config="/root/.msmtprc" #run as sudo, the "home" directory is /root

if [ "${account_type}" = "yahoo" ]; then
cat <<EOT > "$global_config"
  account yahoo
  tls on
  tls_starttls off
  tls_certcheck off
  auth on
  host smtp.mail.yahoo.com
  user "${email_addr}"
  from "${email_addr}"
  password "${email_pass}"
EOT
fi
if [ "${account_type}" = "gmail" ]; then
  echo "Gmail"
cat <<EOT > "$global_config"
  account gmail
  tls on
  tls_certcheck off
  auth on
  host smtp.gmail.com
  port 587
  user "${email_addr}"
  from "${email_addr}"
  password "${email_pass}"
EOT
fi

cp -p ${global_config} ${root_config}

chown www-data:www-data "${global_config}"
chmod 600 "${global_config}"
chmod 600 "${root_config}"

echo "Update PHP ini"
ini=$(php --ini | grep -P '(?<=Loaded Configuration File:)\s*(.*)$' | tr -s ' ' | cut -d ' ' -f 4)
ini=$(echo "$ini"  | tr -d '[:space:]')
ini=$(echo "$ini" | sed "s/cli/apache2/") #shell loads /cli/php.ini, we want /apache2/php.ini
msmtp_path=$(which msmtp)
find=";*sendmail_path\s*=.*$"
replace="sendmail_path = \"${msmtp_path} -C ${global_config} -a ${account_type} -t\""
echo "REPLACE ${replace}"
sed -i -E "s~$find~$replace~m" "$ini"
service apache2 reload

echo "Send a test message to ${test_recipent}"
echo -e "From: ${email_addr} \n\
To: ${test_recipent} \n\
Subject: MSMTP Test Message \n\
\n\
This email was sent using MSMTP via ${account_type}." >> sample_email.txt

cat sample_email.txt | msmtp --debug -a gmail "$test_recipent"
rm sample_email.txt
