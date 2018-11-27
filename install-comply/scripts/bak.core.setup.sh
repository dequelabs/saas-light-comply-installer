#BOTH
echo "----------------- INSTALLING WGET ----------------";
echo "---------------------------------------------------";
yum install -y wget 

#BOTH
echo "----------------- INSTALLING EPEL RELEASE ----------------";
echo "---------------------------------------------------";
yum install -y epel-release

#CORE
echo "----------------- INSTALLING MONGOD ----------------";
echo "---------------------------------------------------";
yum -y install mongodb-org;
#/etc/mongod.conf 'Change bind_ip=127.0.0.1 to bind_ip=0.0.0.0'
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
systemctl enable mongod
systemctl start mongod
systemctl status mongod

#CORE
echo "----------------- INSTALLING ERLANG ----------------";
echo "---------------------------------------------------";
yum install -y erlang;
yum install -y socat;

#CORE
echo "----------------- INSTALLING RABBITMQ ----------------";
echo "---------------------------------------------------";
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc;
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server-3.6.9-1.el7.noarch.rpm;
rpm -Uvh rabbitmq-server-3.6.9-1.el7.noarch.rpm; systemctl enable rabbitmq-server;
systemctl start rabbitmq-server;
systemctl status rabbitmq-server

rabbitmq-plugins enable rabbitmq_management
rabbitmqctl add_user dqadmin deque && rabbitmqctl set_user_tags dqadmin administrator && rabbitmqctl set_permissions -p / dqadmin ".*" ".*" ".*"
rabbitmqctl list_users

#BOTH
echo "----------------- INSTALLING NGINX ----------------";
echo "---------------------------------------------------";
yum install -y nginx;
systemctl enable nginx;
systemctl start nginx;

#CORE
echo "----------------- INSTALLING REDIS ----------------";
echo "---------------------------------------------------";
yum install -y redis
#/etc/redis.conf 'Change bind 127.0.0.1 to bind 0.0.0.0'
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf
systemctl enable redis
systemctl start redis

#BOTH
echo "----------------- INSTALLING SUPERVISORD ----------------";
echo "---------------------------------------------------";
yum install supervisor
systemctl enable supervisord
systemctl start supervisord

echo "--------------- Verifying working versions ----------------";
s=$(rabbitmqctl status | grep '{rabbit' | grep 'rabbit,\"RabbitMQ' | awk -F '\"' '{print$4}')
if [[ ! -z "$s" ]]; then echo "RabbitMQ: $s"; else echo "WARNING: could not find RabbitMQ working version"; fi

#echo "--------------- Verifying mongod working version ----------------";
s=$(mongod --version | grep 'db version' | awk '{print$3}')
if [[ ! -z "$s" ]]; then echo "MongoDB: $s"; else echo "WARNING: could not find RabbitMQ working version"; fi
#echo "--------------- Verifying redis working version ----------------";

s=$(redis-server --version | awk '{print$3}' | awk -F '=' '{print$2}')
if [[ ! -z "$s" ]]; then echo "Redis: $s"; else echo "WARNING: could not find $i working version"; fi;

s=$(supervisord --version)
if [[ ! -z "$s" ]]; then echo "Supervisord: $s"; else echo "WARNING: could not find $i working version"; fi;

#echo "--------------- Verifying supervisord working version ----------------";
#s=$(supervisord --verion)
#if [[ ! -z "$s" ]]; then echo "SU: $s"; else echo "WARNING: could not find RabbitMQ working version"; f

echo "--------------- Verifying running processes for mongod, rabbitmq, nginx, redis, supervisord ----------------";
for i in mongod rabbitmq nginx redis; do x=$(pgrep -f -n -u $i $i | head -n1); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

for i in supervisord; do x=$(pgrep $i); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

echo "--------------- verifying mongo/redis/nginx/rabbitmq(beam.smp) on 0.0.0.0 --------------";
netstat -anp | grep 0.0.0.0 | egrep 'mongod|redis|nginx|beam.smp' | sed 's/beam.smp/beam.smp(RabbitMQ)/g';
