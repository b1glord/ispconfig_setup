InstallHHVM() {
if [ $CFG_HHVM = "yes" ]; then
    echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
    dnf -y update
 echo -e "[${green}DONE${NC}]\n"
 fi
}
