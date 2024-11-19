#!/bin/bash
##########################################################################################
# CROWDSEC INSTALLATION
##########################################################################################
# Debian 12 / Ubuntu 22.04+ LTS x86_64
# Carsten Rieger IT-Services (https://www.c-rieger.de)
##########################################################################################
clear
if [ "$USER" != "root" ]
then
    echo ""
    echo " » KEINE ROOT-BERECHTIGUNGEN | NO ROOT PERMISSIONS"
    echo ""
    echo "----------------------------------------------------------"
    echo " » Bitte starten Sie das Skript als root: 'sudo ./ips.sh'"
    echo " » Please run this script as root using:  'sudo ./ips.sh'"
    echo "----------------------------------------------------------"
    echo ""
    exit 1
fi
echo ""
echo " » fail2ban wird entfernt  // remove fail2ban"
echo ""
sleep 2
systemctl stop fail2ban.service
systemctl disable fail2ban.service
systemctl mask fail2ban.service
apt remove fail2ban --purge -y
clear
echo ""
echo " » fail2ban entfernt // removed           [OK]"
echo " » Crowdsec wird heruntergeladen+installiert // crowdsec will be downloaded+installed"
echo ""
sleep 2
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
if [ "$(lsb_release -r | awk '{ print $2 }')" = "24.04" ]
then
sed -i 's/noble/jammy/' /etc/apt/sources.list.d/crowdsec_crowdsec.list
fi
apt update
apt install crowdsec -y
apt install crowdsec-firewall-bouncer-nftables -y
systemctl enable --now crowdsec.service
cscli collections install crowdsecurity/nextcloud
cscli collections install crowdsecurity/nginx
cscli collections install crowdsecurity/sshd
systemctl reload crowdsec && systemctl restart crowdsec
cp /etc/crowdsec/acquis.yaml /etc/crowdsec/acquis.yaml.bak
cat <<EOF >>/etc/crowdsec/acquis.yaml
#Nextcloud by c-rieger.de
filenames:
 - /var/log/nextcloud/nextcloud.log
labels:
  type: Nextcloud
---
EOF
systemctl reload crowdsec && systemctl restart crowdsec.service crowdsec-firewall-bouncer.service
clear
echo ""
echo " » fail2ban entfernt // removed           [OK]"
echo " » crowdsec installiert // installed      [OK]"
echo " » Carsten Rieger IT-Services, https://www.c-rieger.de"
echo ""
exit 0
