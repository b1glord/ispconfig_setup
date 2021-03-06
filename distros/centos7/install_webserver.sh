#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
  echo -n "Installing Web server (Apache)... "
    yum_install httpd mod_ssl
	echo -e "[${green}DONE${NC}]\n"

		echo -n "Installing PHP ... "
	yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	yum-config-manager --enable remi-php73
	yum_install php
	echo -n "Installing PHP modules... "
	yum_install php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy
	echo -n "Installing needed programs for PHP and Apache... "
	yum_install curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel php-fpm wget
	echo -e "[${green}DONE${NC}]\n"

	sed -i "s/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED/" /etc/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE}\"/" /etc/php.ini
	
	cd /usr/local/src
	yum_install apr-devel
	wget -q http://suphp.org/download/suphp-0.7.2.tar.gz
	tar zxf suphp-0.7.2.tar.gz
	wget -q -O suphp.patch https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/suphp.patch
	patch -Np1 -d suphp-0.7.2 < suphp.patch
	cd suphp-0.7.2
	autoreconf -if
	./configure --prefix=/usr/ --sysconfdir=/etc/ --with-apr=/usr/bin/apr-1-config --with-apache-user=apache --with-setid-mode=owner --with-logfile=/var/log/httpd/suphp_log
        make
	make install
	echo "LoadModule suphp_module /usr/lib64/httpd/modules/mod_suphp.so" > /etc/httpd/conf.d/suphp.conf
	echo "[global]" > /etc/suphp.conf
	echo ";Path to logfile" >> /etc/suphp.conf 
	echo "logfile=/var/log/httpd/suphp.log" >> /etc/suphp.conf
	echo ";Loglevel" >> /etc/suphp.conf
	echo "loglevel=info" >> /etc/suphp.conf
	echo ";User Apache is running as" >> /etc/suphp.conf
	echo "webserver_user=apache" >> /etc/suphp.conf
	echo ";Path all scripts have to be in" >> /etc/suphp.conf
	echo "docroot=/" >> /etc/suphp.conf
	echo ";Path to chroot() to before executing script" >> /etc/suphp.conf
	echo ";chroot=/mychroot" >> /etc/suphp.conf
	echo "; Security options" >> /etc/suphp.conf
	echo "allow_file_group_writeable=true" >> /etc/suphp.conf
	echo "allow_file_others_writeable=false" >> /etc/suphp.conf
	echo "allow_directory_group_writeable=true" >> /etc/suphp.conf
	echo "allow_directory_others_writeable=false" >> /etc/suphp.conf
	echo ";Check wheter script is within DOCUMENT_ROOT" >> /etc/suphp.conf
	echo "check_vhost_docroot=true" >> /etc/suphp.conf
	echo ";Send minor error messages to browser" >> /etc/suphp.conf
	echo "errors_to_browser=false" >> /etc/suphp.conf
	echo ";PATH environment variable" >> /etc/suphp.conf
	echo "env_path=/bin:/usr/bin" >> /etc/suphp.conf
	echo ";Umask to set, specify in octal notation" >> /etc/suphp.conf
	echo "umask=0077" >> /etc/suphp.conf
	echo "; Minimum UID" >> /etc/suphp.conf
	echo "min_uid=100" >> /etc/suphp.conf
	echo "; Minimum GID" >> /etc/suphp.conf
	echo "min_gid=100" >> /etc/suphp.conf
	echo "" >> /etc/suphp.conf
	echo "[handlers]" >> /etc/suphp.conf
	echo ";Handler for php-scripts" >> /etc/suphp.conf
	echo "x-httpd-suphp=\"php:/usr/bin/php-cgi\"" >> /etc/suphp.conf
	echo ";Handler for CGI-scripts" >> /etc/suphp.conf
	echo "x-suphp-cgi=\"execute:"'!'"self\"" >> /etc/suphp.conf
	
	sed -i '0,/<FilesMatch \\.php$>/ s/<FilesMatch \\.php$>/<Directory \/usr\/share>\n<FilesMatch \\.php$>/' /etc/httpd/conf.d/php.conf
	sed -i '0,/<\/FilesMatch>/ s/<\/FilesMatch>/<\/FilesMatch>\n<\/Directory>/' /etc/httpd/conf.d/php.conf
	sed -i 's/<\/Directory>/#<\/Directory>/' /etc/httpd/conf.d/php.conf
	
    systemctl start php-fpm.service
    systemctl enable php-fpm.service
    systemctl enable httpd.service
	
	#removed python support for now
	echo -n "Installing mod_python... "
	yum_install python-devel
	cd /usr/local/src/
	wget -q http://dist.modpython.org/dist/mod_python-3.5.0.tgz
	tar xfz mod_python-3.5.0.tgz
	cd mod_python-3.5.0
	./configure
	make
	sed -e 's/(git describe --always)/(git describe --always 2>\/dev\/null)/g' -e 's/`git describe --always`/`git describe --always 2>\/dev\/null`/g' -i $( find . -type f -name Makefile\* -o -name version.sh )
	make install
	echo 'LoadModule python_module modules/mod_python.so' > /etc/httpd/conf.modules.d/10-python.conf
	echo -e "[${green}DONE${NC}]\n"

  echo "Installing phpMyAdmin... "
	yum_install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
    sed -i "s/Require ip 127.0.0.1/#Require ip 127.0.0.1/" /etc/httpd/conf.d/phpMyAdmin.conf
    sed -i '0,/Require ip ::1/ s/Require ip ::1/#Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
	systemctl enable  httpd.service
    	systemctl restart  httpd.service
	# echo -e "${green}done! ${NC}\n"

  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
  	CFG_NGINX=y
	CFG_APACHE=n
  echo -n "Installing Web server (nginx)... "
	yum_install nginx
	systemctl stop httpd.service
	systemctl disable httpd.service
	systemctl enable nginx.service
echo -e "[${green}DONE${NC}]\n"

	echo -n "Installing PHP ... "
	yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	yum-config-manager --enable remi-php73
	yum_install php
	echo -n "Installing PHP modules... "
	yum_install php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy
	echo -n "Installing needed programs for PHP and Nginx... "
	yum_install curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel php-fpm wget
	echo -e "[${green}DONE${NC}]\n"
	
	sed -i "/; error_reporting/ a error_reporting = E_ALL & ~E_NOTICE" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php.ini
	sed -i "/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0" /etc/php.ini
	
	systemctl enable php-fpm
	systemctl start php-fpm
	systemctl start nginx.service
	
  echo -n "Installing fcgiwrap... "
	yum_install fcgiwrap spawn-fcgi fcgi-devel
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
echo "FCGI_PROGRAM=/usr/sbin/fcgiwrap" >> /etc/sysconfig/spawn-fcgi
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
	# echo -e "${green}done! ${NC}\n"

# Configure Mailman
wget -q -O /etc/nginx/sites-enabled/default https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/webmail/apps.vhost

  echo "Installing phpMyAdmin... "
	yum_install phpmyadmin
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
	echo -e "[${green}DONE${NC}]\n"

  fi
  echo -e "${green}done! ${NC}\n"

  echo -n "Installing Let's Encrypt (Certbot)... "
	  yum_install certbot
echo -e "[${green}DONE${NC}]\n"
}
