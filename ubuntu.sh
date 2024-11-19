#!/bin/bash
##########################################################################################
# Ubuntu 20.04+ / 22.04+ LTS x86_64
# Nextcloud 23+ and 24+ (if released!)
# Carsten Rieger IT-Services (www.c-rieger.de)
# Vielen Dank an / many thanks to:
# https://github.com/MrEddX
# https://github.com/DasCanard
# https://codeberg.org/DecaTec
##########################################################################################

CONFIGFILE="zero.cfg"
INSTALLATIONFILE="zero.sh"
#
#########################################################################
### ! DO NOT CHANGE ANYTHING FROM HERE! // KEINE ÄNDERUNGEN AB HIER ! ###
#########################################################################
if [ "$USER" != "root" ]
then
    clear
    echo ""
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    echo -e " » \e[1;31mKEINE ROOT-BERECHTIGUNGEN! | NO ROOT PERMISSIONS!\033[0m"
    echo ""
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo " » Bitte starten Sie das Skript als root: 'sudo ./$INSTALLATIONFILE'"
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    exit 1
fi

if [ -f /tmp/installation ]; then
        clear
        clear
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
        echo -e " » Die Installation war/ist bereits aktiv  - *\e[1;31mABBRUCH\033[0m*"
        echo -e " » Installation is/was already in progress - *\e[1;31mEXIT\033[0m*"
        echo " » "$(ls -lsha /tmp/installation)
	      echo ""
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""        
        echo " » Prüfen und entfernen // Verify and remove :"
        echo " » sudo rm -f /tmp/installation"
        echo ""
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
        exit 1
fi
##################################################
# Konfigurationsdatei einlesen                   #
##################################################
clear
if [ -f "$CONFIGFILE" ]; then
        echo ""
        echo " » Die Konfigurationsdatei '$CONFIGFILE' wird eingelesen."
        . ./$CONFIGFILE
        NCDBNAME="${NCDBNAME,,}"
        NCDBUSER="${NCDBUSER,,}"
        sleep 2
else
        clear
        echo ""
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
        echo -e " » \e[1;31m'$CONFIGFILE' ist nicht lesbar | '$CONFIGFILE' not readable\033[0m"
        echo ""
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo " » Bitte überprüfen Sie die Datei '$CONFIGFILE'"
        echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
        exit 1
fi
###########################
# Start/Begin            #
###########################
touch /tmp/installation
clear
start=$(date +%s)
# D: Linuxbenutzer ermitteln
# E: identify the current user
BENUTZERNAME=$(logname)
###########################
# IPv4 für "APT'          #
###########################
if [ $APTIP4 == "y" ] 
then
${echo} 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/99force-ipv4
fi
# D: Sicherstellen, dass Basissoftware verfügbar ist
# E: Ensure, admin software is available on the server
if [ -z "$(command -v lsb_release)" ]
then
apt install -y lsb-release
fi
if [ -z "$(command -v curl)" ]
then
apt install -y curl
fi
if [ -z "$(command -v wget)" ]
then
apt install -y wget
fi
if [ -z "$(command -v ping)" ]
then
apt install -y iputils-ping net-tools
fi
# D: Systemvoraussetzungen prüfen
# E: Check system requirements
if [ "$(lsb_release -r | awk '{ print $2 }')" = "22.04" ] || [ "$(lsb_release -r | awk '{ print $2 }')" = "24.04" ]
then
clear
echo "*************************************************"
echo "*  Pre-Installationschecks werden durchgefuehrt *"
echo "*  Pre-Installationschecks are initiated        *"
echo "*************************************************"
echo ""
echo -e "* Test: Root ...............::::::::::::::::\033[32m OK\033[0m *"
echo ""
if [ "$(lsb_release -r | awk '{ print $2 }')" = "22.04" ]
then
echo -e "* Test: Ubuntu 22 was found ........::::::::\033[32m OK\033[0m *"
fi
if [ "$(lsb_release -r | awk '{ print $2 }')" = "24.04" ]
then
echo -e "* Test: Ubuntu 24 was found ........::::::::\033[32m OK\033[0m *"
fi
echo ""
else
clear
echo ""
echo -e " »\e[1;31m"
echo "****************************************"
echo "*   Sie verwenden kein Ubuntu 22/24    *"
echo "* You aren't operating on Ubuntu 22/24 *"
echo "****************************************"
echo  -e "\033[0m"
echo ""
exit 1
fi
###########################
# Uninstall-Skript        #
###########################
mkdir -p /home/"$BENUTZERNAME"/Nextcloud-Installationsskript/
touch /home/"$BENUTZERNAME"/Nextcloud-Installationsskript/uninstall.sh
cat <<EOF >/home/"$BENUTZERNAME"/Nextcloud-Installationsskript/uninstall.sh
#!/bin/bash
if [ "\$(id -u)" != "0" ]
then
clear
echo ""
echo "*****************************"
echo "* BITTE ALS ROOT AUSFÜHREN! *"
echo "*                           *"
echo "* PLEASE OPERATE AS ROOT!   *"
echo "*****************************"
echo ""
exit 1
fi
clear
echo "*************************************************************************************"
echo "*                        ACHTUNG! WARNING! ACHTUNG! WARNING!                        *"
echo "*                                                                                   *"
echo "*   Nextcloud und ALLE Benutzer-Daten und -Dateien werden unwiderruflich gelöscht!  *"
echo "* Nextcloud as well as ALL user files will be IRREVERSIBLY REMOVED from the system! *"
echo "*                                                                                   *"
echo "*************************************************************************************"
echo
echo "Press Ctrl+C To Abort  // Drücke STRG+C um abzubrechen"
echo
seconds=$((5))
while [ \$seconds -gt 0 ]; do
   echo -ne "Removal begins after: \$seconds\033[0K\r"
   sleep 1
   : \$((seconds--))
