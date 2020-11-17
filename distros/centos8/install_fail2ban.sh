#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing Intrusion protection (Fail2Ban) and Rootkit detection (rkhunter)... "
	dnf_install fail2ban rkhunter fail2ban-systemd iptables-services

  systemctl stop firewalld.service
  systemctl mask firewalld.service
  systemctl disable firewalld.service
  systemctl stop firewalld.service
  systemctl enable fail2ban.service
  systemctl start fail2ban.service
 
  echo -e "[${green}DONE${NC}]\n"
}

