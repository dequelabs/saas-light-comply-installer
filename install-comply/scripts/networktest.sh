for i in 81 82 83 84 85 80; 
    do x=$(./components/centos7/nc -lk $i & ./components/centos7/nc -vz -w1 0.0.0.0 $i &> /dev/null; echo $?; ps -ef | grep "./components/centos7/nc -lk $i" | awk '{print$2}' | xargs kill -9 > /dev/null 2>&1); 
        if [[ $x = "0" ]]; 
            then echo "Port $i is routable on 0.0.0.0"; 
            else echo "ERROR: port $i is not routable on 0.0.0.0. Port $i is required by comply."; 
        fi;  
    done
