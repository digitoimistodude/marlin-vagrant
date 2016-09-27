# Marlin-vagrant

Marlin vagrant is a WordPress optimized vagrant server created for local development environment for servers that use WordPress optimized software, reliable hardware, brilliant for example if you have Digital Ocean droplets or your own virtual servers in production. 

This Vagrant box is named after *marlin* which is one of the fastest animals in the world.

Marlin vagrant server can be used as plain local server for serving your files or testing static PHP, but it's also perfect for WordPress development.

**Marlin is a strictly development VM and should be customized.** Also works out of the box. Tweak as close as your production server to get the best results.

![](https://dl.dropboxusercontent.com/u/18447700/vagrant.png)

## What's inside?

| Feature                 | Version / amount                                                   |
|-------------------------|--------------------------------------------------------------------|
| Ubuntu                  | 14.04.3 LTS (Trusty Tahr)                                     |
| MySQL                   | 5.5                                                                |
| PHP                     | 5.6.25, 7.0.10                                       |
| WordPress optimizations | PHP modules recommended for optimal WordPress performance          |
| Vagrant                 | NFS, provision.sh with pre-installed packages, speed optimizations |
| CPU cores               | 1                                                                  |
| RAM                     | 1 GB                                                               |
| nginx                  | 1.4.6                                                            |
| HHVM                     | 3.14.5                                       |

## Background

This is based on [jolliest-vagrant](https://github.com/digitoimistodude/jolliest-vagrant), our first Vagrant box with Apache. We needed faster and scalable environment, so started to use Digital Ocean droplets and needed a local development server identical to that. And so Marlin vagrant was born.

Read the original background story about Dude's vagrant-servers [here](https://github.com/digitoimistodude/jolliest-vagrant#background).

## Usage

To start this vagrant box, always run `vagrant up --provision`, with provision -hook to ensure all the stuff are loaded up properly.

## Table of contents

1. [Installation on Mac/Linux](#installation-on-maclinux)
2. [Installation on Windows](#installation-on-windows)
3. [How to add new vhost](#how-to-add-new-vhost)
4. [How to remove a project or vhost](#how-to-remove-a-project-or-vhost)
5. [Connecting with another computer in LAN](#connecting-with-another-computer-in-lan)
6. [Port forwarding (optional)](#port-forwarding-optional)
7. [Recommended post-installations](#recommended post-installations)
8. [Create a self-signed SSL Certificate for marlin-vagrant](#create-a-self-signed-ssl-certificate-for-marlin-vagrant-optional)
9. [Sequel Pro settings for MySQL](#sequel-pro-settings-for-mysql)
10. [Using PHP5.6 or PHP7 instead of HHVM](#using-php56-or-php7-instead-of-hhvm)
11. [Error logging in HHVM and PHP](#error-logging-in-hhvm-and-php)
12. [Troubleshooting and issues](#troubleshooting-and-issues)
13. [WP-CLI alias](#wp-cli-alias)

## Recommendations

1. Mac OS X or Linux
2. Simple knowledge of web servers
3. WordPress projects under the same folder
4. [dudestack](https://github.com/digitoimistodude/dudestack) in use

## Installation on Mac/Linux

1. Install [Virtualbox](https://www.virtualbox.org/)
2. Start Virtualbox, check updates and install all the latest versions of Virtualbox and Oracle VM Virtualbox Extension Pack, if asked
3. Install [vagrant](http://www.vagrantup.com) (**Mac OS X** [Homebrew](http://brew.sh/): `brew install vagrant`)
4. Install vagrant-triggers with command `vagrant plugin install vagrant-triggers`
5. Install VirtualBox Guest Additions -updater vagrant-vbguest with command `vagrant plugin install vagrant-vbguest`
6. Clone this repo to your Projects directory (path `~/Projects/marlin-vagrant` is depedant in [dudestack](https://github.com/digitoimistodude/dudestack))
7. *(Optional, do this for example if you want to use other image or encounter problems with included Vagrantfile)* If you don't know or don't care, don't do this step. Modify **Vagrantfile**: `config.vm.box` and `config.vm.box_url` to match your production server OS, `config.vm.network` for IP (I recommend it to be `10.1.2.4` to prevent collisions with other subnets) (**For Linux** you need to remove `, :mount_options...` if problems occur with starting the server. Please remove parts that give you errors). **If you don't need to access server from LAN** with co-workers to update WordPress for example, remove completely line with `config.vm.network "public_network"`. You may also need to try different ports than 80 and 443 if your Mac blocks them. For example change the ports to 8080 and 443 (also change triggers accordingly)
8. If you store your projects in different folder than *~/Projects*, change the correct path to `config.vm.synced_folder`
9. Edit or add packages to match your production server packages in **provision.sh** if needed (it's good out of the box though)
10. Add `10.1.2.4 somesite.dev` to your **/etc/hosts**
11. Run `vagrant up --provision`. This can take a moment.

If you make any changes to **Vagrantfile**, run `vagrant reload` or `vagrant up --provision` if the server is not running, or if you change **provision.sh** while running, run `vagrant provision`.

You can always see the server status by `vagrant ssh`'ing to your vagrant box and typing `sudo service nginx status`. If it's not started, run `sudo service nginx start`. **Note:** if your server doesn't start, please ensure you either have removed example.dev from `vhosts/` and `/etc/nginx/sites-available` and `/etc/nginx/sites-enabled` or created a directory called `example` to your Projects dir.

## Installation on Windows

1. Install [Virtualbox](https://www.virtualbox.org/) for Windows
2. Install [Vagrant](http://www.vagrantup.com) for Windows
3. Install [Git](https://git-scm.com/download/win) for Windows
3. Right click My Computer (or This Compu
ter on Windows 10), click Properties, click Advaned System Settings tab, click Environment Variables. Change `VBOX_MSI_INSTALL_PATH` to `VBOX_INSTALL_PATH`. In Windows 10, you can go to Advanced System Settings simply typing it when Start Menu is open.
4. Start `cmd`
5. Navigate to root of `C:\` with double dots `..`
6. `mkdir Projects` to create a project dir and `cd Projects` to enter it
7. Clone this repo to Projects with command `git clone git@github.com:digitoimistodude/marlin-vagrant.git`
8. Edit `Vagrantfile` with your favorite editor and rename `~/Projects` to `C:/Projects`. Remove `, :mount_options => ['nolock,vers=3,udp,actimeo=2']`
9. Run `vagrant up --provision`, wait when box is installed and Allow access if it asks it. This can take a moment.
10. Add `10.1.2.4 somesite.dev` to your **C:/Windows/system32/drivers/etc/hosts** file and have fun!

### How to add new vhost

It's simple to manage multiple projects with nginx's sites-enabled configs. If your project name is `jolly`, and located in *~/Projects/jolly*, just add new config to vhosts. *vhosts/jolly.dev* would then be:

````
server {
    listen 80;
    #listen [::]:80 default ipv6only=on;

    access_log /var/www/jolly/access.log;
    error_log /var/www/jolly/error.log;

    root /var/www/jolly;
    index index.html index.htm index.php;

    server_name jolly.dev www.jolly.dev;
    include hhvm.conf;
    include global/wordpress.conf;

    #  Static File Caching
    location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
       expires 365d;
    }
}
````

Run `vagrant provision`, add `10.1.2.4 jolly.dev` to `/etc/hosts` and boom! http://jolly.dev points to your project file.

### How to remove a project or vhost

If you remove a project from Projects folder, or rename it, you should also remove/rename `vhosts/projectname.dev` correspondingly and make sure after `vagrant ssh` you don't have that conf to point nonexisting files in `/etc/nginx/sites-enabled` and `/etc/nginx/sites-available`. Otherwise the server wont' start!

For example, if we create test project to ~/Projects/test and then remove the folder, next time you are starting up nginx fails. You will have to `vagrant ssh` and `sudo rm /etc/nginx/sites-enabled/test.dev && sudo rm /etc/nginx/sites-available/test.dev && /vagrant/vhosts/test.dev`.

## Connecting with another computer in LAN

You should be good to go after setting up **/etc/hosts** to `192.168.2.242 jolly.dev` (depending on your local subnet of course) on remote computer. If you have problems like I had, run this command on your vagrant host PC (not inside vagrant ssh!):

    sudo ssh -p 2222 -gNfL 80:localhost:80 vagrant@localhost -i ~/.vagrant.d/insecure_private_key

This also helps in some cases where you are unable to open http://localhost in browser window.

### Port forwarding (optional)

`Vagrantfile` has port forwarding included, but Mac OS X has some limitations. If .dev-urls are not reachable from local area network, please add this to `/usr/bin/forwardports` by `sudo nano /usr/bin/forwardports`:

    echo "
    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080
    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443
    " | sudo pfctl -f - > /dev/null 2>&1;

    echo "==> Fowarding Ports: 80 -> 8080, 443 -> 8443";

    osascript -e 'tell application "Terminal" to quit' & exit;

Chmod it by `chmod +x /usr/bin/forwardports` and run `forwardports`. You have to do this every time after reboot, if you are co-working in LAN.

## Recommended post-installations

I have not included everything to this box since I want it keep as minimal as possible, but here's some recommended pieces you should install especially on production (I'll add more later):

- [rocket-nginx](https://github.com/maximejobin/rocket-nginx) - Nginx configuration for WP-Rocket
- [ngx_pagespeed](https://www.digitalocean.com/community/tutorials/how-to-add-ngx_pagespeed-to-nginx-on-ubuntu-14-04) - The PageSpeed modules are open-source server modules that optimize your site automatically.

## Create a self-signed SSL Certificate for marlin-vagrant (optional)

1. Go to the directory you cloned this repo by `cd ~/Projects/marlin-vagrant`
2. SSH into your vagrant box: `vagrant ssh`
3. `sudo mkdir /etc/nginx/ssl`
4. `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt` (press enter all the way through)
5. `sudo nano /etc/nginx/sites-enabled/yourwebsitename.dev` and make sure it looks like something like this:

````
server {
    listen 443 ssl;

    access_log /var/www/yourwebsitename/access.log;
    error_log /var/www/yourwebsitename/error.log;

    root /var/www/yourwebsitename;
    index index.html index.htm index.php;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    server_name yourwebsitename.dev www.yourwebsitename.dev;
    include hhvm.conf;
    include global/wordpress.conf;
}
````

6. Restart nginx: `sudo service nginx restart`

## WP-CLI alias

WP-Cli is included in [dudestack](https://github.com/digitoimistodude/dudestack) per project within `composer.json` and won't work by default. You'll need this alias on your Mac or Linux `.bashrc` or `.bash_profile` file:

```shell
alias wp='ssh vagrant@10.1.2.4 "cd /var/www/"$(basename "$PWD")"; /var/www/"$(basename "$PWD")"/vendor/wp-cli/wp-cli/bin/wp"'
```

After restarting Terminal or running `. ~/.bashrc` or `. ~/.bash_profile` you will be able to use `wp` command directly on your host machine without having to ssh into vagrant.

## Using PHP5.6 or PHP7 instead of HHVM

You can choose to use php5.6 or php7 instead of HHVM. Just add this inside the server block of your virtual host, for example `/etc/nginx/sites-enabled/example.com`:

````
# Use php-fpm instead of HHVM
location ~ \.php$ {
   try_files $uri /index.php;
   fastcgi_split_path_info ^(.+\.php)(/.+)$;
   include fastcgi_params;
   fastcgi_index index.php;
   fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
   fastcgi_pass   unix:/var/run/php/php7.0-fpm.sock;
}
````

Change the version `fastcgi_pass` for different PHP versions, like 5.6.

## Error logging in HHVM and PHP

Log in to vagrant with `vagrant ssh` when inside vagrant dir with Terminal, then run `sudo tail -f /var/log/hhvm/error.log` to see errors when using hhvm.conf.

If you want to see php-fpm errors for example in php7.0-fpm, add this to the bottom of `/etc/php/7.0/fpm/pool.d/www.conf`:

````
catch_workers_output = yes
php_flag[display_errors] = on
php_admin_value[error_log] = /var/log/fpm7.0-php.www.log ; remember: touch /var/log/fpm7.0-php.www.log && chmod 775 /var/log/fpm7.0-php.www.log && sudo chown www-data /var/log/fpm7.0-php.www.log
php_admin_flag[log_errors] = on
php_admin_flag[catch_workers_output] = yes
php_admin_value[memory_limit] = 1024M
slowlog = /var/log/fpm7.0-php.slow.log ; remember: touch /var/log/fpm7.0-php.slow.log && chmod 775 /var/log/fpm7.0-php.slow.log && sudo chown www-data /var/log/fpm7.0-php.slow.log
request_slowlog_timeout = 10
````

Then run `touch /var/log/fpm7.0-php.www.log && chmod 775 /var/log/fpm7.0-php.www.log && sudo chown www-data /var/log/fpm7.0-php.www.log` and `touch /var/log/fpm7.0-php.slow.log && chmod 775 /var/log/fpm7.0-php.slow.log && sudo chown www-data /var/log/fpm7.0-php.slow.log` and then restart php7.0-fpm with `sudo service php7.0-fpm restart`. 

To see log, run `sudo tail -f /var/log/fpm7.0-php.www.log`.

## Troubleshooting and issues

### Authentication failure

    ==> marlin: Booting VM...
    ==> marlin: Waiting for machine to boot. This may take a few minutes...
        marlin: SSH address: 127.0.0.1:2222
        marlin: SSH username: vagrant
        marlin: SSH auth method: private key
        marlin: Warning: Connection timeout. Retrying...
        marlin: Warning: Authentication failure. Retrying...
        marlin: Warning: Authentication failure. Retrying...
        marlin: Warning: Authentication failure. Retrying...
        marlin: Warning: Authentication failure. Retrying...
        ...

This is probably if you use [jolliest-vagrant](https://github.com/digitoimistodude/jolliest-vagrant) or another vagrant box with same ssh keypairs. This can be solved with `cat ~/.ssh/id_rsa.pub`, copying that key, then going to `cd ~/Projects/marlin-vagrant && vagrant ssh`, typing password, then adding the file to VM's known_hosts with `nano ~/.ssh/known_hosts` and saving the file while connecting.

### Other issues

In any issue, error or trouble, please open an issue to [issue tracker](https://github.com/digitoimistodude/marlin-vagrant/issues).

## Sequel Pro settings for MySQL

Choose **SSH** tab and add following settings.

| Setting | Input field |
|---|---|
| Name: | vagrant mysql |
| MySQL Host: | 127.0.0.1 |
| Username: | root |
| Password: | vagrant |
| Database: | *optional* |
| Port: | 3306 |
| SSH Host: | 10.1.2.4 |
| SSH User: | vagrant |
| SSH Password: | vagrant |
| SSH Port: | 22 |
