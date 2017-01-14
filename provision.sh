#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales
export DEBIAN_FRONTEND=noninteractive

apt-get -y update

apt-get upgrade

apt-get -y install nginx

service nginx start

wget https://dev.mysql.com/get/mysql-apt-config_0.8.1-1_all.deb

echo mysql-apt-config mysql-apt-config/repo-distro select ubuntu | debconf-set-selections
echo mysql-apt-config mysql-apt-config/repo-codename select trusty | debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-server select mysql-5.7 | debconf-set-selections
echo mysql-community-server mysql-server/root-pass password vserver | debconf-set-selections
echo mysql-community-server mysql-server/re-root-pass password vserver | debconf-set-selections

dpkg -i mysql-apt-config_0.8.1-1_all.deb

apt-get update
apt-get install -y mysql-server

sudo sed -i "/.*bind-address.*/bind-address = 0.0.0.0" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -uroot -pvserver -e "CREATE USER 'remoteuser'@'localhost' IDENTIFIED BY '$DBROOT_PASSWORD'; "
sudo mysql -uroot -pvserver -e "CREATE USER 'remoteuser'@'%' IDENTIFIED BY  '$DBROOT_PASSWORD'; "
sudo mysql -uroot -pvserver -e "GRANT ALL PRIVILEGES ON *.* TO 'remoteuser'@'localhost' WITH GRANT OPTION; "
sudo mysql -uroot -pvserver -e "GRANT ALL PRIVILEGES ON *.* TO 'remoteuser'@'%' WITH GRANT OPTION; "

service mysql restart
