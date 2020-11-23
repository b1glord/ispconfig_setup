InstallHHVM() {
if [ $CFG_HHVM = "yes" ]; then
    echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
#Add Repository Hvvm PreBuild Installation
  cat > /etc/yum.repos.d/hhvm.repo << EOF
[hhvm]
name=gleez hhvm-repo
baseurl=http://mirrors.linuxeye.com/hhvm-repo/7/\$basearch/
enabled=1
gpgcheck=0
EOF

  echo -n "Installing HHVM HipHop Virtual Machine (FCGI)... "
  yum_install hhvm

  cat > /etc/systemd/system/hhvm.service << EOF
[Unit]
Description=HHVM HipHop Virtual Machine (FCGI)
After=network.target nginx.service mariadb.service
 
[Service]
ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --mode daemon -vServer.Type=fastcgi -vServer.FileSocket=/var/log/hhvm/hhvm.sock
Restart=always
# Restart service after 10 seconds if the hhvm service crashes:
RestartSec=10
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
# Configure Hhvm 
sed -i "s/hhvm.server.port = 9001/;hhvm.server.port = 9001/" /etc/hhvm/server.ini
sed -i "/;hhvm.server.port = 9001/a hhvm.server.file_socket=/var/log/hhvm/hhvm.sock" /etc/hhvm/server.ini
sed -i "s%date.timezone = Asia/Calcutta%date.timezone = $TIME_ZONE%" /etc/hhvm/server.ini
mkdir /var/log/hhvm
# Start Hhvm Service
systemctl start hhvm
 echo -e "[${green}DONE${NC}]\n"
 fi
}
