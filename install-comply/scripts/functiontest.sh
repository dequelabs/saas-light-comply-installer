route_test () {
        x=$(./components/centos7/nc -lk $1 & ./components/centos7/nc -vz -w1 0.0.0.0 $1 &> /dev/null; echo $?; ps -ef | grep "./components/centos7/nc -lk $1" | awk '{print$2}' | xargs kill -9 > /dev/null 2>&1);
            if [[ $x = "0" ]];
                then echo "Port $1 is routable on 0.0.0.0";
                else echo "ERROR: port $1 is not routable on 0.0.0.0. Port $1 is required by comply.";
            fi;
    }
route_test 81
