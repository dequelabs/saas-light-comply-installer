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

# install erlang
yum_install erlang

# install socat
yum_install socat

# install nginx
yum_install nginx
add_service nginx

# install redis
yum_install redis
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf
add_service redis
redis-cli < redis_commands

# install supervisord
yum_install supervisor
add_service supervisord

# install mongodb
yum_install mongodb-org
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
add_service mongod

# install RabbitMQ
echo "${bold}----------------- INSTALLING RABBITMQ ----------------";
echo "${bold}---------------------------------------------------";
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc;
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server-3.6.9-1.el7.noarch.rpm;
rpm -Uvh rabbitmq-server-3.6.9-1.el7.noarch.rpm;
add_service rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
rabbitmqctl add_user dqadmin deque && rabbitmqctl set_user_tags dqadmin administrator && rabbitmqctl set_permissions -p / dqadmin ".*" ".*" ".*"
rabbitmqctl list_users

echo "${bold}--------------- Verifying working versions ----------------";
s=$(rabbitmqctl status | grep '{rabbit' | grep 'rabbit,\"RabbitMQ' | awk -F '\"' '{print$4}')
if [[ ! -z "$s" ]]; then echo "RabbitMQ: $s"; else echo "WARNING: could not find RabbitMQ working version"; fi

s=$(mongod --version | grep 'db version' | awk '{print$3}')
if [[ ! -z "$s" ]]; then echo "MongoDB: $s"; else echo "WARNING: could not find RabbitMQ working version"; fi

s=$(redis-server --version | awk '{print$3}' | awk -F '=' '{print$2}')
if [[ ! -z "$s" ]]; then echo "Redis: $s"; else echo "WARNING: could not find $i working version"; fi;

s=$(supervisord --version)
if [[ ! -z "$s" ]]; then echo "Supervisord: $s"; else echo "WARNING: could not find $i working version"; fi;


echo "${bold}--------------- Verifying running processes for mongod, rabbitmq, nginx, redis, supervisord ----------------";
for i in mongod rabbitmq nginx redis; do x=$(pgrep -f -n -u $i $i | head -n1); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

for i in supervisord; do x=$(pgrep $i); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

echo "${bold}--------------- verifying listeners for mongo/redis/nginx/rabbitmq(beam.smp) on 0.0.0.0 --------------${normal}";
netstat -anp | grep 0.0.0.0 | egrep 'mongod|redis|nginx|beam.smp' | sed 's/beam.smp/beam.smp(RabbitMQ)/g';

