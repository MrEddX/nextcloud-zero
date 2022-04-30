#!/bin/bash
##########################################################################################
# Ubuntu 22.04+ LTS x86_64
# Nextcloud latest
# Carsten Rieger IT-Services (www.c-rieger.de)
# Vielen Dank an:
# https://github.com/MrEddX
# https://github.com/DasCanard
##########################################################################################

###########################
# Konfigurationsvariablen #
###########################

# Datenverzeichnis: wo sollen die Echtdaten liegen
# absoluter Pfad, bspw.: "/var/nc_data"
NEXTCLOUDDATAPATH="/data"

# Lokaler Nextcloud Administrator
# beliebiger Name, bspw.: "nc_admin"
NEXTCLOUDADMINUSER="nc_admin"

# Passwort des lokalen Nextcloud Administrators
# NEXTCLOUDADMINUSERPASSWORD="NeXtCLoUd-PwD"
# oder automatisch generieren lassen
NEXTCLOUDADMINUSERPASSWORD=$(openssl rand -hex 16)

# Nextcloud Release (https://nextcloud.com/changelog/), bspw.:
# NCRELEASE="nextcloud-23.0.4.tar.bz2" oder das aktuelle:
NCRELEASE="latest.tar.bz2"

# Ihre Nextcloud Domain ohne(!) https
# Wird der Parameter LETSENCRYPT="y" gesetzt
# so werden TLS Zertifikate von dieser Domain
# von Let's Encrypt automatisch eingebunden
NEXTCLOUDDNS="ihre.domain.de"

# Let'sEncrypt-TLS: [y|n]
# Sollen Zertifikate von LetsEncrypt eingerichtet werden?
# LETSENCRYPT="y" <- inkl. automat. Renewals
LETSENCRYPT="n"

# Nextcloud Externe IP(v4), bspw.:
# NEXTCLOUDEXTIP="123.124.125.120"
NEXTCLOUDEXTIP=$(dig +short txt ch whoami.cloudflare @1.0.0.1)

# MariaDB-Root-Passwort, bspw.:
# MARIADBROOTPASSWORD="MaRiAdB-RooT-PwD"
# oder automatisch generieren lassen
MARIADBROOTPASSWORD=$(openssl rand -hex 16)

# Database MariaDB o. postgreSQL [m|p]
DATABASE="m"

# Time Zone
CURRENTTIMEZONE='Europe/Berlin'

# Phone Region
PHONEREGION='DE'

# 2. LAN-Interface (ETH1): [y|n]
# Bspw. für vLAN's
LAN2="n"

###########################
# Installationsskript     #
###########################

# Linuxbenutzer ermitteln
BENUTZERNAME=$(logname)

# Ausführung als ROOT überprüfen
if [ "$(id -u)" != "0" ]
then
clear
echo ""
echo "*****************************"
echo "* BITTE ALS ROOT AUSFÜHREN! *"
echo "*****************************"
echo ""
exit 1
fi

if [ "$(lsb_release -r | awk '{ print $2 }')" = "22.04" ]
then
clear
echo "*************************************************"
echo "*  Pre-Installationschecks werden durchgefuehrt *"
echo "*************************************************"
echo ""
echo "* Test: Root ...............:::::::::::::::: OK *"
echo ""
echo "* Test: Ubuntu 22.04 LTS .........:::::::::: OK *"
echo ""
else
clear
echo ""
echo "**************************************"
echo "* Skript exklusiv nur fuer Ubuntu 22 *"
echo "**************************************"
echo ""
exit 1
fi

###########################
# Prüfen ob Benutzer-     #
# verzeichnis existiert   #
###########################
if [ ! -d "/home/$BENUTZERNAME/" ]; then
  echo "* Erstelle: Benutzerverzeichnis ......:::::: OK *"
  echo ""
  mkdir /home/$BENUTZERNAME/
  echo "* Test: Benutzerverzeichnis ........:::::::: OK *"
  echo ""
    else
  echo "* Test: Benutzerverzeichnis ........:::::::: OK *"
  echo ""
  fi

###########################
# Prüfen ob Installations-#
# scriptverzeichnis       #
# existiert               #
###########################
  if [ ! -d "/home/$BENUTZERNAME/Nextcloud-Installationsskript/" ]; then
  echo "* Erstelle: Installationsskript-Verzeichnis  OK *"
  echo ""
  mkdir /home/$BENUTZERNAME/Nextcloud-Installationsskript/
  echo "* Test: Installationsskript-Verzeichnis ..:: OK *"
  echo ""
    else
  echo "* Test: Installationsskript-Verzeichnis ..:: OK *"
  echo ""
  fi
  echo "*************************************************"
  echo "*  Pre-Installationschecks erfolgreich!         *"
  echo "*************************************************"
  echo ""
  sleep 3

# Namensauflösung ermitteln
RESOLVER=$(cat /etc/resolv.conf | grep "nameserver" | awk '{ print $2 }')

# Lokale IP ermitteln
IPA=$(hostname -I | awk '{print $1}')