done
rm -Rf $NEXTCLOUDDATAPATH
mv /etc/hosts.bak /etc/hosts
apt remove --purge --allow-change-held-packages -y lsb-release iputils-ping net-tools figlet apt-transport-https bash-completion bzip2 ca-certificates cron curl dialog dirmngr ffmpeg ghostscript gpg gnupg gnupg2 htop jq libfile-fcntllock-perl libfontconfig1 libfuse2 locate net-tools rsyslog screen smbclient socat software-properties-common ssl-cert tree unzip wget zip nginx php-common php$PHPVERSION-* imagemagick ldap-utils nfs-common cifs-utils libmagickcore-6.q16-6-extra redis-* ssl-cert bzip2 crowdsec crowdsec-firewall-bouncer-nftables ufw mariadb-* mysql-* galera-*

rm -Rf /etc/ufw /etc/crowdsec /var/www /etc/mysql /etc/postgresql /etc/postgresql-common /var/lib/mysql /var/lib/postgresql /etc/letsencrypt /var/log/nextcloud /home/"$BENUTZERNAME"/"$NEXTCLOUDDNS"/Nextcloud-Installationsskript/install.log /home/"$BENUTZERNAME"/"$NEXTCLOUDDNS"/Nextcloud-Installationsskript/update.sh
rm -Rf /etc/nginx /usr/share/keyrings/nginx-archive-keyring.gpg /usr/share/keyrings/postgresql-archive-keyring.gpg
add-apt-repository ppa:ondrej/php -ry
rm -f /etc/ssl/certs/dhparam.pem /etc/apt/sources.list.d/* /etc/motd /root/.bash_aliases
deluser --remove-all-files acmeuser
crontab -u www-data -r
rm -f /etc/sudoers.d/acmeuser
apt autoremove -y
apt autoclean -y
sed -i '/vm.overcommit_memory = 1/d' /etc/sysctl.conf
rm -f /tmp/installation
echo ""
echo "Done!"
exit 0
EOF
chmod +x /home/"$BENUTZERNAME"/Nextcloud-Installationsskript/uninstall.sh
##########################
# Re-Install. verhindern #
# Prevent Second Run     #
##########################
if [ -e "/var/www/nextcloud/config/config.php" ] || [ -e /etc/nginx/conf.d/nextcloud.conf ]; then
  clear
  echo "*************************************************"
  echo -e "* Test: Bestehende Installation ....:::::\e[1;31m FAILED\033[0m *"
  echo -e "* Test: Previous installation ......:::::\e[1;31m FAILED\033[0m *"
  echo "*************************************************"
  echo ""
  echo "* Nextcloud ist auf diesem System bereits installiert!"
  echo "* Nextcloud has already been installed on this system!"
  echo ""
  echo "* Bitte entfernen Sie alles komplett, bevor Sie mit einer Installation fortfahren."
  echo "* Please remove it completely before proceeding to a new installation."
  echo ""
  echo "* Das Uninstall-Skript finden Sie hier // Please find the uninstall script here:"
  echo "* /home/$BENUTZERNAME/Nextcloud-Installationsskript/uninstall.sh"
  echo ""
  exit 1
else
  echo "*************************************************"
  echo -e "* Keine bestehende Installation gefunden .::\033[32m OK\033[0m *"
  echo -e "* No previous installation found ......:::::\033[32m OK\033[0m *"
  echo "*************************************************"
  echo ""
fi
###########################
# Prüfe Homeverzeichnis   #
# Verify homedirectory    #
###########################
if [ ! -d "/home/$BENUTZERNAME/" ]; then
  echo -e "* Erstelle:  Benutzerverzeichnis .....::::::\033[32m OK\033[0m *"
  echo -e "* Creating:  Home Directory ..........::::::\033[32m OK\033[0m *"
  mkdir -p /home/"$BENUTZERNAME"/
  echo ""
  else
  echo -e "* Test: Benutzerverzeichnis ........::::::::\033[32m OK\033[0m *"
  echo -e "* Test: Home directory ..........:::::::::::\033[32m OK\033[0m *"
  echo ""
  fi
if [ ! -d "/home/$BENUTZERNAME/Nextcloud-Installationsskript/" ]; then
  echo -e "* Erstelle: Installationsskript-Verzeichnis:\033[32m OK\033[0m *"
  echo -e "* Creating: Install directory .......:::::::\033[32m OK\033[0m *"
  mkdir /home/"$BENUTZERNAME"/Nextcloud-Installationsskript/
  echo ""
  else
  echo -e "* Test: Installationsskript-Verzeichnis ..::\033[32m OK\033[0m *"
  echo -e "* Test: Installscript directory .....:::::::\033[32m OK\033[0m *"
  echo ""
  fi
  echo "*************************************************"
  echo -e "\033[32m*  Pre-Installationschecks erfolgreich!         *\033[0m"
  echo -e "\033[32m*  Pre-Installation checks successfull!         *\033[0m"
  echo "*************************************************"
  echo ""
  echo -e "* Press Ctrl+C To abort  // Drücke STRG+C um abzubrechen"
  seconds=10
  while [ $seconds -gt 0 ]; do
   echo -ne "* INSTALLATION STARTET IN $seconds\033[0K\r"
   sleep 1
   : $((seconds--))
  done
  echo ""
###########################
# D: Lokale IP ermitteln  #
# E: Identify local ip    #
###########################
IPA=$(hostname -I | awk '{print $1}')
###########################
# D: Systempfade auslesen #
# E: System patches       #
###########################
addaptrepository="add-apt-repository"
adduser=$(command -v adduser)
apt=$(command -v apt-get)
aptmark=$(command -v apt-mark)
cat=$(command -v cat)
chmod=$(command -v chmod)
chown=$(command -v chown)
clear=$(command -v clear)
cp=$(command -v cp)
curl=$(command -v curl)
date=$(command -v date)
echo=$(command -v echo)
lsbrelease=$(command -v lsb_release)
ln=$(command -v ln)
mkdir=$(command -v mkdir)
mv=$(command -v mv)
rm=$(command -v rm)
sed=$(command -v sed)
sudo=$(command -v sudo)
su=$(command -v su)
systemctl=$(command -v systemctl)
tar=$(command -v tar)
timedatectl=$(command -v timedatectl)
touch=$(command -v touch)
usermod=$(command -v usermod)
wget=$(command -v wget)
###########################
# Timezone
###########################
${timedatectl} set-timezone "$CURRENTTIMEZONE"
###########################
# D: Hostdatei anpassen   #
# E: Modify host file     #
###########################
${cp} /etc/hosts /etc/hosts.bak
${sed} -i '/127.0.1.1/d' /etc/hosts
${cat} <<EOF >> /etc/hosts
127.0.1.1 $(hostname)
EOF
###########################
# D: Systemeinstellungen  #
# E: System settings      #
###########################
${apt} install -y figlet
figlet=$(command -v figlet)
${touch} /etc/motd
${figlet} Nextcloud > /etc/motd
${cat} <<EOF >> /etc/motd

      (c) Carsten Rieger IT-Services
           https://www.c-rieger.de

EOF
###########################
# Logdatei / Logfile      #
# install.log             #
###########################
exec > >(tee -i "/home/$BENUTZERNAME/Nextcloud-Installationsskript/install.log")
exec 2>&1
###########################
# D: Update-Funktion      #
# E: Update-function      #
###########################
function update_and_clean() {
  ${apt} update
  ${apt} upgrade -y
  ${apt} autoclean -y
  ${apt} autoremove -y
  }
###########################
# D: Kosmetische Funktion #
# E: Cosmetical function  #
###########################
CrI() {
  while ps "$!" > /dev/null; do
  echo -n '.'
  sleep '0.5'
  done
  ${echo} ''
  }
#############################
# D: Relevante Software     #
#    wird f. apt geblockt   #
# E: Relevant software will #
#    be blocked for apt     #
#############################
function setHOLD() {
  ${aptmark} hold nginx*
  ${aptmark} hold redis*
  ${aptmark} hold mariadb* mysql*
  ${aptmark} hold php-* php$PHPVERSION-*
  }
###########################
# D: Services neu starten #
# E: Restart services     #
###########################
function restart_all_services() {
  ${systemctl} restart nginx
  if [ $DATABASE == "m" ]
  then
        ${systemctl} restart mysql
  else
        ${systemctl} restart postgresql
  fi
  ${systemctl} restart redis-server php$PHPVERSION-fpm
  }
###########################
# D: NC Daten indizieren  #
# E: NC data index        #
###########################
function nextcloud_scan_data() {
  ${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ files:scan --all
  ${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ files:scan-app-data
  }
###########################
# D: Basissoftware        #
# E: Required software    #
###########################
${clear}
${echo} "Systemaktualisierungen u. Rerepositories"
${echo} "System updates and software repositories"
${echo} ""
sleep 3
${apt} update
${apt} upgrade -y
${apt} install -y apt-transport-https bash-completion bzip2 ca-certificates cron curl dialog dirmngr ffmpeg ghostscript gpg gnupg gnupg2 htop jq \
libfile-fcntllock-perl libfontconfig1 libfuse2 locate nodejs npm net-tools rsyslog screen smbclient socat software-properties-common ssl-cert tree unzip wget zip ubuntu-keyring
###########################
# D: Energiesparmodus: aus#
# E: Energy mode: off     #
###########################
${systemctl} mask sleep.target suspend.target hibernate.target hybrid-sleep.target
###########################
# PHP 8 Repositories      #
###########################
${addaptrepository} ppa:ondrej/php -y
if [ "$(lsb_release -r | awk '{ print $2 }')" = "24.04" ]
then
curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6" | gpg --dearmor | sudo tee /usr/share/keyrings/ondrej-ubuntu-php.gpg >/dev/null
${cat} <<EOF > /etc/apt/sources.list.d/ondrej-ubuntu-php-noble.sources
Types: deb
URIs: https://ppa.launchpadcontent.net/ondrej/php/ubuntu/
Suites: noble
Components: main
Signed-By: /usr/share/keyrings/ondrej-ubuntu-php.gpg
EOF
fi
###########################
# NGINX Repositories      #
###########################
${curl} https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
###########################
# DB Repositories         #
###########################
if [ $DATABASE == "m" ]
then
    ${curl} -o /usr/share/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
    echo "deb [signed-by=/usr/share/keyrings/mariadb-keyring.pgp] https://mirror1.hs-esslingen.de/pub/Mirrors/mariadb/repo/10.11/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list
else
    ${wget}  -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /usr/share/keyrings/postgresql-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list      
fi
###########################
# D: Entfernen Autoupdates#
# E: Remove unatt.upgrades#
###########################
if [ $REMOVEUAU == "y" ]
then
${apt} purge -y unattended-upgrades
fi
###########################
# D: Systemaktualisierung #
# E: System update        #
###########################
update_and_clean
###########################
# D: Bereinigung          #
# E: Clean Up             #
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
${apt} update
${apt} install -y nginx --allow-change-held-packages
${systemctl} enable nginx.service
${mv} /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
${touch} /etc/nginx/nginx.conf
${cat} <<EOF >/etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /var/run/nginx.pid;
events {
  worker_connections 2048;
  multi_accept on;
  use epoll;
  }
http {
  log_format criegerde escape=json
  '{'
    '"time_local":"\$time_local",'
    '"remote_addr":"\$remote_addr",'
    '"remote_user":"\$remote_user",'
    '"request":"\$request",'
    '"status": "\$status",'
    '"body_bytes_sent":"\$body_bytes_sent",'
    '"request_time":"\$request_time",'
    '"http_referrer":"\$http_referer",'
    '"http_user_agent":"\$http_user_agent"'
  '}';
  server_names_hash_bucket_size 64;
  access_log /var/log/nginx/access.log criegerde;
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
# Neustart/Restart NGINX  #
###########################
${systemctl} restart nginx
###########################
# D: Verzeichnisse anlegen#
# E: Create directories   #
###########################
${mkdir} -p /var/log/nextcloud /var/www/letsencrypt/.well-known/acme-challenge /etc/letsencrypt/rsa-certs /etc/letsencrypt/ecc-certs
${chmod} -R 775 /var/www/letsencrypt
${chmod} -R 770 /etc/letsencrypt
${chown} -R www-data:www-data /var/log/nextcloud /var/www/ /etc/letsencrypt
###########################
# D: Hinzufügen ACME-User #
# E: Create ACME-user     #
###########################
# ${adduser} --system --disabled-login acmeuser
${adduser} acmeuser --gecos "" --disabled-password
${usermod} -aG www-data acmeuser
${touch} /etc/sudoers.d/acmeuser
${cat} <<EOF >/etc/sudoers.d/acmeuser
acmeuser ALL=NOPASSWD: /bin/systemctl reload nginx.service
EOF
${su} - acmeuser -c "/usr/bin/curl https://get.acme.sh | sh"
${su} - acmeuser -c ".acme.sh/acme.sh --set-default-ca --server letsencrypt"
###########################
# Installation PHP        #
###########################
${clear}
${echo} "PHP-Installation"
${echo} ""
sleep 3
${apt} install -y php-common php$PHPVERSION-{fpm,gd,curl,xml,zip,intl,mbstring,bz2,ldap,apcu,bcmath,gmp,imagick,igbinary,redis,smbclient,sqlite3,cli,common,opcache,readline} imagemagick ldap-utils nfs-common cifs-utils --allow-change-held-packages
${apt} install -y libmagickcore-6.q16-6-extra --allow-change-held-packages
AvailableRAM=$(/usr/bin/awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
${cp} /etc/php/$PHPVERSION/fpm/pool.d/www.conf /etc/php/$PHPVERSION/fpm/pool.d/www.conf.bak
${cp} /etc/php/$PHPVERSION/fpm/php-fpm.conf /etc/php/$PHPVERSION/fpm/php-fpm.conf.bak
${cp} /etc/php/$PHPVERSION/cli/php.ini /etc/php/$PHPVERSION/cli/php.ini.bak
${cp} /etc/php/$PHPVERSION/fpm/php.ini /etc/php/$PHPVERSION/fpm/php.ini.bak
${cp} /etc/php/$PHPVERSION/mods-available/opcache.ini /etc/php/$PHPVERSION/mods-available/opcache.ini.bak
${cp} /etc/php/$PHPVERSION/mods-available/apcu.ini /etc/php/$PHPVERSION/mods-available/apcu.ini.bak
${cp} /etc/php/$PHPVERSION/fpm/php-fpm.conf /etc/php/$PHPVERSION/fpm/php-fpm.conf.bak
${cp} /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak
${sed} -i 's/pm = dynamic/pm = ondemand/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;env\[HOSTNAME\] = /env[HOSTNAME] = /' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;env\[TMP\] = /env[TMP] = /' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;env\[TMPDIR\] = /env[TMPDIR] = /' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;env\[TEMP\] = /env[TEMP] = /' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;env\[PATH\] = /env[PATH] = /' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
if [ "$AvailableRAM" -ge "4096" ];then 
${sed} -i 's/pm.max_children =.*/pm.max_children = 200/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.start_servers =.*/pm.start_servers = 100/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = 60/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = 140/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;pm.max_requests =.*/pm.max_requests = 1000/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
else
${sed} -i 's/pm.max_children =.*/pm.max_children = 100/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.start_servers =.*/pm.start_servers = 50/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = 30/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = 70/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
${sed} -i 's/;pm.max_requests =.*/pm.max_requests = 1000/' /etc/php/$PHPVERSION/fpm/pool.d/www.conf
fi
${sed} -i 's/output_buffering =.*/output_buffering = Off/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/max_execution_time =.*/max_execution_time = 3600/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/max_input_time =.*/max_input_time = 3600/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/post_max_size =.*/post_max_size = 10240M/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/upload_max_filesize =.*/upload_max_filesize = '$UPLOADSIZE'/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's|;date.timezone.*|date.timezone = '$CURRENTTIMEZONE'|' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/;cgi.fix_pathinfo.*/cgi.fix_pathinfo = 0/' /etc/php/$PHPVERSION/cli/php.ini
${sed} -i 's/memory_limit = 128M/memory_limit = 2G/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/output_buffering =.*/output_buffering = Off/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/max_execution_time =.*/max_execution_time = 3600/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/max_input_time =.*/max_input_time = 3600/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/post_max_size =.*/post_max_size = 10240M/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/upload_max_filesize =.*/upload_max_filesize = '$UPLOADSIZE'/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's|;date.timezone.*|date.timezone = '$CURRENTTIMEZONE'|' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;session.cookie_secure.*/session.cookie_secure = True/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.enable=.*/opcache.enable=1/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.enable_cli=.*/opcache.enable_cli=1/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=256/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=64/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=100000/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=1/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.save_comments=.*/opcache.save_comments=1/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;opcache.huge_code_pages=.*/opcache.huge_code_pages=0/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/allow_url_fopen =.*/allow_url_fopen = 1/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i 's/;cgi.fix_pathinfo.*/cgi.fix_pathinfo = 0/' /etc/php/$PHPVERSION/fpm/php.ini
${sed} -i '$aapc.enable_cli=1' /etc/php/$PHPVERSION/mods-available/apcu.ini
${sed} -i 's/opcache.jit=off/; opcache.jit=off/' /etc/php/"$PHPVERSION"/mods-available/opcache.ini
${sed} -i '$aopcache.jit=1255' /etc/php/"$PHPVERSION"/mods-available/opcache.ini
${sed} -i '$aopcache.jit_buffer_size=256M' /etc/php/$PHPVERSION/mods-available/opcache.ini
${sed} -i 's|;emergency_restart_threshold.*|emergency_restart_threshold = 10|g' /etc/php/$PHPVERSION/fpm/php-fpm.conf
${sed} -i 's|;emergency_restart_interval.*|emergency_restart_interval = 1m|g' /etc/php/$PHPVERSION/fpm/php-fpm.conf
${sed} -i 's|;process_control_timeout.*|process_control_timeout = 10|g' /etc/php/$PHPVERSION/fpm/php-fpm.conf
${sed} -i 's/rights=\"none\" pattern=\"PS\"/rights=\"read|write\" pattern=\"PS\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"EPS\"/rights=\"read|write\" pattern=\"EPS\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"PDF\"/rights=\"read|write\" pattern=\"PDF\"/' /etc/ImageMagick-6/policy.xml
${sed} -i 's/rights=\"none\" pattern=\"XPS\"/rights=\"read|write\" pattern=\"XPS\"/' /etc/ImageMagick-6/policy.xml
if [ ! -e "/usr/bin/gs" ]; then
${ln} -s /usr/local/bin/gs /usr/bin/gs
fi
###########################
# Neustart/Restart PHP    #
###########################
${systemctl} restart php$PHPVERSION-fpm
${systemctl} restart nginx
###########################
# Installation DB         #
###########################
${clear}
${echo} "DB-Installation"
${echo} ""
sleep 3
if [ $DATABASE == "m" ]
then
        ${apt} install -y php$PHPVERSION-mysql libdbd-mysql-perl libmariadb3 mariadb-common mysql-common mariadb-server mariadb-client --allow-change-held-packages
        ${cp} /etc/php/$PHPVERSION/fpm/conf.d/20-mysqli.ini /etc/php/$PHPVERSION/fpm/conf.d/20-mysqli.ini.bak
        ${cat} <<EOF >>/etc/php/$PHPVERSION/fpm/conf.d/20-mysqli.ini
