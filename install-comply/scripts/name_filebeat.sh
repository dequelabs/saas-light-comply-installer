# Usage: ./name_filebeat.sh kibana.dequelabs.com comply-qa-centos-core
elastichome=$1
beatname=$2
sed -i "s/HOSTPLACEHOLDER/$elastichome/g" /etc/filebeat/filebeat.yml
sed -i "s/NAMEPLACEHOLDER/$beatname/g" /etc/filebeat/filebeat.yml