###########################
# Systempfade auslesen    #
###########################
addaptrepository=$(which add-apt-repository)
adduser=$(which adduser)
apt=$(which apt-get)
aptkey=$(which apt-key)
aptmark=$(which apt-mark)
cat=$(which cat)
chmod=$(which chmod)
chown=$(which chown)
clear=$(which clear)
cp=$(which cp)
curl=$(which curl)
echo=$(which echo)
ip=$(which ip)
ln=$(which ln)
mkdir=$(which mkdir)
mv=$(which mv)
rm=$(which rm)
sed=$(which sed)
service=$(which service)
sudo=$(which sudo)
su=$(which su)
systemctl=$(which systemctl)
tar=$(which tar)
touch=$(which touch)
usermod=$(which usermod)
wget=$(which wget)

###########################
# Uninstall-Skript        #
###########################

${touch} /home/$BENUTZERNAME/Nextcloud-Installationsskript/uninstall.sh
${cat} <<EOF >/home/$BENUTZERNAME/Nextcloud-Installationsskript/uninstall.sh
#!/bin/bash
# Ausführung als ROOT überprüfen
if [ "$(id -u)" != "0" ]
then
clear
echo ""
echo "*****************************"
echo "* BITTE ALS ROOT AUSFÜHREN! *"
echo "*****************************"
echo ""
exit 1
fi
clear
echo "*************************************************************************************"
echo "*                        WARNING! WARNING! WARNING!                                 *"
echo "*                                                                                   *"
echo "* Nextcloud as well as ALL user files will be IRREVERSIBLY REMOVED from the system! *"
echo "*                                                                                   *"
echo "*************************************************************************************"
echo
echo "Press Ctrl+C To Abort"
echo
seconds=$((10))
while [ \$seconds -gt 0 ]; do
   echo -ne "Removal begins after: \$seconds\033[0K\r"
   sleep 1
   : \$((seconds--))
