#---------------------------------------------------------------------
# Function: InstallBind Centos 8
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing DNS server (Bind)... ";
    dnf_install bind bind-utils 

 #echo -n "Installing haveged... ";
 #https://github.com/jirka-h/haveged
    dnf_install haveged
    
    systemctl enable named
    systemctl start named
    systemctl enable haveged
    systemctl start haveged

  echo -e "[${green}DONE${NC}]\n"
}
