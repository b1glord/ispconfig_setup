#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Antivirus utilities (Amavisd-new, ClamAV), Spam filtering (SpamAssassin) and Greylisting (Postgrey)... "
	dnf_install clamav clamav-update
	dnf_install spamassassin postgrey
# Configure Clamd
	sed -i "s/#Example/Example/" /etc/clamd.d/scan.conf
	sed -i "s%#LogFile /var/log/clamd.scan%LogFile /var/log/clamd.scan%" /etc/clamd.d/scan.conf
	sed -i "s%#PidFile /run/clamd.scan/clamd.pid%PidFile /run/clamd.scan/clamd.pid%" /etc/clamd.d/scan.conf
	sed -i "s%#LocalSocket /run/clamd.scan/clamd.sock%LocalSocket /run/clamd.scan/clamd.sock%" /etc/clamd.d/scan.conf
	touch /var/log/clamd.scan
	chown clamscan /var/log/clamd.scan
# Configure Amavisd
#	sed -i "s%$mydomain = 'example.com';%$mydomain = 'srv.world';%" /etc/clamd.d/scan.conf
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Updating Freshclam Antivirus Database. Please Wait... "
  	freshclam 
	systemctl enable --now clamd@scan
	systemctl enable --now amavisd
	systemctl enable --now postgrey
  echo -e "[${green}DONE${NC}]\n"
}