[mysql]
mysql.allow_local_infile=On
mysql.allow_persistent=On
mysql.cache_size=2000
mysql.max_persistent=-1
mysql.max_links=-1
mysql.default_port=3306
mysql.connect_timeout=60
mysql.trace_mode=Off
EOF
        ${systemctl} stop mysql
        ${cp} /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
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
# performance_schema=ON
basedir = /usr
bind-address = 127.0.0.1
binlog_format = ROW
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
datadir = /var/lib/mysql
default_storage_engine = InnoDB
expire_logs_days = 2
general_log_file = /var/log/mysql/mysql.log
innodb_buffer_pool_size = 2G
innodb_log_buffer_size = 32M
innodb_log_file_size = 512M
innodb_read_only_compressed=OFF
join_buffer_size = 2M
key_buffer_size = 512M
lc_messages_dir = /usr/share/mysql
lc_messages = en_US
log_bin = /var/log/mysql/mariadb-bin
log_bin_index = /var/log/mysql/mariadb-bin.index
log_bin_trust_function_creators = true
log_error = /var/log/mysql/mysql_error.log
log_slow_verbosity = query_plan
log_warnings = 2
long_query_time = 1
max_connections = 100
max_heap_table_size = 64M
max_allowed_packet = 512M
myisam_sort_buffer_size = 512M
port = 3306
pid-file = /var/run/mysqld/mysqld.pid
query_cache_limit = 0
query_cache_size = 0 
read_buffer_size = 2M
read_rnd_buffer_size = 2M
skip-name-resolve
socket = /var/run/mysqld/mysqld.sock
sort_buffer_size = 2M
table_open_cache = 400
table_definition_cache = 800
tmp_table_size = 32M
tmpdir = /tmp
transaction_isolation = READ-COMMITTED
user = mysql
wait_timeout = 600
[mariadb-dump]
max_allowed_packet = 512M
quick
quote-names
[isamchk]
key_buffer = 16M
EOF
${systemctl} restart mysql
mysql=$(command -v mariadb)
${mysql} -e "CREATE DATABASE ${NCDBNAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
${mysql} -e "CREATE USER ${NCDBUSER}@localhost IDENTIFIED BY '${NCDBPASSWORD}';"
${mysql} -e "CREATE USER ${NCDBUSER}@127.0.0.1 IDENTIFIED BY '${NCDBPASSWORD}';"
${mysql} -e "GRANT ALL PRIVILEGES ON ${NCDBNAME}.* TO '${NCDBUSER}'@'localhost';"
${mysql} -e "GRANT ALL PRIVILEGES ON ${NCDBNAME}.* TO '${NCDBUSER}'@'127.0.0.1';"
${mysql} -e "FLUSH PRIVILEGES;"
mysql_secure_installation=$(command -v mariadb-secure-installation)
cat <<EOF | ${mysql_secure_installation}
\n
n
y
y
y
y
EOF
        mariadb -u root -e "SET PASSWORD FOR root@'localhost' = PASSWORD('$MARIADBROOTPASSWORD'); FLUSH PRIVILEGES;"
