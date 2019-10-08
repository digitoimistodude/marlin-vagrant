#!/usr/bin/env bash
# WordPress Vagrant config
# Packages installed: mysql 5.5, php5 with mysql drivers, nginx, git

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
    sudo debconf-set-selections <<< "mariadb-server mariadb-server/root_password password vagrant"
    sudo debconf-set-selections <<< "mariadb-server mariadb-server/root_password_again password vagrant"
    sudo debconf-set-selections <<< "mariadb-server-10.4 mariadb-server/root_password password vagrant"
    sudo debconf-set-selections <<< "mariadb-server-10.4 mariadb-server/root_password_again password vagrant"
    # sudo debconf-set-selections <<< "mariadb-server-10.1 mariadb-server/root_password password vagrant"
    # sudo debconf-set-selections <<< "mariadb-server-10.1 mariadb-server/root_password_again password vagrant"

    # Install global handy packages
    sudo apt-get update
    sudo apt-get -y install software-properties-common libnuma-dev

    # Install nginx
    sudo apt-get update
    sudo apt-get -y install nginx
    sudo cp /vagrant/bin/* /usr/bin/

    # Config nginx
    sudo cp /vagrant/confs/nginx.conf /etc/nginx/

    # Install mariadb
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.4/ubuntu xenial main'
    sudo apt-get update
    sudo apt-get -y install mariadb-server
    sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
    sudo service mysql start
    sudo service mysql stop

    # mariadb configuration
    sudo cp /vagrant/confs/mysql.cnf /etc/mysql/my.cnf

    # Get ready for PHP installation
    sudo LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
    sudo apt-get update

    # Install PHP 7.2
    sudo apt-get -y install php7.2-fpm php7.2-mysql php7.2-curl php7.2-gd php7.2-intl php7.2-imagick php-imagick php7.2-imap php-memcache php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl php-gettext php7.2-gettext php-gd php php7.2-zip

    # Install PHP 7.0
    sudo apt-get -y install php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-imagick php-imagick php7.0-imap php7.0-mcrypt php-memcache php7.0-memcache php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php-gettext php7.0-gettext php-gd php

    # Install PHP 5.6
    sudo apt-get -y install php5.6-fpm php5.6-mysql php5.6-curl php5.6-gd php5.6-intl php5.6-imagick php-imagick php5.6-imap php5.6-mcrypt php-memcache php5.6-memcache php5.6-pspell php5.6-recode php5.6-sqlite3 php5.6-tidy php5.6-xmlrpc php5.6-xsl php5.6-mbstring php-gettext php5.6-gettext php-gd

    # PHP configuration
    sudo cp /vagrant/confs/php5.conf /etc/nginx/php5.conf
    sudo cp /vagrant/confs/php7.conf /etc/nginx/php7.conf

    # Install Redis
    sudo apt-get -y install build-essential tcl8.5
    wget http://download.redis.io/releases/redis-stable.tar.gz
    tar xzf redis-stable.tar.gz
    cd redis-stable
    make
    make test
    sudo make install
    sudo REDIS_PORT=6379 \
         REDIS_CONFIG_FILE=/etc/redis/redis.conf \
         REDIS_LOG_FILE=/var/log/redis.log \
         REDIS_DATA_DIR=/var/lib/redis \
         REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh
    redis-cli PING

    # Add timezones to database
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -pvagrant mysql

    # Install curl & wp-cli
    sudo apt-get -y install curl
    cd ~/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo mv wp-cli.phar /usr/bin/wp && sudo chmod +x /usr/bin/wp

    # Restart machine, obviously
    sudo service nginx restart
    sudo service mysql start
fi

# Unlock root and set password
if [ $ROOT = 'YES' ]
then
	sudo usermod -U root
	echo -e "password\npassword" | sudo passwd root
fi
