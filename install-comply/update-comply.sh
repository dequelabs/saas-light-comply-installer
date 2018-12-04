#!/bin/bash
if [[ $1 != "core" ]] && [[ $1 != "selenium" ]];
    then echo "This install script must be run with one argument which must be either "core" or "selenium".";
        exit 1;
    else

        VERSION=$2
        COMPLYINSTALLER="comply-$VERSION-linux-x64-installer.run"

        case "$1" in
        "core" )
                 service filebeat stop;
                 echo "copying install.options from /opt.."
                 cp /opt/install.options ./
                 echo "Uninstalling comply core..."
                 ./opt/worldspace/uninstall
                 rm -rf /opt/worldspace
                 cp ./install.options /opt
                 cd /opt;
                 echo "Retreiving comply bitrock installer from s3.."
                 aws s3 cp s3://comply-ci/$COMPLYINSTALLER ./$COMPLYINSTALLER
                 chmod 755 ./$COMPLYINSTALLER
                 echo "------------------- Executing $COMPLYINSTALLER"
                 echo "----------------------------------------------------"
                 ./$COMPLYINSTALLER --mode unattended --optionfile ./install.options
                 echo "------------------- Executing ./worldspace/bin/db_upgrade.sh"
                 echo "------------------------------------------------------------"
                 ./worldspace/bin/db_upgrade.sh
                 chown -R worldspace:worldspace /opt/worldspace
                 cd -;
                 echo "------------------- Executing /etc/supervisord.d/comply.ini edits... ---------"
                 echo "------------------------------------------------------------------------------"
                 cat scripts/components/core-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                 sed -i 's/autostart=false/autostart=true/g' /etc/supervisord.d/comply.ini
                 echo "------------------ Check supervisorctl service status ------------------------"
                 echo "------------------------------------------------------------------------------"
                 supervisorctl reload
                 supervisorctl status
                 sed -i 's.7/custom-rules.7.g' /opt/worldspace/mounts/nginx/conf.d/comply.conf
                 systemctl restart nginx
                 chown -R worldspace:worldspace /opt/worldspace
                 service filebeat start;
                 ;;

        "selenium" )
                     service filebeat stop;
                     echo "copying install.options from /opt.."
                     cp /opt/install.options ./
                     echo "Uninstalling comply core..."
                     ./opt/worldspace/uninstall
                     rm -rf /opt/worldspace
                     cp ./install.options /opt
                     cd /opt;
                     echo "Retreiving comply bitrock installer from s3.."
                     aws s3 cp s3://comply-ci/$COMPLYINSTALLER ./$COMPLYINSTALLER
                     chmod 755 ./$COMPLYINSTALLER
                     echo "------------------- Executing $COMPLYINSTALLER"
                     echo "----------------------------------------------------"
                     ./$COMPLYINSTALLER --mode unattended --optionfile ./install.options
                     chown -R worldspace:worldspace /opt/worldspace
                     cd -;
                     echo "------------------- Executing /etc/supervisord.d/comply.ini edits..."
                     echo "------------------------------------------------------------------------------"
                     cat scripts/components/selenium-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                     sed -i 's/autostart=false/autostart=true/g' /etc/supervisord.d/comply.ini
                     echo "------------------ Check supervisorctl service status ------------------------"
                     echo "------------------------------------------------------------------------------"
                     supervisorctl reload
                     supervisorctl status
                     chown -R worldspace:worldspace /opt/worldspace
                     echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
                     sysctl vm.overcommit_memory=1
                     service filebeat start;
                     ;;
        esac

fi

