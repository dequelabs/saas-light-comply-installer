if [[ $1 != "core" ]] && [[ $1 != "selenium" ]];
    then echo "This post-install script must be run with one argument which must be either "core" or "selenium".";
        exit 1;
    else

cd /opt
./worldspace/bin/db_upgrade.sh
./worldspace/components/keycloak/bin/firstrun.sh

chown -R worldspace:worldspace /opt/worldspace

        case "$1" in
        "core" ) 
                 cat scripts/components/core-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                 sed -i 's/autostart=false/autostart=true/g' /etc/supervisord.d/comply.ini
                 supervisorctl reload
                 supervisorctl start all
                 supervisorctl status
                 systemctl restart nginx
                 ;;

        "selenium" )
                     cat scripts/components/selenium-init-edit.txt | while read p n; do sed -i "/$p/,+$n"d"" /etc/supervisord.d/comply.ini; done
                     sed -i 's/autostart=false/autostart=true/g' /etc/supervisord.d/comply.ini
                     supervisorctl reload
                     supervisorctl start all
                     supervisorctl status
                     ;;
        esac

fi
