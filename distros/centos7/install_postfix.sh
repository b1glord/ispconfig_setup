#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  echo -n "Disabling Sendmail... "
  systemctl stop sendmail.service
  systemctl disable sendmail.service
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Installing SMTP Mail server (Postfix)... "
  yum_install postfix ntp getmail
  #Fix for mailman virtualtable - need also without mailman
  mkdir /etc/mailman/
  touch /etc/mailman/virtual-mailman
  postmap /etc/mailman/virtual-mailman
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
sed -i "s/    #user =/    user = postfix/" /etc/dovecot/conf.d/10-master.conf
sed -i "s/    #group =/    group = postfix/" /etc/dovecot/conf.d/10-master.conf
fi
    elif [ "$CFG_WEBSERVER" == "nginx" ]; then
  	CFG_NGINX=y
	  CFG_APACHE=n
sed -i "s/    #user =/    user = postfix/" /etc/dovecot/conf.d/10-master.conf
sed -i "s/    #group =/    group = postfix/" /etc/dovecot/conf.d/10-master.conf
fi

  systemctl enable postfix.service
  systemctl restart postfix.service
  echo -e "[${green}DONE${NC}]\n"
}
