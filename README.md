# Neues Nextcloud Auto-Installerskript
Installieren Sie Ihren eigenen Nextcloud-Server in weniger als 10 Minuten.

<h2>Bis zur Fertigstellung PRIVAT ONLY</h2>
<h2>Basis f. Ubuntu 22 u. Nextcloud 24</h2>

* Ubuntu 22.x (aktuell stehen noch nicht alle Repositories zur Verfügungung!)

<h2>INSTALLATION:</h2>

<h3>Vorbereitung:</h3>
<code>sudo -s</code><br>
<code>git clone ssh://git@github.com/gitusername/nextcloud-zero.git --config core.sshCommand="ssh -i privateKey"</code>

<h3>Skriptauswahl und Vorbereitung:</h3>

* zero.sh (Auswahl MariaDB o. PostgreSQL)

<code>cp auto-installer/zero.sh .</code><br>

<code>chmod +x zero.sh*.sh</code><br>

<h3>Installation:</h3>
<code>./zero.sh</code><br>

<h2>DEINSTALLATION:</h2>
Sofern Sie das Skript erneut ausführen möchten, so führen Sie bitte zuerst die Deinstallation durch:
<code>./uninstall.sh</code><br>
<code>rm -f uninstall.sh</code><br>

Dabei werden alle Softwarepakete (inkl. DB) sowie alle Verzeichnisse und Daten aus der vorherigen Installation entfernt.
Im Anschluss daran kann die Installation erneut durchgeführt werden.
 
<h2>ERNEUTE INSTALLATION:</h2>
<code>./zero.sh</code><br>

<h2>LOGDATEI:</h2>
<code>nano /home/*benutzer*/install.log</code><br>

-----------------------------------------------------------------------------------

Weitere Optimierungs-, Härtungs- und Erweiterungsmöglichkeiten werden unter
https://www.c-rieger.de/nextcloud-installationsanleitung/
beschrieben. Viel Spaß.

Carsten Rieger IT-Services
