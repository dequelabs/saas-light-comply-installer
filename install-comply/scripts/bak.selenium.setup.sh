
#BOTH
echo "----------------- INSTALLING WGET ----------------";
echo "---------------------------------------------------";
yum install -y wget 

#BOTH
echo "----------------- INSTALLING EPEL RELEASE ----------------";
echo "---------------------------------------------------";
yum install -y epel-release

#SELENIUM
echo "----------------- INSTALLING GOOGLE CHROME STABLE ----------------";
echo "---------------------------------------------------";
yum install -y google-chrome-stable

#BOTH
echo "----------------- INSTALLING NGINX ----------------"
echo "---------------------------------------------------"
yum install -y nginx
systemctl enable nginx
systemctl start nginx

#BOTH
echo "----------------- INSTALLING SUPERVISORD ----------------";
echo "---------------------------------------------------";
yum install supervisor
systemctl enable supervisord
systemctl start supervisord

#SELENIUM
echo "----------------- INSTALLING SUPERVISOR, GTK3, XORG, DBUS ----------------";
echo "---------------------------------------------------";
yum install -y gtk3 supervisor xorg-x11-font-utils xorg-x11-fonts* dbus-x11 xorg-x11-server-Xvfb

echo "--------------- Verifying working versions ----------------";
s=$(supervisord --version)
if [[ ! -z "$s" ]]; then echo "Supervisord: $s"; else echo "WARNING: could not find $i working version"; fi;

#echo "--------------- Verifying supervisord working version ----------------";
#s=$(supervisord --verion)
#if [[ ! -z "$s" ]]; then echo "SU: $s"; else echo "WARNING: could not find RabbitMQ working version"; f

echo "--------------- Verifying running processes for  nginx, supervisord ----------------";
for i in nginx; do x=$(pgrep -f -n -u $i $i | head -n1); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

for i in supervisord; do x=$(pgrep $i); if [[ ! -z "$x" ]]; then echo "SUCCESS: $i is running with process $x"; else echo "WARNING: Could not find running process for $i"; fi; done

echo "--------------- verifying nginx on 0.0.0.0 --------------";
netstat -anp | grep 0.0.0.0 | egrep 'nginx';
