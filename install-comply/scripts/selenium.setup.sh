#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

yum_install () {
    echo "${bold}----------------- INSTALLING $1";
    echo "${bold}---------------------------------------------------";
    yum install -y $1 > /dev/null 2>&1
    if [[ $? = "0" ]];
        then
            echo "${bold}$1 is installed."
        else
            echo "${bold}ERROR: A problem was encountered with "yum install -y $1".";
            printf "\n";
    fi
}

add_service () {
    systemctl enable $1;
    systemctl start $1;
    systemctl status $1;
}

# install wget
yum_install wget

# install epel-release
yum_install epel-release

# install google-chrome-stable 
yum_install google-chrome-stable-69.0.3497.100-1.x86_64 

# install nginx
yum_install nginx

# install supervisord
yum_install supervisor
add_service supervisord

# install redis
yum_install redis
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf
add_service redis

yum_install gtk3 
yum_install xorg-x11-font-utils 
yum_install xorg-x11-fonts*
yum_install dbus-x11
yum_install xorg-x11-server-Xvfb

echo "--------------- Verifying working versions ----------------";
s=$(supervisord --version)
if [[ ! -z "$s" ]]; then echo "Supervisord: $s"; else echo "WARNING: could not find $i working version"; fi;

s=$(redis-server --version | awk '{print$3}' | awk -F '=' '{print$2}')
if [[ ! -z "$s" ]]; then echo "Redis: $s"; else echo "WARNING: could not find $i working version"; fi;

#echo "--------------- Verifying supervisord working version ----------------";
#s=$(supervisord --verion)
#if [[ ! -z "$s" ]]; then echo "SU: $s"; else echo "WARNING: could not find RabbitMQ working version"; f

echo "--------------- Verifying running processes for supervisord ----------------";

for i in supervisord; do x=$(pgrep $i); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

