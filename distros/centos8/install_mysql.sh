#---------------------------------------------------------------------
# Function: InstallMysql
#    Install and configure mysql
#---------------------------------------------------------------------
InstallSQLServer() {
  echo -n "Installing Database server (MariaDB)... "
  curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.4"
  dnf_update
  dnf_install mariadb-server expect
  systemctl enable mariadb.service
  systemctl start mariadb.service
SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$CFG_MYSQL_ROOT_PWD\r\"
expect \"Re-enter new password:\"
send \"$CFG_MYSQL_ROOT_PWD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
  echo "${SECURE_MYSQL}"
  echo -e "[${green}DONE${NC}]\n"
}