done
rm -Rf $NEXTCLOUDDATAPATH
${mv} /etc/hosts.bak /etc/hosts
echo "Software entfernen..."
apt remove --purge --allow-change-held-packages -y nginx* php* mariadb-* mysql-common libdbd-mariadb-perl galera-* postgresql-* redis* fail2ban ufw
rm -Rf /etc/ufw /etc/fail2ban /var/www /etc/mysql /etc/postgresql /etc/postgresql-common /var/lib/mysql /var/lib/postgresql /etc/letsencrypt /var/log/nextcloud /home/$BENUTZERNAME/Nextcloud-Installationsskript/install.log /home/$BENUTZERNAME/Nextcloud-Installationsskript/update.sh
${addaptrepository} ppa:ondrej/php -ry
${addaptrepository} ppa:ondrej/nginx -ry
rm -f /etc/ssl/certs/dhparam.pem /etc/apt/sources.list.d/* /etc/motd /root/.bash_aliases
deluser --remove-all-files acmeuser
crontab -u www-data -r
rm -f /etc/sudoers.d/acmeuser
apt autoremove -y
apt autoclean -y
exit 0
EOF
chmod +x /home/$BENUTZERNAME/Nextcloud-Installationsskript/uninstall.sh

###########################
# Hostdatei anpassen      #
###########################
${cp} /etc/hosts /etc/hosts.bak
${sed} -i '/127.0.1.1/d' /etc/hosts
${cat} <<EOF >> /etc/hosts
127.0.1.1 $(hostname) $NEXTCLOUDDNS
$NEXTCLOUDEXTIP $NEXTCLOUDDNS
EOF

###########################
# Systemeinstellungen     #
###########################
${apt} install -y figlet
figlet=$(which figlet)
${touch} /etc/motd
${figlet} Nextcloud > /etc/motd
${cat} <<EOF >> /etc/motd

      (c) Carsten Rieger IT-Services
           https://www.c-rieger.de

EOF

###########################
# Logdatei                #
# install.log             #
###########################
exec > >(tee -i "/home/$BENUTZERNAME/Nextcloud-Installationsskript/install.log")
exec 2>&1

###########################
# Globale Update-Funktion #
###########################
function update_and_clean() {
  ${apt} update
  ${apt} upgrade -y
  ${apt} autoclean -y
  ${apt} autoremove -y
  }

###########################
# Kosmetische Funktion    #
###########################
CrI() {
  while ps "$!" > /dev/null; do
  echo -n '.'
  sleep '0.5'
  done
  ${echo} ''
  }

###########################
# Relevante Softwarepakete#
# werden für apt geblockt #
###########################
function setHOLD() {
  ${aptmark} hold nginx*
  ${aptmark} hold redis*
  ${aptmark} hold mariadb*
  ${aptmark} hold mysql*
  ${aptmark} hold php*
  }

###########################
# Services neu starten    #
###########################
function restart_all_services() {
  ${service} nginx restart
  if [ $DATABASE == "m" ]
  then
        ${service} mysql restart
  else
        ${service} postgresql restart
  fi
  ${service} redis-server restart
  ${service} php8.0-fpm restart
  }

###########################
# Daten indizieren        #
###########################
function nextcloud_scan_data() {
  ${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ files:scan --all
  ${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ files:scan-app-data
  ${service} fail2ban restart
  }

###########################
# IPv4 für "APT'          #
###########################
${echo} 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/99force-ipv4

###########################
# Basissoftware           #
###########################
${clear}
${echo} "Systemaktualisierung und Einrichtung der Software-Repos"
${echo} ""
sleep 3
${apt} upgrade -y
${apt} install -y \
apt-transport-https bash-completion bzip2 ca-certificates cron curl dialog dirmngr ffmpeg ghostscript git gpg gnupg gnupg2 htop \
libfile-fcntllock-perl libfontconfig1 libfuse2 locate lsb-release net-tools screen smbclient socat software-properties-common \
ssl-cert tree ubuntu-keyring unzip wget zip

###########################
# Energiesparmodus        #
###########################
${systemctl} mask sleep.target suspend.target hibernate.target hybrid-sleep.target

###########################
# PHP 8 Repositories      #
###########################
${addaptrepository} ppa:ondrej/php -y
# ${echo} "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -cs) main" | /usr/bin/tee /etc/apt/sources.list.d/php.list
# ${aptkey} adv --keyserver keyserver.ubuntu.com --recv-keys 4f4ea0aae5267a6c

###########################
# NGINX Repositories      #
###########################
${addaptrepository} ppa:ondrej/nginx -y
# Aktuell nicht verfügbar
# ${curl} https://nginx.org/keys/nginx_signing.key | /usr/bin/gpg --dearmor | /usr/bin/tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
# ${echo} "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | /usr/bin/tee /etc/apt/sources.list.d/nginx.list

###########################
# DB Repositories         #
###########################
if [ $DATABASE == "m" ]
then
        ${echo} "MariaDB aus dem PPA"
        # ${echo} "deb [arch=amd64] https://mirror.kumi.systems/mariadb/repo/10.7/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/mariadb.list
        # ${aptkey} adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
else
        ${echo} "postgreSQL aus dem PPA"
        # ${echo} "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
        # ${wget} --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
fi

###########################
# Entfernen auto-Updates  #
###########################
${apt} purge -y unattended-upgrades

###########################
# Systemaktualisierung    #
###########################
update_and_clean

###########################
# Bereinigung             #
###########################
${apt} remove -y apache2 nginx nginx-common nginx-full --allow-change-held-packages
${rm} -Rf /etc/apache2 /etc/nginx

###########################
# Installation NGINX      #
###########################
${clear}
${echo} "NGINX-Installation"
${echo} ""
sleep 3
${apt} install -y nginx --allow-change-held-packages
${systemctl} enable nginx.service

###########################
# Optimierung NGINX       #
###########################
${mv} /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
${touch} /etc/nginx/nginx.conf
${cat} <<EOF >/etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /var/run/nginx.pid;
events {
  worker_connections 2048;
  multi_accept on; use epoll;
  }
http {
  server_names_hash_bucket_size 64;
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log warn;
  #set_real_ip_from 127.0.0.1;
  real_ip_header X-Forwarded-For;
  real_ip_recursive on;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  send_timeout 3600;
  tcp_nopush on;
  tcp_nodelay on;
  open_file_cache max=500 inactive=10m;
  open_file_cache_errors on;
  keepalive_timeout 65;
  reset_timedout_connection on;
  server_tokens off;
  resolver $RESOLVER valid=30s;
  resolver_timeout 5s;
  include /etc/nginx/conf.d/*.conf;
  }
EOF

###########################
# Neustart NGINX          #
###########################
${service} nginx restart

###########################
# Erstellen Verzeichnisse #
###########################
${mkdir} -p /var/log/nextcloud /var/www/letsencrypt/.well-known/acme-challenge /etc/letsencrypt/rsa-certs /etc/letsencrypt/ecc-certs
${chmod} -R 775 /var/www/letsencrypt
${chmod} -R 770 /etc/letsencrypt
${chown} -R www-data:www-data /var/log/nextcloud /var/www/ /etc/letsencrypt

###########################
# Hinzufügen ACME-User    #
###########################
${adduser} --disabled-login --gecos "" acmeuser
${usermod} -aG www-data acmeuser
${touch} /etc/sudoers.d/acmeuser
${cat} <<EOF >/etc/sudoers.d/acmeuser
acmeuser ALL=NOPASSWD: /bin/systemctl reload nginx.service
EOF
${su} - acmeuser -c "/usr/bin/curl https://get.acme.sh | sh"
${su} - acmeuser -c ".acme.sh/acme.sh --set-default-ca --server letsencrypt"

###########################
# Installation von PHP 8  #
###########################
${clear}
${echo} "PHP-Installation"
${echo} ""
sleep 3
${apt} install -y php-common php8.0-{fpm,gd,curl,xml,zip,intl,mbstring,bz2,ldap,apcu,bcmath,gmp,imagick,igbinary,redis,smbclient,cli,common,opcache,readline} imagemagick ldap-utils nfs-common cifs-utils --allow-change-held-packages

###########################
# Optimierung von PHP 8   #
###########################
AvailableRAM=$(/usr/bin/awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
AverageFPM=$(/usr/bin/ps --no-headers -o 'rss,cmd' -C php-fpm8.0 | /usr/bin/awk '{ sum+=$1 } END { printf ("%d\n", sum/NR/1024,"M") }')
FPMS=$((AvailableRAM/AverageFPM))
PMaxSS=$((FPMS*2/3))
PMinSS=$((PMaxSS/2))
PStartS=$(((PMaxSS+PMinSS)/2))
${cp} /etc/php/8.0/fpm/pool.d/www.conf /etc/php/8.0/fpm/pool.d/www.conf.bak
${cp} /etc/php/8.0/fpm/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf.bak
${cp} /etc/php/8.0/cli/php.ini /etc/php/8.0/cli/php.ini.bak
${cp} /etc/php/8.0/fpm/php.ini /etc/php/8.0/fpm/php.ini.bak
${cp} /etc/php/8.0/fpm/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf.bak
${cp} /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak
${sed} -i 's/;env\[HOSTNAME\] = /env[HOSTNAME] = /' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/;env\[TMP\] = /env[TMP] = /' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/;env\[TMPDIR\] = /env[TMPDIR] = /' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/;env\[TEMP\] = /env[TEMP] = /' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/;env\[PATH\] = /env[PATH] = /' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/pm.max_children =.*/pm.max_children = '$FPMS'/' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/pm.start_servers =.*/pm.start_servers = '$PStartS'/' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/;pm.max_requests =.*/pm.max_requests = 2000/' /etc/php/8.0/fpm/pool.d/www.conf
${sed} -i 's/output_buffering =.*/output_buffering = 'Off'/' /etc/php/8.0/cli/php.ini
${sed} -i 's/max_execution_time =.*/max_execution_time = 3600/' /etc/php/8.0/cli/php.ini
${sed} -i 's/max_input_time =.*/max_input_time = 3600/' /etc/php/8.0/cli/php.ini
${sed} -i 's/post_max_size =.*/post_max_size = 10240M/' /etc/php/8.0/cli/php.ini
${sed} -i 's/upload_max_filesize =.*/upload_max_filesize = 10240M/' /etc/php/8.0/cli/php.ini
${sed} -i "s|;date.timezone.*|date.timezone = $CURRENTTIMEZONE|" /etc/php/8.0/cli/php.ini
${sed} -i 's/memory_limit = 128M/memory_limit = 2G/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/output_buffering =.*/output_buffering = 'Off'/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/max_execution_time =.*/max_execution_time = 3600/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/max_input_time =.*/max_input_time = 3600/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/post_max_size =.*/post_max_size = 10240M/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/upload_max_filesize =.*/upload_max_filesize = 10240M/' /etc/php/8.0/fpm/php.ini
${sed} -i "s|;date.timezone.*|date.timezone = $CURRENTTIMEZONE|" /etc/php/8.0/fpm/php.ini
${sed} -i 's/;session.cookie_secure.*/session.cookie_secure = True/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.enable=.*/opcache.enable=1/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.enable_cli=.*/opcache.enable_cli=1/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=128/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/;opcache.save_comments=.*/opcache.save_comments=1/' /etc/php/8.0/fpm/php.ini
${sed} -i 's/allow_url_fopen =.*/allow_url_fopen = 1/' /etc/php/8.0/fpm/php.ini
${sed} -i '$aapc.enable_cli=1' /etc/php/8.0/mods-available/apcu.ini
${sed} -i "s|;emergency_restart_threshold.*|emergency_restart_threshold = 10|g" /etc/php/8.0/fpm/php-fpm.conf
${sed} -i "s|;emergency_restart_interval.*|emergency_restart_interval = 1m|g" /etc/php/8.0/fpm/php-fpm.conf
${sed} -i "s|;process_control_timeout.*|process_control_timeout = 10|g" /etc/php/8.0/fpm/php-fpm.conf
${sed} -i 's/rights=\"none\" pattern=\"PS\"/rights=\"read|write\" pattern=\"PS\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"EPS\"/rights=\"read|write\" pattern=\"EPS\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"PDF\"/rights=\"read|write\" pattern=\"PDF\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"XPS\"/rights=\"read|write\" pattern=\"XPS\"/' /etc/ImageMagick-6/policy.xml
/usr/bin/ln -s /usr/local/bin/gs /usr/bin/gs

