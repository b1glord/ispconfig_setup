#---------------------------------------------------------------------
# Function: InstallMailman
#    Install the Mailman list manager
#---------------------------------------------------------------------
InstallMailman() {
  echo -n "Installing Mailman... ";
	dnf -y install mailman
	
#Fix for mailman virtualtable - need also without mailman
	mkdir /etc/mailman/
	touch /etc/mailman/virtual-mailman
	postmap /etc/mailman/virtual-mailman
 
	systemctl restart postfix
	systemctl enable mailman
	systemctl start mailman
	echo -e "[${green}DONE${NC}]\n"
}
