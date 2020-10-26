#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
	echo -n "Installing Quota... "
	dnf -y install quota
	echo -e "[${green}DONE${NC}]\n"

	if ! [ -f /proc/user_beancounters ]; then
		echo -n "Initializing Quota, this may take awhile... "
		if [ "$(grep -c ',uquota,gquota' /etc/fstab)" -eq 0 ]; then
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/errors=remount-ro/errors=remount-ro,uquota,gquota/}' /etc/fstab
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/defaults/defaults,uquota,gquota/}' /etc/fstab
		fi
		mount -o remount /
		quotacheck -avugm
		quotaon -avug
		echo -e "[${green}DONE${NC}]\n"
	fi
}