###########################
# Neustart PHP and NGINX  #
###########################
${service} php8.0-fpm restart
${service} nginx restart

###########################
# Installation DB         #
###########################
${clear}
${echo} "DB-Installation"
${echo} ""
sleep 3
if [ $DATABASE == "m" ]
then
        ${apt} install -y php8.0-mysql mariadb-server --allow-change-held-packages
        ${service} mysql stop
        ${mv} /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
        ${cat} <<EOF >/etc/mysql/my.cnf
[client]
default-character-set = utf8mb4
port = 3306
socket = /var/run/mysqld/mysqld.sock
[mysqld_safe]
log_error=/var/log/mysql/mysql_error.log
nice = 0
socket = /var/run/mysqld/mysqld.sock
[mysqld]
basedir = /usr
bind-address = 127.0.0.1
binlog_format = ROW
bulk_insert_buffer_size = 16M
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
concurrent_insert = 2
connect_timeout = 5
datadir = /var/lib/mysql
default_storage_engine = InnoDB
expire_logs_days = 2
general_log_file = /var/log/mysql/mysql.log
general_log = 0
innodb_buffer_pool_size = 2G
innodb_buffer_pool_instances = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_file_per_table = 1
innodb_open_files = 400
innodb_io_capacity = 4000
innodb_flush_method = O_DIRECT
innodb_read_only_compressed=OFF
key_buffer_size = 128M
lc_messages_dir = /usr/share/mysql
lc_messages = en_US
log_bin = /var/log/mysql/mariadb-bin
log_bin_index = /var/log/mysql/mariadb-bin.index
log_error = /var/log/mysql/mysql_error.log
log_slow_verbosity = query_plan
log_warnings = 2
long_query_time = 1
max_allowed_packet = 16M
max_binlog_size = 100M
max_connections = 200
max_heap_table_size = 64M
myisam_recover_options = BACKUP
myisam_sort_buffer_size = 512M
port = 3306
pid-file = /var/run/mysqld/mysqld.pid
query_cache_limit = 2M
query_cache_size = 64M
query_cache_type = 1
query_cache_min_res_unit = 2k
read_buffer_size = 2M
read_rnd_buffer_size = 1M
skip-log-bin
skip-external-locking
skip-name-resolve
slow_query_log_file = /var/log/mysql/mariadb-slow.log
slow-query-log = 1
socket = /var/run/mysqld/mysqld.sock
sort_buffer_size = 4M
table_open_cache = 400
thread_cache_size = 128
tmp_table_size = 64M
tmpdir = /tmp
transaction_isolation = READ-COMMITTED
#unix_socket=OFF
user = mysql
wait_timeout = 600
[mysqldump]
max_allowed_packet = 16M
quick
quote-names
[isamchk]
key_buffer = 16M
EOF
        ${service} mysql restart
        mysql=$(which mysql)
        ${mysql} <<EOF
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER nextcloud@localhost identified by 'nextcloud';
GRANT ALL PRIVILEGES on nextcloud.* to nextcloud@localhost;
FLUSH privileges;
EOF
        cat <<EOF | ${mysql_secure_installation}
