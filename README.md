# Nextcloud Installationsskript // Nextcloud Installation script
D: Installieren Sie Ihren eigenen Nextcloud-Server in weniger als 10 Minuten.<br>
E: Install your own Nextcloud server in less than 10 minutes.

* Ubuntu 20.04 LTS / 22.04 LTS x86_64
* NGINX 1.2x from PPA
* PHP 8.x from PPA
* Auswahl / Option: MariaDB // postgreSQL
* Auswahl / Option: Self-signed // Let's Encrypt certificates
* Auswahl / Option: Nextcloud Release
* etc...

<h2>INSTALLATION:</h2>
<h3>D/E: Vorbereitungen/Preparations:</h3>
<code>sudo -s</code><br>
<code>git clone ssh://git@github.com/gitusername/nextcloud-zero.git</code><br>
<code>cp nextcloud-zero/zero.sh .</code><br>
<code>chmod +x zero.sh*.sh</code><br> <br>
<h3>D/E: Konfigurationsvariablen anpassen / modify configuration variables:</h3></code>
<code>nano zero.sh</code><br> <br>
<code>NEXTCLOUDDATAPATH="/data"</code><br>
<code>NEXTCLOUDADMINUSER="nc_admin"</code><br>
<code># e.g. NEXTCLOUDADMINUSERPASSWORD="Nc-AdMi!n65#" or it wil be gerated by the script</code><br>
<code>NEXTCLOUDADMINUSERPASSWORD=$(openssl rand -hex 16)</code><br>
<code># Nextcloud Release (https://nextcloud.com/changelog/)</code><br>
<code># e.g. NCRELEASE="nextcloud-23.0.4.tar.bz2" or choose the latest/current release</code><br>
<code>NCRELEASE="latest.tar.bz2"</code><br>
<code>NEXTCLOUDDNS="ihre.domain.de"</code><br>
<code># Let'sEncrypt-SSL/TLS: [y|n]</code><br>
<code>LETSENCRYPT="n"</code><br>
<code># NEXTCLOUDEXTIP="123.124.125.120" or read from the system</code><br>
<code>NEXTCLOUDEXTIP=$(dig +short txt ch whoami.cloudflare @1.0.0.1)</code><br>
<code># e.g. MARIADBROOTPASSWORD="MaRiAdB-RooT-PwD" or it wil be gerated by the script</code><br>
<code>MARIADBROOTPASSWORD=$(openssl rand -hex 16)</code><br>
<code># MariaDB "m" or postgreSQL "p"</code><br>
<code>DATABASE="m"</code><br>
<code>NCDBUSER="ncdbuser"</code><br>
<code># e.g. NCDBPASSWORD="YouR#P@ssworT" or it wil be gerated by the script</code><br>
<code>NCDBPASSWORD=$(openssl rand -hex 16)</code><br>
<code>CURRENTTIMEZONE='Europe/Berlin'</code><br>
<code>PHONEREGION='DE'</code><br>
<h3>Installation:</h3>
<code>./zero.sh</code>
<h2>D/E: DEINSTALLATION/UNINSTALL:</h2>
D. Sofern Sie das Skript erneut ausführen möchten, so führen Sie bitte zuerst die Deinstallation durch:<br>
E: If you want to re-install your server - please uninstall your software first.<br> <br>
<code>/home/*benutzer*/Nextcloud-Installationsskript/uninstall.sh</code><br>
<code>rm -f /home/*benutzer*/Nextcloud-Installationsskript/uninstall.sh</code><br> <br>
D: Dabei werden alle Softwarepakete (inkl. DB) sowie alle Verzeichnisse und Daten aus der vorherigen Installation entfernt. Im Anschluss daran kann die Installation erneut durchgeführt werden.<br>
E: All data, databases and software from the previous installation will be removed. Afterwards you can re-run the installation script.<br>
<h2>D/E: ERNEUTE INSTALLATION/RE-INSTALLATION:</h2>
<code>./zero.sh</code><br>
<h2>D/E: LOGDATEI/LOGFILE:</h2>
<code>nano /home/*benutzer*/Nextcloud-Installationsskript/install.log</code><br>

-----------------------------------------------------------------------------------

D: Weitere Optimierungs-, Härtungs- und Erweiterungsmöglichkeiten finden Sie hier:<br>
E: Further hardening, optimization and enhancement information can be found here:<br>
https://www.c-rieger.de/nextcloud24-installationsanleitung/<br>
Carsten Rieger IT-Services
