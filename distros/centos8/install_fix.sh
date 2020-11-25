#---------------------------------------------------------------------
# Function: InstallFix Centos 8
#	Ask for all needed user input
#---------------------------------------------------------------------
InstallFix(){
  if [ "$CFG_WEBMAIL" == "roundcube" ]; then
  	echo "Installing Roundcube fix... "
wget -nc https://gist.github.com/rcubetrac/cc85589b837d58680a86e7b5cbb09a4f/raw/6a04577ae65c9a035404ea46f5861c939558c248/centos_rhel_install.sh%25E2%2580%258B -P /tmp
chmod 755 /tmp/centos_rhel_install.sh​
/tmp/centos_rhel_install.sh​
	echo -e "[${green}DONE${NC}]\n"
  fi
  if [ $CFG_DKIM == "n" ]; then
	dnf_install opendkim

	fi
	echo -e "[${green}DONE${NC}]\n"
  fi  
}