\n
n
y
y
y
y
EOF
        mysql -u root -e "SET PASSWORD FOR root@'localhost' = PASSWORD('$MARIADBROOTPASSWORD'); FLUSH PRIVILEGES;"
else
${apt} install -y php8.0-pgsql postgresql-14 --allow-change-held-packages
sudo -u postgres psql <<EOF
CREATE USER nextcloud WITH PASSWORD 'nextcloud';
CREATE DATABASE nextcloud TEMPLATE template0 ENCODING 'UNICODE';
ALTER DATABASE nextcloud OWNER TO nextcloud;
GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;
EOF
${service} postgresql stop
${cp} /etc/postgresql/14/main/postgresql.conf /etc/postgresql/14/main/postgresql.conf.bak
${service} postgresql restart
fi

###########################
# Installation Redis      #
###########################
${clear}
${echo} "REDIS-Installation"
${echo} ""
sleep 3
${apt} install -y redis-server --allow-change-held-packages
${cp} /etc/redis/redis.conf /etc/redis/redis.conf.bak
${sed} -i 's/port 6379/port 0/' /etc/redis/redis.conf
${sed} -i s/\#\ unixsocket/\unixsocket/g /etc/redis/redis.conf
${sed} -i 's/unixsocketperm 700/unixsocketperm 770/' /etc/redis/redis.conf
${sed} -i 's/# maxclients 10000/maxclients 10240/' /etc/redis/redis.conf
${cp} /etc/sysctl.conf /etc/sysctl.conf.bak
${sed} -i '$avm.overcommit_memory = 1' /etc/sysctl.conf
${usermod} -a -G redis www-data

###########################
# Self-Signed-SSL         #
###########################
${apt} install -y ssl-cert

###########################
# Vorbereitung NGINX TLS  #
###########################
[ -f /etc/nginx/conf.d/default.conf ] && ${mv} /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
${touch} /etc/nginx/conf.d/default.conf
${touch} /etc/nginx/conf.d/http.conf
${cat} <<EOF >/etc/nginx/conf.d/http.conf
upstream php-handler {
  server unix:/run/php/php8.0-fpm.sock;
  }
  server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name cloud.server.io;
    root /var/www;
    location ^~ /.well-known/acme-challenge {
      default_type text/plain;
      root /var/www/letsencrypt;
      }
    location / {
      return 301 https://\$host\$request_uri;
      }
   }
