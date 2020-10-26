InstallVarnish() {
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y

  echo -n "Installing Varnish Cache... "
    yum -y install varnish
  
  echo -n "Configure Varnish Cache... "
	  sed -i "s/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/" /etc/varnish/varnish.params
	  sed -i 's/    .port = "8080";/    .port = "8090";/' /etc/varnish/default.vcl
    systemctl enable varnish.service

# Setting Up Apache Service
  systemctl stop httpd.service
  sed -i "s/Listen 80/Listen 8090/" /etc/httpd/conf/httpd.conf
  systemctl start httpd.service
  systemctl start varnish.service

  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
  	CFG_NGINX=y
	  CFG_APACHE=n

  echo -n "Installing Varnish Cache... "
    yum -y install varnish
  
  echo -n "Configure Varnish Cache... "
	  sed -i "s/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/" /etc/varnish/varnish.params
	  sed -i 's/    .port = "8080";/    .port = "8090";/' /etc/varnish/default.vcl
    systemctl enable varnish.service

# Setting Up Nginx Service
  systemctl stop nginx.service
	sed -i "s/        listen       80 default_server;/        listen       8090 default_server;/" /etc/nginx/nginx.conf
  systemctl start nginx.service
  systemctl start varnish.service

 echo -e "${green}done! ${NC}\n"
 fi
}
