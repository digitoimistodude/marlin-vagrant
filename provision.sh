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

    # Install HHVM
    sudo apt-get update
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
    sudo apt-get update
    sudo apt-get -y install hhvm
    sudo update-rc.d hhvm defaults

    # Config HHVM
    sudo /usr/share/hhvm/install_fastcgi.sh
    sudo cp /vagrant/confs/hhvm/server.ini /etc/hhvm/server.ini
    sudo cp /vagrant/confs/hhvm/php.ini /etc/hhvm/php.ini
    sudo cp /vagrant/confs/hhvm.conf /etc/nginx/hhvm.conf
    sudo cp -R /vagrant/confs/global /etc/nginx/
    sudo service hhvm restart
    sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

    # Install WordPress specific recommendations
    sudo apt-get -y install php5-cli php5-dev php5-fpm php5-cgi php5-xmlrpc php5-curl php5-gd php5-imagick php-apc php-pear php5-imap php5-mcrypt php5-pspell

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