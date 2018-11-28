# Usage: ./name_filebeat.sh kibana.dequelabs.com comply-qa-centos-core
elastichome=kibana.dequelabs.com
beatname=$(grep wscorehost /opt/install.options | awk -F'=' '{print$2}' | cut -d"." -f1);
sed -i "s/HOSTPLACEHOLDER/$elastichome/g" /etc/filebeat/filebeat.yml
sed -i "s/NAMEPLACEHOLDER/$beatname/g" /etc/filebeat/filebeat.yml