else
${apt} install -y php$PHPVERSION-pgsql postgresql-15 --allow-change-held-packages
sudo -u postgres psql -c "CREATE USER ${NCDBUSER} WITH PASSWORD '${NCDBPASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE ${NCDBNAME} TEMPLATE template0 ENCODING 'UNICODE';"
sudo -u postgres psql -c "ALTER DATABASE ${NCDBNAME} OWNER TO ${NCDBUSER};"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${NCDBNAME} TO ${NCDBUSER};"
${systemctl} restart postgresql
cat <<EOF >>/etc/php/$PHPVERSION/fpm/conf.d/20-pgsql.ini
[PostgresSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
EOF
${systemctl} restart postgresql
fi
###########################
# Installation Redis      #
###########################
${clear}
${echo} "REDIS-Installation"
${echo} ""
sleep 1
${apt} install -y redis-server --allow-change-held-packages
${cp} /etc/redis/redis.conf /etc/redis/redis.conf.bak
${sed} -i 's/port 6379/port 0/' /etc/redis/redis.conf
${sed} -i s/\#\ unixsocket/\unixsocket/g /etc/redis/redis.conf
${sed} -i 's/unixsocketperm 700/unixsocketperm 770/' /etc/redis/redis.conf
${sed} -i "s/# requirepass foobared/requirepass $REDISPASSWORD/" /etc/redis/redis.conf
${sed} -i 's/# maxclients 10000/maxclients 10240/' /etc/redis/redis.conf
${cp} /etc/sysctl.conf /etc/sysctl.conf.bak
${sed} -i '$avm.overcommit_memory = 1' /etc/sysctl.conf
${usermod} -a -G redis www-data
###########################
# Self-Signed-SSL         #
###########################
${apt} install -y ssl-cert
###########################
# NGINX TLS               #
###########################
[ -f /etc/nginx/conf.d/default.conf ] && ${mv} /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
${touch} /etc/nginx/conf.d/default.conf
${touch} /etc/nginx/conf.d/http.conf
${cat} <<EOF >/etc/nginx/conf.d/http.conf
upstream php-handler {
  server unix:/run/php/php$PHPVERSION-fpm.sock;
  }
map \$arg_v \$asset_immutable {
    "" "";
    default "immutable";
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
${cat} <<EOF >/etc/nginx/conf.d/nextcloud.conf
limit_req_zone \$binary_remote_addr zone=NextcloudRateLimit:10m rate=2r/s;
server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;
  http2 on;
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
  client_body_buffer_size 512k;
  fastcgi_buffers 64 4K;
  gzip on;
  gzip_vary on;
  gzip_comp_level 4;
  gzip_min_length 256;
  gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
  gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
  add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;
  add_header Permissions-Policy "interest-cohort=()";
  add_header Referrer-Policy "no-referrer" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Download-Options "noopen" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Permitted-Cross-Domain-Policies "none" always;
  add_header X-Robots-Tag "noindex, nofollow" always;
  add_header X-XSS-Protection "1; mode=block" always;
  fastcgi_hide_header X-Powered-By;
  include mime.types;
  types {
  text/javascript mjs;
	  }
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
    rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode\/proxy) /index.php\$request_uri;
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
    fastcgi_max_temp_file_size 0;
    }
  location ~ \.(?:css|js|mjs|svg|gif|png|jpg|ico|wasm|tflite|map|ogg|flac)\$ {
    try_files \$uri /index.php\$request_uri;
    add_header Cache-Control "public, max-age=15778463, \$asset_immutable";
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
  location /login {
    limit_req zone=NextcloudRateLimit burst=5 nodelay;
    limit_req_status 429;
    try_files \$uri \$uri/ /index.php\$request_uri;
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
sleep 1
###########################
# Hostname                #
###########################
${sed} -i "s/server_name cloud.server.io;/server_name $(hostname) $NEXTCLOUDDNS;/" /etc/nginx/conf.d/http.conf
${sed} -i "s/server_name cloud.server.io;/server_name $(hostname) $NEXTCLOUDDNS;/" /etc/nginx/conf.d/nextcloud.conf
###########################
# Nextcloud-CRON          #
###########################
(/usr/bin/crontab -u www-data -l ; echo "*/5 * * * * /usr/bin/php -f /var/www/nextcloud/cron.php > /dev/null 2>&1") | /usr/bin/crontab -u www-data -
###########################
# Neustart/Restart NGINX  #
###########################
${systemctl} restart nginx
${clear}
###########################
# Herunterladen/Download  #
# Nextcloud               #
###########################
${echo} "Downloading:" $NCRELEASE
${wget} -q https://download.nextcloud.com/server/releases/$NCRELEASE & CrI
#${wget} -q https://download.nextcloud.com/server/releases/$NCRELEASE.md5
${echo} ""
#${echo} "Verify Checksum (MD5):"
#if [ "$(md5sum -c $NCRELEASE.md5 < $NCRELEASE | awk '{ print $2 }')" = "OK" ]
#then
#md5sum -c $NCRELEASE.md5 < $NCRELEASE
#${echo} ""
#else
#${clear}
#${echo} ""
#${echo} "CHECKSUM ERROR => SECURITY ALERT => ABBRUCH!"
#exit 1
#fi
${echo} "Extracting:" $NCRELEASE
${apt} install -y bzip2
${tar} -xjf $NCRELEASE -C /var/www & CrI
${chown} -R www-data:www-data /var/www/
${rm} -f $NCRELEASE $NCRELEASE.md5
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
${echo} "Die Nextcloud wird jetzt 'silent' installiert - bitte haben Sie Geduld!"
${echo} "Your Nextcloud will now be installed silently - please be patient!"
${echo} ""
if [ $DATABASE == "m" ]
then
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "${NCDBNAME}" --database-user "${NCDBUSER}" --database-pass "${NCDBPASSWORD}" --admin-user "${NEXTCLOUDADMINUSER}" --admin-pass "${NEXTCLOUDADMINUSERPASSWORD}" --data-dir "${NEXTCLOUDDATAPATH}"
else
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "pgsql" --database-name "${NCDBNAME}" --database-user "${NCDBUSER}" --database-pass "${NCDBPASSWORD}" --admin-user "${NEXTCLOUDADMINUSER}" --admin-pass "${NEXTCLOUDADMINUSERPASSWORD}" --data-dir "${NEXTCLOUDDATAPATH}"
fi
${echo} ""
sleep 2
declare -l YOURSERVERNAME
YOURSERVERNAME=$(hostname)
###########################
# Optimieren/Optimizing   #
# Nextcloud config.php    #
###########################
${sudo} -u www-data ${cp} /var/www/nextcloud/config/config.php /var/www/nextcloud/config/config.php.bak
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 0 --value="$YOURSERVERNAME"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 1 --value="$NEXTCLOUDDNS"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set trusted_domains 2 --value="$IPA"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set overwrite.cli.url --value=https://"$NEXTCLOUDDNS"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:system:set overwritehost --value="$NEXTCLOUDDNS"
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
  'forbidden_filenames' =>
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
      10 => 'OC\\Preview\\HEIC',
      11 => 'OC\\Preview\\Movie',
      12 => 'OC\\Preview\\MKV',
      13 => 'OC\\Preview\\MP4',
      14 => 'OC\\Preview\\AVI',
      ),
      'filesystem_check_changes' => 0,
      'filelocking.enabled' => 'true',
      'htaccess.RewriteBase' => '/',
      'integrity.check.disabled' => false,
      'knowledgebaseenabled' => false,
      'log_rotate_size' => '104857600',
      'logfile' => '/var/log/nextcloud/$NEXTCLOUDDNS.log',
      'loglevel' => 2,
      'logtimezone' => '$CURRENTTIMEZONE',
      'memcache.local' => '\\\\OC\\\\Memcache\\\\APCu',
      'memcache.locking' => '\\\\OC\\\\Memcache\\\\Redis',
      'overwriteprotocol' => 'https',
      'preview_max_x' => 1024,
      'preview_max_y' => 768,
      'preview_max_scale_factor' => 1,
      'profile.enabled' => false,
      'redis' =>
      array (
        'host' => '/var/run/redis/redis-server.sock',
        'port' => 0,
        'password' => '$REDISPASSWORD',
        'timeout' => 0.5,
        'dbindex' => 1,
        ),
        'quota_include_external_storage' => false,
        'share_folder' => '/Freigaben',
        'skeletondirectory' => '',
        'trashbin_retention_obligation' => 'auto, 7',
        'maintenance_window_start' => 1,
        );
