InstallHHVM() {
if [ $CFG_HHVM = "yes" ]; then
dnf -y install fping

 echo -e "[${green}DONE${NC}]\n"
 fi
}