EOF
### MUSS für Nextcloud 24 angepasst werden!
${cat} <<EOF >/etc/nginx/conf.d/nextcloud.conf
server {
  listen 443 ssl http2 default_server;
  listen [::]:443 ssl http2 default_server;
  server_name cloud.server.io;
  ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
  ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
  ssl_trusted_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
  #ssl_certificate /etc/letsencrypt/rsa-certs/fullchain.pem;
  #ssl_certificate_key /etc/letsencrypt/rsa-certs/privkey.pem;
  #ssl_certificate /etc/letsencrypt/ecc-certs/fullchain.pem;
  #ssl_certificate_key /etc/letsencrypt/ecc-certs/privkey.pem;
  #ssl_trusted_certificate /etc/letsencrypt/ecc-certs/chain.pem;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.3 TLSv1.2;
  ssl_ciphers 'TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384';
  ssl_ecdh_curve X448:secp521r1:secp384r1;
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  client_max_body_size 10G;
  client_body_timeout 3600s;
  fastcgi_buffers 64 4K;
  gzip on;
  gzip_vary on;
  gzip_comp_level 4;
  gzip_min_length 256;
  gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
  gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
  add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;
  add_header Permissions-Policy "interest-cohort=()";
  add_header Referrer-Policy "no-referrer" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Download-Options "noopen" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Permitted-Cross-Domain-Policies "none" always;
  add_header X-Robots-Tag "none" always;
  add_header X-XSS-Protection "1; mode=block" always;
  fastcgi_hide_header X-Powered-By;
  root /var/www/nextcloud;
  index index.php index.html /index.php\$request_uri;
  location = / {
    if ( \$http_user_agent ~ ^DavClnt ) {
      return 302 /remote.php/webdav/\$is_args\$args;
      }
  }
  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
    }
  location ^~ /apps/rainloop/app/data {
    deny all;
    }
  location ^~ /.well-known {
    location = /.well-known/carddav { return 301 /remote.php/dav/; }
    location = /.well-known/caldav  { return 301 /remote.php/dav/; }
    location /.well-known/acme-challenge { try_files \$uri \$uri/ =404; }
    location /.well-known/pki-validation { try_files \$uri \$uri/ =404; }
    return 301 /index.php\$request_uri;
    }
  location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:\$|/)  { return 404; }
  location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)  { return 404; }
  location ~ \.php(?:\$|/) {
    rewrite ^/(?!index|test|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy) /index.php\$request_uri;
    fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
    set \$path_info \$fastcgi_path_info;
    try_files \$fastcgi_script_name =404;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_param PATH_INFO \$path_info;
    fastcgi_param HTTPS on;
    fastcgi_param modHeadersAvailable true;
    fastcgi_param front_controller_active true;
    fastcgi_pass php-handler;
    fastcgi_intercept_errors on;
    fastcgi_request_buffering off;
    fastcgi_read_timeout 3600;
    fastcgi_send_timeout 3600;
    fastcgi_connect_timeout 3600;
    }
  location ~ \.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite)\$ {
    try_files \$uri /index.php\$request_uri;
    expires 6M;
    access_log off;
    location ~ \.wasm\$ {
      default_type application/wasm;
      }
    }
  location ~ \.woff2?\$ {
    try_files \$uri /index.php\$request_uri;
    expires 7d;
    access_log off;
    }
  location /remote {
    return 301 /remote.php\$request_uri;
    }
  location / {
    try_files \$uri \$uri/ /index.php\$request_uri;
    }
}
EOF
${clear}
${echo} "Diffie-Hellman key:"
${echo} ""
/usr/bin/openssl dhparam -dsaparam -out /etc/ssl/certs/dhparam.pem 4096
${echo} ""
sleep 3

###########################
# Übernahme der Hostnames #
###########################
${sed} -i "s/server_name cloud.server.io;/server_name $(hostname) $NEXTCLOUDDNS;/" /etc/nginx/conf.d/http.conf
${sed} -i "s/server_name cloud.server.io;/server_name $(hostname) $NEXTCLOUDDNS;/" /etc/nginx/conf.d/nextcloud.conf

###########################
# Anlegen Nextcloud-CRON  #
###########################
(/usr/bin/crontab -u www-data -l ; echo "*/5 * * * * /usr/bin/php -f /var/www/nextcloud/cron.php > /dev/null 2>&1") | /usr/bin/crontab -u www-data -

###########################
# Neustart NGINX          #
###########################
${service} nginx restart
${clear}

###########################
# Herunterladen Nextcloud #
###########################
${echo} "Downloading:" $NCRELEASE
${wget} -q https://download.nextcloud.com/server/releases/$NCRELEASE & CrI
${wget} -q https://download.nextcloud.com/server/releases/$NCRELEASE.md5
${echo} ""
${echo} "Verify Checksum (MD5):"
if [ "$(md5sum -c $NCRELEASE.md5 < $NCRELEASE | awk '{ print $2 }')" = "OK" ]
then
md5sum -c $NCRELEASE.md5 < $NCRELEASE
${echo} ""
else
${clear}
${echo} ""
${echo} "CHECKSUM ERROR => SECURITY ALERT => ABBRUCH!"
exit 1
fi
${echo} "Extracting:" $NCRELEASE
${tar} -xjf $NCRELEASE -C /var/www & CrI
${chown} -R www-data:www-data /var/www/
${rm} -f $NCRELEASE $NCRELEASE.md5

###########################
# Aktualisierung + Restart#
###########################
restart_all_services

###########################
# Nextcloud Installation  #
###########################
${clear}
${echo} "Nextcloud Installation"
${echo} ""
if [[ ! -e $NEXTCLOUDDATAPATH ]];
then
${mkdir} -p $NEXTCLOUDDATAPATH
fi
${chown} -R www-data:www-data $NEXTCLOUDDATAPATH
${echo} "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${echo} "Your Nextcloud will now be installed silently - please be patient!"
${echo} ""
if [ $DATABASE == "m" ]
then
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud" --database-user "nextcloud" --database-pass "nextcloud" --admin-user "${NEXTCLOUDADMINUSER}" --admin-pass "${NEXTCLOUDADMINUSERPASSWORD}" --data-dir "${NEXTCLOUDDATAPATH}"
else
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "pgsql" --database-name "nextcloud" --database-user "nextcloud" --database-pass "nextcloud" --admin-user "${NEXTCLOUDADMINUSER}" --admin-pass "${NEXTCLOUDADMINUSERPASSWORD}" --data-dir "${NEXTCLOUDDATAPATH}"
fi
${echo} ""
sleep 5
###########################
# Auslesen des Hostnames  #
###########################
declare -l YOURSERVERNAME
YOURSERVERNAME=$(hostname)

