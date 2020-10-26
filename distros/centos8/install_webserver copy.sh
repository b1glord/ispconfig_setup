#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
  echo -n "Installing Apache and modules... "
 	dnf -y install httpd
	#dnf -y install php httpd httpd-tools mod_ssl
	sed -i '/; Note: This value is mandatory./a listen = 9000' /etc/php-fpm.d/www.conf

  echo -n "Installing PHP and Modules... "
	dnf -y install   php
	dnf -y install php-gd php-fpm php-pdo php-gmp php-dbg php-pdo php-xml php-cli php-dba php-soap php-snmp php-ldap php-pear php-intl php-json php-odbc php-devel php-pgsql php-common php-recode php-bcmath php-xmlrpc php-mysqlnd php-enchant php-process php-opcache php-mbstring php-pecl-zip php-embedded php-pecl-apcu php-pecl-apcu-devel
  echo -e "[${green}DONE${NC}]\n"
	sed -i "s/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED/" /etc/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php.ini
  # install apr
	dnf -y install apr-devel
  # install mod_suphp 
  #ref:https://github.com/lightsey/mod_suphp 
	rpm -ivh https://github.com/b1glord/ispconfig_setup_extra/raw/master/centos8/suphp/mod_suphp-0.7.2-16.el7.lux.1.x86_64.rpm
			
  echo -n "Installing mod_python... "
	dnf -y install python3-devel
	echo -e "[${green}DONE${NC}]\n"
		systemctl enable php-fpm
		systemctl start php-fpm
		systemctl enable httpd
		systemctl start httpd
	 echo -e "${green}done! ${NC}\n"

  echo "Installing phpMyAdmin... "
  	yum_install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
	yum --enablerepo=remi install -y phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
    sed -i "s/Require ip 127.0.0.1/#Require ip 127.0.0.1/" /etc/httpd/conf.d/phpMyAdmin.conf
    sed -i '0,/Require ip ::1/ s/Require ip ::1/#Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
	systemctl enable  httpd.service
    systemctl restart  httpd.service
fi

  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
  	CFG_NGINX=y
	CFG_APACHE=n
  echo -n "Installing Web server (nginx)... "
	dnf -y install nginx varnish
	sed -i "s/        listen       80 default_server;/        listen       8090 default_server;/" /etc/nginx/nginx.conf
	sed -i "s/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/" /etc/varnish/varnish.params
	sed -i 's/    .port = "8080";/    .port = "8090";/' /etc/varnish/default.vcl
	
	systemctl stop httpd.service
	systemctl disable httpd.service
	systemctl enable nginx.service
	systemctl enable varnish.service

  echo -n "Installing PHP 7 and modules... "
	dnf -y install php
  
  echo -n "Installing PHP modules... "
dnf -y install php-gd php-fpm php-pdo php-gmp php-dbg php-pdo php-xml php-cli php-dba php-soap php-snmp php-ldap php-pear php-intl php-json php-odbc php-devel php-pgsql php-common php-recode php-bcmath php-xmlrpc php-mysqlnd php-enchant php-process php-opcache php-mbstring php-pecl-zip php-embedded php-pecl-apcu php-pecl-apcu-devel
	

	sed -i "/; error_reporting/ a error_reporting = E_ALL & ~E_NOTICE" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php.ini
	sed -i "/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0" /etc/php.ini
	sed -i "s%;pid = /var/log/hhvm/pid%pid = /var/log/hhvm/pid%" /etc/hhvm/server.ini
	
	systemctl enable php-fpm
	systemctl start php-fpm
	systemctl start nginx.service
	systemctl start varnish.service
	
  echo -n "Installing fcgiwrap... "
	dnf -y install fcgiwrap spawn-fcgi fcgi-devel


# modify the /etc/sysconfig/spawn-fcgi file as follows:
echo '# You must set some working options before the "spawn-fcgi" service will work.' >> /etc/sysconfig/spawn-fcgi
echo "# If SOCKET points to a file, then this file is cleaned up by the init script." >> /etc/sysconfig/spawn-fcgi
echo "#" >> /etc/sysconfig/spawn-fcgi
echo "# See spawn-fcgi(1) for all possible options." >> /etc/sysconfig/spawn-fcgi
echo "#" >> /etc/sysconfig/spawn-fcgi
echo "# Example :" >> /etc/sysconfig/spawn-fcgi
echo "#SOCKET=/var/run/php-fcgi.sock" >> /etc/sysconfig/spawn-fcgi
echo '#OPTIONS="-u nginx -g nginx -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"' >> /etc/sysconfig/spawn-fcgi
echo "FCGI_SOCKET=/var/run/fcgiwrap.socket" >> /etc/sysconfig/spawn-fcgi
echo "FCGI_PROGRAM=/usr/local/sbin/fcgiwrap" >> /etc/sysconfig/spawn-fcgi
echo "FCGI_USER=apache" >> /etc/sysconfig/spawn-fcgi
echo "FCGI_GROUP=apache" >> /etc/sysconfig/spawn-fcgi
echo 'FCGI_EXTRA_OPTIONS="-M 0770"' >> /etc/sysconfig/spawn-fcgi
echo 'OPTIONS="-u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -S $FCGI_EXTRA_OPTIONS -F 1 -P /var/run/spawn-fcgi.pid -- $FCGI_PROGRAM"' >> /etc/sysconfig/spawn-fcgi

#Now add the user nginx to the group apache:
	usermod -a -G apache nginx
	chkconfig spawn-fcgi on
	systemctl start spawn-fcgi
	systemctl restart nginx.service
	systemctl restart php-fpm
	systemctl restart varnish.service
	# echo -e "${green}done! ${NC}\n"

  echo "Installing phpMyAdmin... "
  	yum_install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
	yum --enablerepo=remi install -y phpmyadmin
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
		echo -e "[${green}DONE${NC}]\n"
  fi
  echo -e "${green}done! ${NC}\n"

  echo -n "Installing Let's Encrypt (Certbot)... "
	  dnf -y install certbot
echo -e "[${green}DONE${NC}]\n"
}
