InstallHHVM() {
if [ $CFG_HHVM = "yes" ]; then
    echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
yum_install cpp gcc-c++ cmake git psmisc {binutils,boost,jemalloc,numactl}-devel \
{ImageMagick,sqlite,tbb,bzip2,openldap,readline,elfutils-libelf,gmp,lz4,pcre}-devel \
lib{xslt,event,yaml,vpx,png,zip,icu,mcrypt,memcached,cap,dwarf}-devel \
{unixODBC,expat,mariadb}-devel lib{edit,curl,xml2,xslt}-devel \
glog-devel oniguruma-devel ocaml gperf enca libjpeg-turbo-devel openssl-devel \
mariadb mariadb-server libc-client make

#Add Repository Hvvm PreBuild Installation
  cat > /etc/yum.repos.d/hhvm.repo << EOF
[hhvm]
name=gleez hhvm-repo
baseurl=http://mirrors.linuxeye.com/hhvm-repo/7/\$basearch/
enabled=1
gpgcheck=0
EOF

  echo -n "Installing HHVM HipHop Virtual Machine (FCGI)... "
  yum -y install hhvm

  cat > /etc/systemd/system/hhvm.service << EOF
[Unit]
Description=HHVM HipHop Virtual Machine (FCGI)
After=network.target nginx.service mariadb.service
 
[Service]
ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user nginx --mode daemon -vServer.Type=fastcgi -vServer.FileSocket=/var/log/hhvm/hhvm.sock
 
[Install]
WantedBy=multi-user.target
EOF

# Configure Hhvm 
sed -i "s/hhvm.server.port = 9001/;hhvm.server.port = 9001/" /etc/hhvm/server.ini
sed -i "/;hhvm.server.port = 9001/a hhvm.server.file_socket=/var/log/hhvm/hhvm.sock" /etc/hhvm/server.ini
sed -i "s%date.timezone = Asia/Calcutta%date.timezone = $TIME_ZONE%" /etc/hhvm/server.ini

  systemctl enable hhvm
  
if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
mkdir /var/log/hhvm /var/cache/hhvm /var/run/hhvm
sudo chown apache:apache /var/log/hhvm /var/cache/hhvm /var/run/hhvm
chmod 0770 /var/log/hhvm /var/cache/hhvm /var/run/hhvm
sed -i "s%chown -R nginx:nginx /var/run/hhvm/%chown -R apache:apache /var/run/hhvm/%" /etc/rc.local
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/hhvm/files/apache2/mods-available/hhvm_proxy_fcgi.conf -P /etc/httpd/conf.d/
sed -i "s/--user nginx/--user apache/" /usr/lib/systemd/system/hhvm.service
elif [ "$CFG_WEBSERVER" == "nginx" ]; then
  	CFG_NGINX=y
	CFG_APACHE=n
usermod -a -G apache nginx
mkdir /var/log/hhvm /var/cache/hhvm /var/run/hhvm
sudo chown nginx:nginx /var/log/hhvm /var/cache/hhvm /var/run/hhvm
chmod 0770 /var/log/hhvm /var/cache/hhvm /var/run/hhvm
sed -i "s/--user nginx/--user nginx/" /usr/lib/systemd/system/hhvm.service
fi
systemctl daemon-reload
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/hhvm/test/hhvminfo.php -P /var/www
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/hhvm/test/phpinfo.php -P /var/www

systemctl start hhvm
systemctl status hhvm
hhvm --version
 echo -e "[${green}DONE${NC}]\n"
 fi
}