###########################
# Optimieren config.php   #
###########################
${sudo} -u www-data ${cp} /var/www/nextcloud/config/config.php /var/www/nextcloud/config/config.php.bak
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 0 --value=$YOURSERVERNAME
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 1 --value=$NEXTCLOUDDNS
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 2 --value=$IPA
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set overwrite.cli.url --value=https://$NEXTCLOUDDNS
${echo} ""
${echo} "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${cp} /var/www/nextcloud/.user.ini /usr/local/src/.user.ini.bak
${sudo} -u www-data ${sed} -i 's/output_buffering=.*/output_buffering=0/' /var/www/nextcloud/.user.ini
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ background:cron
${sed} -i '/);/d' /var/www/nextcloud/config/config.php
${cat} <<EOF >>/var/www/nextcloud/config/config.php
'activity_expire_days' => 14,
'allow_local_remote_servers' => true,
'auth.bruteforce.protection.enabled' => true,
'blacklisted_files' =>
array (
0 => '.htaccess',
1 => 'Thumbs.db',
2 => 'thumbs.db',
),
'cron_log' => true,
'default_phone_region' => '$PHONEREGION',
'enable_previews' => true,
'enabledPreviewProviders' =>
array (
0 => 'OC\\Preview\\PNG',
1 => 'OC\\Preview\\JPEG',
2 => 'OC\\Preview\\GIF',
3 => 'OC\\Preview\\BMP',
4 => 'OC\\Preview\\XBitmap',
5 => 'OC\\Preview\\Movie',
6 => 'OC\\Preview\\PDF',
7 => 'OC\\Preview\\MP3',
8 => 'OC\\Preview\\TXT',
9 => 'OC\\Preview\\MarkDown',
),
'filesystem_check_changes' => 0,
'filelocking.enabled' => 'true',
'htaccess.RewriteBase' => '/',
'integrity.check.disabled' => false,
'knowledgebaseenabled' => false,
'log_rotate_size' => '104857600',
'logfile' => '/var/log/nextcloud/nextcloud.log',
'loglevel' => 2,
'logtimezone' => '$CURRENTTIMEZONE',
'memcache.local' => '\\OC\\Memcache\\APCu',
'memcache.locking' => '\\OC\\Memcache\\Redis',
'overwriteprotocol' => 'https',
'preview_max_x' => 1024,
'preview_max_y' => 768,
'preview_max_scale_factor' => 1,
'profile.enabled' => false,
'redis' =>
array (
'host' => '/var/run/redis/redis-server.sock',
'port' => 0,
'timeout' => 0.5,
'dbindex' => 1,
),
'quota_include_external_storage' => false,
'share_folder' => '/Freigaben',
'skeletondirectory' => '',
'trashbin_retention_obligation' => 'auto, 7',
);
EOF
${sed} -i 's/^[ ]*//' /var/www/nextcloud/config/config.php

###########################
# Korrektur Berechtigungen#
###########################
${chown} -R www-data:www-data /var/www

###########################
# Neustart Services       #
###########################
restart_all_services

###########################
# Installation fail2ban   #
###########################
${clear}
${echo} "fail2ban-Installation"
${echo} ""
sleep 3
${apt} install -y fail2ban --allow-change-held-packages
${touch} /etc/fail2ban/filter.d/nextcloud.conf
${cat} <<EOF >/etc/fail2ban/filter.d/nextcloud.conf
[Definition]
_groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
            ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
EOF
${touch} /etc/fail2ban/jail.d/nextcloud.local
${cat} <<EOF >/etc/fail2ban/jail.d/nextcloud.local
[DEFAULT]
maxretry=3
bantime=1800
findtime = 1800

[nextcloud]
backend = auto
enabled = true
port = 80,443
protocol = tcp
filter = nextcloud
maxretry = 5
logpath = /var/log/nextcloud/nextcloud.log

[nginx-http-auth]
enabled = true
EOF

###########################
# Installation ufw        #
###########################
${clear}
${echo} "ufw-Installation"
${echo} ""
sleep 3
${apt} install -y ufw --allow-change-held-packages
ufw=$(which ufw)
${ufw} allow 80/tcp comment "LetsEncrypt(http)"
${ufw} allow 443/tcp comment "TLS(https)"
SSHPORT=`grep -w Port /etc/ssh/sshd_config | awk '/Port/ {print $2}'`
${ufw} allow $SSHPORT/tcp comment "SSH"
${ufw} logging medium && ${ufw} default deny incoming
${cat} <<EOF | ${ufw} enable
y
EOF

###########################
# Neustart fail2ban, ufw  #
# und redis               #
###########################
${service} ufw restart
${service} fail2ban restart
${service} redis-server restart

###########################
# Deaktivierung Apps      #
###########################
${clear}
${echo} "Nextcloud-Anpassungen"
${echo} ""
sleep 3
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable survey_client
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable firstrunwizard
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable federation
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable support

###########################
# Deaktivierung Profile   #
###########################
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:app:set settings profile_enabled_by_default --value="0"

###########################
# Aktivierung Apps        #
###########################
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable admin_audit
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable files_pdfviewer
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable contacts

###########################
# Indizierung             #
###########################
rediscli=$(which redis-cli)
${rediscli} -s /var/run/redis/redis-server.sock <<EOF
FLUSHALL
quit
EOF
${service} nginx stop
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-primary-keys
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-indices
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-columns
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:convert-filecache-bigint
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ security:certificates:import /etc/ssl/certs/ssl-cert-snakeoil.pem
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:app:set settings profile_enabled_by_default --value="0"
${clear}
nextcloud_scan_data
${service} nginx restart