EOF
${sed} -i 's/^[ ]*//' /var/www/nextcloud/config/config.php
###########################
# Nextcloud Berechtigungen#
# Nextcloud Permissions   #
###########################
${chown} -R www-data:www-data /var/www
###########################
# Neustart/Restart        #
###########################
restart_all_services
###########################
# Installation crowdsec   #
###########################
${clear}
echo ""
${echo} " » Crowdsec-Installation"
${echo} ""
sleep 2
${curl} -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
if [ "$(lsb_release -r | awk '{ print $2 }')" = "24.04" ]
then
sed -i 's/noble/jammy/' /etc/apt/sources.list.d/crowdsec_crowdsec.list
fi
${apt} update
${apt} install -y crowdsec
${apt} install -y crowdsec-firewall-bouncer-nftables
${systemctl} reload crowdsec.service crowdsec-firewall-bouncer.service
${systemctl} enable crowdsec.service crowdsec-firewall-bouncer.service
${systemctl} restart crowdsec.service crowdsec-firewall-bouncer.service
cscli collections install crowdsecurity/nextcloud
cscli collections install crowdsecurity/nginx
cscli collections install crowdsecurity/sshd
cscli parsers install crowdsecurity/geoip-enrich
${systemctl} reload crowdsec.service crowdsec-firewall-bouncer.service
${systemctl} restart crowdsec.service crowdsec-firewall-bouncer.service
${cp} /etc/crowdsec/acquis.yaml /etc/crowdsec/acquis.yaml.bak
${cat} <<EOF >>/etc/crowdsec/acquis.yaml
#Nextcloud by c-rieger.de
filenames:
 - /var/log/nextcloud/$NEXTCLOUDDNS.log
