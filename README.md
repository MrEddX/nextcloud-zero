# Neues Nextcloud Auto-Installerskript // New Nextcloud Installation script
D: Installieren Sie Ihren eigenen Nextcloud-Server in weniger als 10 Minuten.<br>
E: Install your own Nextcloud server in less than 10 minutes.

<h2>Bis zur Fertigstellung: PRIVATE ONLY</h2>
<h2>Basis f. Ubuntu 22 u. Nextcloud 24</h2>
<h2>nach Finalisierung -> PUBLIC</h2>

* Ubuntu 22.x (aktuell stehen noch nicht die aktuellen Repositories zur Verfügung!)
* PHP (8.0) und NGINX (1.20.2) derzeit auf PPA umgestellt
* MariaDB 10.6/postgreSQL 14 direkt von Ubuntu 22

<h2>INSTALLATION:</h2>

<h3>Vorbereitung:</h3>
<code>sudo -s</code><br>
<code>git clone ssh://git@github.com/gitusername/nextcloud-zero.git --config core.sshCommand="ssh -i privateKey"</code>

<h3>Skriptauswahl und Vorbereitung:</h3>

* zero.sh (Auswahl MariaDB o. PostgreSQL)

<code>cp nextcloud-zero/zero.sh .</code><br>

<code>chmod +x zero.sh*.sh</code><br>

<h3>Installation:</h3>
<code>./zero.sh</code><br>

<h2>DEINSTALLATION:</h2>
Sofern Sie das Skript erneut ausführen möchten, so führen Sie bitte zuerst die Deinstallation durch:<br>
<code>/home/*benutzer*/Nextcloud-Installationsskript/uninstall.sh</code><br>
<code>rm -f /home/*benutzer*/Nextcloud-Installationsskript/uninstall.sh</code><br>

Dabei werden alle Softwarepakete (inkl. DB) sowie alle Verzeichnisse und Daten aus der vorherigen Installation entfernt.
Im Anschluss daran kann die Installation erneut durchgeführt werden.
 
<h2>ERNEUTE INSTALLATION:</h2>
<code>./zero.sh</code><br>

<h2>LOGDATEI:</h2>
<code>nano /home/*benutzer*/Nextcloud-Installationsskript/install.log</code><br>

-----------------------------------------------------------------------------------

Weitere Optimierungs-, Härtungs- und Erweiterungsmöglichkeiten werden unter
https://www.c-rieger.de/nextcloud-installationsanleitung/
beschrieben. Viel Spaß.

Carsten Rieger IT-Services
