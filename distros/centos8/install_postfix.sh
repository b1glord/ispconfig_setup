#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  echo -n "Installing SMTP Mail server (Postfix)... "
  dnf -y install postfix

  systemctl enable postfix
  systemctl start postfix
  systemctl restart postfix
  echo -e "[${green}DONE${NC}]\n"
}
