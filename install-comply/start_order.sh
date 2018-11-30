#!/bin/bash
chown -R worldspace:worldspace /opt/worldspace
if [[ $1 != "core" ]] && [[ $1 != "selenium" ]];
    then echo "This install script must be run with one argument which must be either "core" or "selenium".";
        exit 1;
    else

        super_startup () {
        echo "Supervisord starting $1..";
        supervisorctl start $1;
        }

        case "$1" in
        "core" )
                 supervisorctl stop all;
                 echo "Stopping all supervisord services, sleeping 30 seconds for service shutdown.."
                 sleep 30;

                 for i in worldspace:keycloak scan-manager:ecp-registry scan-manager:ecp-config-server scan-manager:ecp-custom-rules scan-manager:ecp-gateway scan-manager:ecp-manager worldspace:comply;
                     do 
                         super_startup $i; echo "sleeping 45 seconds while $i launches...";sleep 45; 
                     done

                 echo "Supervisord services startup complete";
                 service filebeat start;
#                 supervisorctl status all;
#                 exit 0;
#                 echo "Tailing comply startup log.."
#                 tail -f /opt/worldspace/logs/worldspace-core.log
                 ;;

        "selenium" )

                         wspublic=$(/opt/install.options | awk -F'=' '{print$2}')

                         route_test () {
                             x=$(./scripts/components/centos7/nc -lk $1 & ./scripts/components/centos7/nc -vz -w1 $wspublic $1 &> /dev/null; echo $?; ps -ef | grep "./scripts/components/centos7/nc -lk $1" | awk '{print$2}' | xargs kill -9 > /dev/null 2>&1);
                                 if [[ $x = "0" ]];
                                     then echo "Port $1 for $2 is routable on $wspublic.";
                                     else echo "ERROR: port $1 is not routable on $wspublic. Unable to reach $2 on $wspublic Port $1.";
                                 fi;
                         }
 

                         echo "Running network routability check for comply core requisite ports."
                         for n in 6379; do sleep 1; route_test $n Redit; done
                         for n in 5672; do sleep 1; route_test $n RabbitMQ; done
                         for n in 15672; do sleep 1; route_test $n RabbitMQ; done
                         for n in 8095; do sleep 1; route_test $n "config service"; done
                         for n in 8761; do sleep 1; route_test $n "registry service"; done
                         for n in 27017; do sleep 1; route_test $n MongoDB; done

                     supervisorctl stop all;
                     echo "Stopping all supervisord services, sleeping 30 seconds for service shutdown.."
                     sleep 30;

                     for i in scan-worker:ecp-proxy scan-worker:ecp-result-processor scan-worker:ecp-selenium scan-worker:ecp-worker
                         do
                             super_startup $i; echo "sleeping 45 seconds while $i launches...";sleep 45;
                         done

                     echo "Supervisord services startup complete";
                     service filebeat start;
 #                    supervisorctl status all;
 #                    exit 0;
                     ;;
     esac
fi
