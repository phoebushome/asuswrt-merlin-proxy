#!/bin/ash

REDSOCKSFOLDER=/jffs/redsocks2
CONFIG=${REDSOCKSFOLDER}/redsocks2.conf
LOCALPORT=`awk -F'[= ;]+' '/local_port/{print $3;exit}' ${CONFIG}`
SERVERIP=`awk -F'[= ;]+' '$2=="ip"{print $3;exit}' ${CONFIG}`
 
add_fw(){
    del_fw
    # Create new chain Shadowsocks
    iptables -t nat -N REDSOCKS2
    # Ignore LANs IP address
    #iptables -t nat -A REDSOCKS2 -d 0.0.0.0/8 -j RETURN
    #iptables -t nat -A REDSOCKS2 -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A REDSOCKS2 -d 127.0.0.0/8 -j RETURN
    #iptables -t nat -A REDSOCKS2 -d 169.254.0.0/16 -j RETURN
    #iptables -t nat -A REDSOCKS2 -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A REDSOCKS2 -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A REDSOCKS2 -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A REDSOCKS2 -d 240.0.0.0/4 -j RETURN
    # Ignore VPS IP address
    iptables -t nat -A REDSOCKS2 -d ${SERVERIP} -j RETURN
    # Transmit to the VPS
    iptables -t nat -A REDSOCKS2 -p tcp -j REDIRECT --to-ports ${LOCALPORT}
    iptables -t nat -A PREROUTING -p tcp -j REDSOCKS2
}
del_fw(){
    iptables -t nat -D PREROUTING -p tcp -j REDSOCKS2 2>/dev/null
    iptables -t nat -F REDSOCKS2 2>/dev/null && iptables -t nat -X REDSOCKS2
}
start_red(){
    add_fw
    touch ${REDSOCKSFOLDER}/ipcache.txt
    ${REDSOCKSFOLDER}/redsocks2 -c ${CONFIG} -p /var/run/redsocks2.pid
}
stop_red(){
    del_fw
    killall redsocks2
}
 
[ $# -eq 0 ] && echo "script start|stop|restart" && exit
 
if [ $1 = "start" ]; then
    start_red
elif [ $1 = "stop" ]; then
    stop_red
elif [ $1 = "restart" ]; then
    stop_red
    start_red
elif [ $1 = "fw" ]; then
    add_fw
else
    echo "$0 start|stop|restart"
fi
