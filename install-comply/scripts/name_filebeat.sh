# Usage: ./name_filebeat.sh kibana.dequelabs.com comply-qa-centos-core
beatname=$1
elastichome=$2
sed -i "s/ELASTICHOSTPLACEHOLDER/$elastichome/g" /etc/filebeat/filebeat.yml
sed -i "s/COMPLYHOSTNAME/$beatname/g" /etc/filebeat/filebeat.yml
