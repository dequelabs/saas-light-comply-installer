#!/bin/bash
if [[ $1 != "core" ]] && [[ $1 != "selenium" ]];
    then echo "This install script must be run with one argument which must be either "core" or "selenium".";
        exit 1;
    else

        VERSION=$2
        COMPLYINSTALLER="comply-$VERSION-linux-x64-installer.run"

        case "$1" in
        "core" )
                 mkdir /opt/worldspace
                 #cp scripts/components/install.options.core /opt/install.options
                 
                 cp -Ra ./scripts/components/sslcerts /opt
                 cd /opt;
                 echo "Retreiving comply install.options from s3.."
                 aws s3 cp s3://comply-ci/install.options.core ./install.options
                 sudo chown worldspace:worldspace install.options
                 echo "Retreiving comply bitrock installer from s3.."
                 aws s3 cp s3://comply-ci/bitrock_artifact/$COMPLYINSTALLER ./$COMPLYINSTALLER
                 chmod 755 ./$COMPLYINSTALLER
                 echo "------------------- Executing $COMPLYINSTALLER"
                 echo "----------------------------------------------------"
                 ./$COMPLYINSTALLER --mode unattended --optionfile ./install.options
                 echo "------------------- Executing ./worldspace/bin/db_upgrade.sh"
                 echo "------------------------------------------------------------"
                 ./worldspace/bin/db_upgrade.sh
                 sed -i 's-^/opt/worldspace/components/keycloak/bin/standalone.sh-nohup /opt/worldspace/components/keycloak/bin/standalone.sh-g' /opt/worldspace/components/keycloak/bin/firstrun.sh
                 sed -i 's/OVERWRITE_EXISTING$/OVERWRITE_EXISTING \&/g' /opt/worldspace/components/keycloak/bin/firstrun.sh
                 echo "------------------- Executing ./worldspace/components/keycloak/bin/firstrun.sh"
                 echo "------------------------------------------------------------------------------"
                 chown -R worldspace:worldspace /opt/*
                 ./worldspace/components/keycloak/bin/firstrun.sh > /dev/null &
                 cd -;
                 echo "------------------- Executing /etc/supervisord.d/comply.ini edits... ---------"
                 echo "------------------------------------------------------------------------------"
                 cat scripts/components/core-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                 echo "------------------ Check supervisorctl service status ------------------------"
                 echo "------------------------------------------------------------------------------"
                 supervisorctl reload
                 supervisorctl status
                 sed -i 's.7/custom-rules.7.g' /opt/worldspace/mounts/nginx/conf.d/comply.conf
                 systemctl restart nginx
                 chown -R worldspace:worldspace /opt/*
                 redis-cli CONFIG SET dir /var/lib/redis
                 redis-cli CONFIG SET dbfilename temp.rdb
                 redis-cli BGSAVE
                 echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
                 sysctl vm.overcommit_memory=1
                 rpm -vi scripts/components/filebeat/filebeat-6.5.1-x86_64.rpm
                 \cp -f scripts/components/filebeat/filebeat.yml /etc/filebeat
                 elastichome=kibana.dequelabs.com
                 beatname=$(grep wscorehost /opt/install.options | awk -F'=' '{print$2}' | cut -d"." -f1);
                 ./scripts/name_filebeat.sh $beatname $elastichome
                 ;;

        "selenium" )
                     mkdir /opt/worldspace
                     cp -Ra ./scripts/components/sslcerts /opt
                     cd /opt;
                     echo "Retreiving comply install.options from s3.."
                     aws s3 cp s3://comply-ci/install.options.selenium ./install.options
                     sudo chown worldspace:worldspace install.options
                     echo "Retreiving comply bitrock installer from s3.."
                     aws s3 cp s3://comply-ci/bitrock_artifact/$COMPLYINSTALLER ./$COMPLYINSTALLER
                     chmod 755 ./$COMPLYINSTALLER
                     echo "------------------- Executing $COMPLYINSTALLER"
                     echo "----------------------------------------------------"
                     ./$COMPLYINSTALLER --mode unattended --optionfile ./install.options
                     chown -R worldspace:worldspace /opt/*
                     cd -;
                     echo "------------------- Executing /etc/supervisord.d/comply.ini edits..."
                     echo "------------------------------------------------------------------------------"
                     cat scripts/components/selenium-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                     echo "------------------ Check supervisorctl service status ------------------------"
                     echo "------------------------------------------------------------------------------"
                     supervisorctl reload
                     supervisorctl status
                     chown -R worldspace:worldspace /opt/*
                     echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
                     sysctl vm.overcommit_memory=1
                     rpm -vi scripts/components/filebeat/filebeat-6.5.1-x86_64.rpm
                     \cp -f scripts/components/filebeat/filebeat.yml /etc/filebeat
                     elastichome=kibana.dequelabs.com
                     beatname=$(grep wscorehost /opt/install.options | awk -F'=' '{print$2}' | cut -d"." -f1 | sed 's/core/analysis/g');
                     ./scripts/name_filebeat.sh $beatname $elastichome
                     ;;
        esac

fi