###########################
# initiales Ausführen CRON#
###########################
${echo} ""
${echo} "Systemoptimierungen"
${echo} ""
${echo} "Dieser Vorgang kann mehrere Minuten dauern - bitte haben Sie Geduld!"
${echo} ""
${sudo} -u www-data /usr/bin/php -f /var/www/nextcloud/cron.php & CrI

###########################
# Sperren der Software    #
###########################
setHOLD

###########################
# Request LE-Zertifikate  #
###########################

if [ $LETSENCRYPT == "y" ]
then
${sudo} -i -u acmeuser bash << EOF
/home/acmeuser/.acme.sh/acme.sh --issue -d "${NEXTCLOUDDNS}" --server letsencrypt --keylength 4096 -w /var/www/letsencrypt --key-file /etc/letsencrypt/rsa-certs/privkey.pem --ca-file /etc/letsencrypt/rsa-certs/chain.pem --cert-file /etc/letsencrypt/rsa-certs/cert.pem --fullchain-file /etc/letsencrypt/rsa-certs/fullchain.pem --reloadcmd "sudo /bin/systemctl reload nginx.service"
EOF
${sudo} -i -u acme bash << EOF
/home/acmeuser/.acme.sh/acme.sh --issue -d "${NEXTCLOUDDNS}" --server letsencrypt --keylength ec-384 -w /var/www/letsencrypt --key-file /etc/letsencrypt/ecc-certs/privkey.pem --ca-file /etc/letsencrypt/ecc-certs/chain.pem --cert-file /etc/letsencrypt/ecc-certs/cert.pem --fullchain-file /etc/letsencrypt/ecc-certs/fullchain.pem --reloadcmd "sudo /bin/systemctl reload nginx.service"
EOF
${sed} -i '/ssl-cert-snakeoil/d' /etc/nginx/conf.d/nextcloud.conf
${sed} -i s/#\ssl/\ssl/g /etc/nginx/conf.d/nextcloud.conf
${service} nginx restart
fi

###########################
# LAN-Interface 2         #
###########################
if [ $LAN2 == "y" ]
then
if [ ! -f /etc/netplan/eth1.yaml ]; then ${touch} /etc/netplan/eth1.yaml; fi
${cat} <<EOF >/etc/netplan/eth1.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    eth1:
      dhcp4: true
  version: 2
EOF
/usr/sbin/netplan apply
fi

###########################
# Abschlußbildschirm      #
###########################
${clear}
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${echo} "Server - IP(v4):"
${echo} "----------------"
${echo} $IPA
${echo} ""
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${echo} "Nextcloud:"
${echo} ""
${echo} "https://$NEXTCLOUDDNS oder https://$IPA"
${echo} ""
${echo} "*******************************************************************************"
${echo} ""
${echo} "Nextcloud User/Pwd: "$NEXTCLOUDADMINUSER" // "$NEXTCLOUDADMINUSERPASSWORD
${echo} ""
${echo} "Passwordreset     : nocc user:resetpassword" $NEXTCLOUDADMINUSER
${echo} ""
${echo} "Nextcloud datapath: "$NEXTCLOUDDATAPATH
${echo} ""
${echo} "Nextcloud DB-/User: nextcloud // nextcloud"
if [ $DATABASE == "m" ]
then
${echo} ""
${echo} "MariaDB-Rootpwd   : "$MARIADBROOTPASSWORD
fi
${echo} ""
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
figl=$(which figlet)
${figl} '(c) c-rieger.de'
${echo} ""
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""

###########################
# Nextcloud-Logdatei      #
###########################
${rm} -f /var/log/nextcloud/nextcloud.log
${sudo} -u www-data ${touch} /var/log/nextcloud/nextcloud.log

###########################
# occ Aliases (nocc)      #
###########################
if [ ! -f /root/.bash_aliases ]; then ${touch} /root/.bash_aliases; fi
${cat} <<EOF >> /root/.bash_aliases
alias nocc="${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ"
EOF

###########################
# Update-Skript anlegen   #
###########################
${touch} /home/$BENUTZERNAME/Nextcloud-Installationsskript/update.sh
${cat} <<EOF >/home/$BENUTZERNAME/Nextcloud-Installationsskript/update.sh
#!/bin/bash
apt-get update
apt-get upgrade -V
apt-get autoremove
apt-get autoclean
chown -R www-data:www-data /var/www/nextcloud
find /var/www/nextcloud/ -type d -exec chmod 750 {} \;
find /var/www/nextcloud/ -type f -exec chmod 640 {} \;
sudo -u www-data php /var/www/nextcloud/updater/updater.phar
sudo -u www-data php /var/www/nextcloud/occ status
sudo -u www-data php /var/www/nextcloud/occ -V
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-columns
sudo -u www-data php /var/www/nextcloud/occ db:convert-filecache-bigint
sudo -u www-data sed -i "s/output_buffering=.*/output_buffering=0/" /var/www/nextcloud/.user.ini
sudo -u www-data php /var/www/nextcloud/occ app:update --all
if [ -e /var/run/reboot-required ]; then echo "*** NEUSTART ERFORDERLICH ***";fi
exit 0
EOF
${chmod} +x /home/$BENUTZERNAME/Nextcloud-Installationsskript/update.sh

###########################
# Bereinigung             #
###########################
${cat} /dev/null > ~/.bash_history
history -c
history -w
exit 0
