#!/usr/bin/env bash
# WordPress Vagrant config
# Packages installed:  mysql 5.5, php5 with mysql drivers, nginx, git

# Unlock the root and give it a password? (YES/NO)
ROOT=YES

# Add vhosts
sudo cp -Rv /vagrant/vhosts/* /etc/nginx/sites-available/
sudo ln -nfs /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

echo "Booting the machine..."
sudo service nginx restart

if [ ! -f /var/log/firsttime ];
then
	sudo touch /var/log/firsttime

    # Set credentials for MySQL
	sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password vagrant"
	sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password vagrant"

    # Install packages
    sudo apt-get update
    sudo apt-get -y install nginx mysql-server php5-mysql php5-fpm software-properties-common
    sudo cp /vagrant/bin/* /usr/bin/

    # Config nginx
    sudo cp /vagrant/confs/nginx.conf /etc/nginx/

    # Install WordPress specific recommendations
    sudo apt-get -y install php5-cli php5-dev php5-fpm php5-cgi php5-xmlrpc php5-curl php5-gd php5-imagick php-apc php-pear php5-imap php5-mcrypt php5-pspell

    # Install php5.6-fpm side by side with php7.0-fpm
    sudo apt-get -y install python-software-properties
    sudo LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    sudo apt-get remove -y php5-common
    sudo apt-get -y autoremove
    sudo apt-get -y install php5.6-fpm php5.6-curl php5.6-geoip php5.6-imagick php5.6-mcrypt php5.6-recode php5.6-sqlite php5.6-xdebug php5.6-xmlrpc php5.6-xsl php5.6-mysql
    sudo cp /vagrant/confs/php5.conf /etc/nginx/php5.conf
    sudo apt-get -y install php7.0-fpm php7.0-curl php7.0-mcrypt php7.0-recode php7.0-sqlite php7.0-xmlrpc php7.0-xsl php7.0-mysql
    sudo cp /vagrant/confs/php7.conf /etc/nginx/php7.conf
    sudo update-rc.d php5.6-fpm defaults
    sudo update-rc.d php5.6-fpm auto
    sudo update-rc.d php7.0-fpm defaults
    sudo update-rc.d php7.0-fpm auto

    # Add timezones to database
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -pvagrant mysql

    # Install curl & wp-cli
    sudo apt-get -y install curl
    cd ~/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo mv wp-cli.phar /usr/bin/wp && sudo chmod +x /usr/bin/wp

    # Restart machine, obviously
    sudo service nginx restart
fi

# Unlock root and set password
if [ $ROOT = 'YES' ]
then
	sudo usermod -U root
	echo -e "password\npassword" | sudo passwd root
fi
