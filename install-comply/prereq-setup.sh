#!/bin/bash
if [[ $1 != "core" ]] && [[ $1 != "selenium" ]];
    then echo "This pre-install script must be run with one argument which must be either "core" or "selenium".";
        exit 1;
    else 

        yum install nc -y
        yum install bind-utils -y

        if [[ $? = "0" ]];
            then
                route_test () {
                    x=$(./scripts/components/centos7/nc -lk $1 & ./scripts/components/centos7/nc -vz -w1 0.0.0.0 $1 &> /dev/null; echo $?; ps -ef | grep "./scripts/components/centos7/nc -lk $1" | awk '{print$2}' | xargs kill -9 > /dev/null 2>&1);
                        if [[ $x = "0" ]];
                            then echo "Port $1 is routable on 0.0.0.0";
                            else echo "ERROR: port $1 is not routable on 0.0.0.0. Port $1 is required by comply.";
                        fi;
                    }
            else
                echo "Netcat could not be installed for network routability check. Skipping network check."
        fi


# DB connectivity test: Needs a loop to check the value of dbtype, set port accordingly or exit loop, if no exit confirm DB connect check
#dbhost=$(grep dbhost scripts/components/install.options.core | awk -F'=' '{print$2}') ^C
#./scripts/components/centos7/nc -vz -w1 $dbhost 3306

#DNS resolution test: check if public IP matches resolution for wspublic in install.options
#mydns=$(grep wspublic scripts/components/install.options.core | awk -F'=' '{print$2}')
#myip=$(curl ipinfo.io/ip)
#       if [ "$mydns" = "$myip" ]; 
#           then
#               echo "This servers public IP correctly resolves for wspublic setting: $wspublic" 
#           else
#               echo "WARNING: This servers public IP DOES NOT RESOLVE for wspublic setting: $wspublic"
#       fi           

        echo "Installing pre-requistes for comply $1";
        cp ./scripts/components/centos7/mongodb.repo /etc/yum.repos.d;

        chmod 755 ./scripts/*;
    
        case "$1" in
        "core" ) 
                 yum install nc -y

                 if [[ $? = "0" ]];
                     then
                         route_test () {
                             x=$(./scripts/components/centos7/nc -lk $1 & ./scripts/components/centos7/nc -vz -w1 0.0.0.0 $1 &> /dev/null; echo $?; ps -ef | grep "./scripts/components/centos7/nc -lk $1" | awk '{print$2}' | xargs kill -9 > /dev/null 2>&1);
                                 if [[ $x = "0" ]];
                                     then echo "Port $1 is routable on 0.0.0.0";
                                     else echo "ERROR: port $1 is not routable on 0.0.0.0. Port $1 is required by comply.";
                                 fi;
                         }
                         
                         echo "Running network routability check for comply core requisite ports."
                         for n in 80 443 6379 5672 15672 8095 8761 27017; do sleep 1; route_test $n; done    
                     else
                         echo "Netcat could not be installed for network routability check. Skipping network check."
                 fi

                 echo "Installing pre-requistes for comply $1";
                 cp ./scripts/components/centos7/mongodb.repo /etc/yum.repos.d;
                 cp ./scripts/components/centos7/google-chrome.repo /etc/yum.repos.d;
                 ;;

        "selenium" )
                    echo "Installing pre-requistes for comply $1";
                    cp ./scripts/components/centos7/google-chrome.repo /etc/yum.repos.d;
                    repoquery --requires --resolve google-chrome-stable | xargs sudo yum -y install;
                    rpm -i ./scripts/components/centos7/google-chrome-stable-69.0.3497.100-1.x86_64.rpm
                    cp ./scripts/components/centos7/mongodb.repo /etc/yum.repos.d;
                    cp ./scripts/components/centos7/google-chrome.repo /etc/yum.repos.d;
                    ;;

        esac

        ./scripts/$1.setup.sh;

fi