labels:
  type: Nextcloud
---
EOF
${systemctl} reload crowdsec.service crowdsec-firewall-bouncer.service
${systemctl} restart crowdsec.service crowdsec-firewall-bouncer.service
###########################
# Installation ufw        #
###########################
${clear}
${echo} "ufw-Installation"
${echo} ""
sleep 3
${apt} install -y ufw --allow-change-held-packages
ufw=$(command -v ufw)
${ufw} allow 80/tcp comment "LetsEncrypt(http)"
${ufw} allow 443/tcp comment "TLS(https)"
SSHPORT=$(grep -w Port /etc/ssh/sshd_config | awk '/Port/ {print $2}')
${ufw} allow "$SSHPORT"/tcp comment "SSH"
${ufw} logging medium && ${ufw} default deny incoming
${cat} <<EOF | ${ufw} enable
y
EOF
${systemctl} restart redis-server ufw$
###########################
# D: Nextcloud Anpassungen#
# E: Nextcloud customizing#
###########################
${clear}
${echo} "Nextcloud-Anpassungen/-Customizing"
${echo} ""
sleep 3
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable survey_client
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable firstrunwizard
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable federation
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable support
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:disable logreader
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:app:set settings profile_enabled_by_default --value="0"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable admin_audit
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable files_pdfviewer
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable contacts
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable calendar
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:enable groupfolders
if [ $NEXTCLOUDOFFICE == "y" ]
then
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:install richdocuments
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:install richdocumentscode
fi
if [ $ONLYOFFICE == "y" ]
then
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:install documentserver_community
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ app:install onlyoffice
fi
rediscli=$(command -v redis-cli)
${rediscli} -s /var/run/redis/redis-server.sock <<EOF
FLUSHALL
quit
EOF
${systemctl} stop nginx
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-primary-keys
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-indices
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:add-missing-columns
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ db:convert-filecache-bigint
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ security:certificates:import /etc/ssl/certs/ssl-cert-snakeoil.pem
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ config:app:set settings profile_enabled_by_default --value="0"
${sudo} -u www-data /usr/bin/php /var/www/nextcloud/occ maintenance:repair --include-expensive
${clear}
nextcloud_scan_data
${systemctl} restart nginx
${echo} ""
${echo} "Systemoptimierungen / System optimizations"
${echo} ""
${echo} "Dieser Vorgang kann mehrere Minuten dauern - bitte haben Sie Geduld!"
${echo} "It will take a few minutes - please be patient!"
${echo} ""
${sudo} -u www-data /usr/bin/php -f /var/www/nextcloud/cron.php & CrI
###########################
# Sperren/Hold Software   #
###########################
setHOLD
###########################
# D: LE-Zertifikate       #
# E: LE certificates      #
###########################
if [ $LETSENCRYPT == "y" ]
then
${sudo} -i -u acmeuser bash << EOF
/home/acmeuser/.acme.sh/acme.sh --issue -d "${NEXTCLOUDDNS}" --server letsencrypt --keylength 4096 -w /var/www/letsencrypt --key-file /etc/letsencrypt/rsa-certs/privkey.pem --ca-file /etc/letsencrypt/rsa-certs/chain.pem --cert-file /etc/letsencrypt/rsa-certs/cert.pem --fullchain-file /etc/letsencrypt/rsa-certs/fullchain.pem --reloadcmd "sudo /bin/systemctl reload nginx.service"
EOF
${sudo} -i -u acmeuser bash << EOF
/home/acmeuser/.acme.sh/acme.sh --issue -d "${NEXTCLOUDDNS}" --server letsencrypt --keylength ec-384 -w /var/www/letsencrypt --key-file /etc/letsencrypt/ecc-certs/privkey.pem --ca-file /etc/letsencrypt/ecc-certs/chain.pem --cert-file /etc/letsencrypt/ecc-certs/cert.pem --fullchain-file /etc/letsencrypt/ecc-certs/fullchain.pem --reloadcmd "sudo /bin/systemctl reload nginx.service"
EOF
${sed} -i '/ssl-cert-snakeoil/d' /etc/nginx/conf.d/nextcloud.conf
${sed} -i s/#\ssl/\ssl/g /etc/nginx/conf.d/nextcloud.conf
${systemctl} restart nginx
fi
###########################
# System information-just #
# for logging purposes    #
###########################
${echo} ""
${echo} "$CURRENTTIMEZONE"
${echo} ""
${date}
${echo} ""
$lsbrelease -ar
###########################
# D: Update-Skript anlegen#
# E: Create Update-Script #
###########################
cd /home/"$BENUTZERNAME"/
${wget} -q https://codeberg.org/criegerde/nextcloud/raw/branch/master/skripte/update.sh
${chmod} +x /home/"$BENUTZERNAME"/update.sh
###########################
# D: Abschlußbildschirm   #
# E: Final screen         #
###########################
${clear}
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${echo} "Server - IP(v4):"
${echo} "----------------"
${echo} "$IPA"
${echo} ""
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${echo} "Nextcloud:"
${echo} ""
${echo} "https://$NEXTCLOUDDNS oder/or https://$IPA"
${echo} ""
${echo} "*******************************************************************************"
${echo} ""
${echo} "Nextcloud User/Pwd: $NEXTCLOUDADMINUSER // $NEXTCLOUDADMINUSERPASSWORD"
${echo} ""
${echo} "Passwordreset     : sudo -s"
${echo} "                    source /root/.bash_aliases"
${echo} "                    nocc user:resetpassword $NEXTCLOUDADMINUSER"
${echo} ""
${echo} "Nextcloud datapath: $NEXTCLOUDDATAPATH"
${echo} ""
${echo} "Nextcloud DB      : $NCDBNAME"
${echo} "Nextcloud DB-User : $NCDBUSER / $NCDBPASSWORD"
if [ $DATABASE == "m" ]
then
${echo} ""
${echo} "MariaDB-Rootpwd   : $MARIADBROOTPASSWORD"
fi
${echo} ""
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
${cat} /etc/motd
###########################
# Nextcloud-Log           #
###########################
${rm} -f /var/log/nextcloud/$NEXTCLOUDDNS.log
${sudo} -u www-data ${touch} /var/log/nextcloud/$NEXTCLOUDDNS.log
###########################
# occ Aliases (nocc)      #
###########################
if [ ! -f /root/.bash_aliases ]; then touch /root/.bash_aliases; fi
cat <<EOF >> /root/.bash_aliases
alias nocc="sudo -u www-data php /var/www/nextcloud/occ"
EOF
###########################
# Bereinigung/Clean Up    #
###########################
${cat} /dev/null > ~/.bash_history && history -c && history -w
###########################
# Laufzeit Berechnung     #
# Calculating runtime     #
###########################
${echo} ""
end=$(date +%s)
runtime=$((end-start))
echo ""
if [ "$runtime" -lt 60 ] || [ $runtime -ge "120" ]; then
echo "Installation process completed in $((runtime/60)) minutes and $((runtime%60)) seconds."
else
echo "Installation process completed in $((runtime/60)) minute and $((runtime%60)) seconds."
echo ""
fi
${echo} "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
${echo} ""
exit 0
