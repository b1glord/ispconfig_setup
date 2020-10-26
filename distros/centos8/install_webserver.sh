#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

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
  	dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
	dnf --enablerepo=remi install -y phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
    sed -i "s/Require ip 127.0.0.1/#Require ip 127.0.0.1/" /etc/httpd/conf.d/phpMyAdmin.conf
    sed -i '0,/Require ip ::1/ s/Require ip ::1/#Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
	systemctl enable  httpd.service
    systemctl restart  httpd.service