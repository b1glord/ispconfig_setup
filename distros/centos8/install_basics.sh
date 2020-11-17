#---------------------------------------------------------------------
# Function: InstallBasics Centos 8
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating yum package database and upgrading currently installed packages... "
	dnf_install epel-release
	dnf_update 
  echo -e "[${green}DONE${NC}]\n"

  echo -n "Installing basic packages... "
	dnf_install nano net-tools NetworkManager-tui selinux-policy which unzip bzip2 perl-DBD-mysql which
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Disabling Firewall... "
  systemctl stop firewalld.service
  systemctl disable firewalld.service
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Installing Development Tools... "
  dnf_groupinstall 'Development Tools'  
  echo -e "[${green}DONE${NC}]\n"
}

