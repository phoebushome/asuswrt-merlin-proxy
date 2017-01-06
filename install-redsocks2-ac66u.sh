#!/bin/sh

#--------------------------------------------------------------------------------------------------------
# Version 1.0:
# Feature:	Using redsocks2 to determine the gfwed traffic and auto redirect to the shadowsock proxy,
#		No need to maintain the black list.
#		Using the shadowsocks function in the redsocks2 to relay the proxy traffic and DNS requset
#		No need to use ss-local and ss-tunnel.
#---------------------------------------------------------------------------------------------------------
# Variable definitions

ask_yes_or_no() {
    read -p "$1 ([y]es or [n]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

BOLD="\033[42;1m"
NORM="\033[0m"
INFO="$BOLD Info: $NORM"
ERROR="$BOLD Error: $NORM"
LOCALIP=192.168.1.1
LOCALPORT=3080
PREFIX="/jffs"

# Instruction
  echo
  echo -e "\033[41;37m Redsocks2 auto install script for RT-AC66U version 1.0\033[0m"
  echo
  echo -e $INFO This script will guide you to config the redsocks2 on your router.
  echo -e $INFO When finished, you should have a transparent network enviroment to access gfwed internet.
  echo -e $INFO Script only create folders and files \in\ your jffs partion.
  echo -e $INFO Make sure you have enabled JFFS partition and checked "JFFS custom scripts and configs".


# Decteting if jffs partion is enabled
if [ ! -d /jffs/scripts ]
then
  nvram set jffs2_on=1
  nvram set jffs2_format=1
  nvram set jffs2_scripts=1
  nvram commit
  echo -e "$ERROR you have to reboot the router and try again. Exiting..."
  exit 1
fi


#Set shadowsocks config password
  echo "============================================"
  echo "Please input your shadowsocks account imformation:"
  read -p "(Your Server IP):" SERVERIP
  read -p "(Your Server Port):" SERVERPORT
  read -p "(Your Password):" SERVERPW
  read -p "(Your Encryption Method):" SERVERMETHOD
  echo "============================================"
  echo "Please confirm your shadowsocks imformation:"
  echo -e "Your Server IP: \033[41;37m ${SERVERIP} \033[0m"
  echo -e "Your Server Port: \033[41;37m ${SERVERPORT} \033[0m"
  echo -e "Your Password: \033[41;37m ${SERVERPW} \033[0m"
  echo -e "Your Encryption Method: \033[41;37m ${SERVERMETHOD} \033[0m"
  echo "============================================"

echo -e $INFO Please confirm your shadowsocks imformation with "\033[4m yes \033[0m"  or "\033[4m no \033[0m"  to exit
if [ "no" == $(ask_yes_or_no "Is your config above correct?") ]; then
  echo -e $INFO please re-run the script to input the correct information of you shadowsocks account...
  echo -e $INFO Exiting...
  exit 0
fi
#------------------------------------------------------------------------------------
# Install redsocks2...
echo -e $INFO Install redsocks2...
mkdir -p ${PREFIX}/redsocks2
cp ./binary/mipsel/redsocks2/redsocks2-release-0.60-27 ${PREFIX}/redsocks2/redsocks2
cp ./binary/shell/redsocks2/* ${PREFIX}/redsocks2
chmod +x ${PREFIX}/redsocks2/redsocks2 ${PREFIX}/redsocks2/redsocks.sh ${PREFIX}/redsocks2/uninstall.sh


# Config redsocks2...
echo -e $INFO Creating redsocks config file...
cat > ${PREFIX}/redsocks2/redsocks2.conf <<EOF
base {
  log_debug = off; 
  log_info = on;
  //log = "file:${PREFIX}/redsocks2/redsocks2.log";
  daemon = on;
  redirector= iptables;
}

redsocks {
  local_ip = ${LOCALIP};
  local_port = ${LOCALPORT};
  ip = ${SERVERIP};
  port = ${SERVERPORT};
  type = shadowsocks;
  timeout = 3;
  autoproxy = 1;
  login = "${SERVERMETHOD}";
  password = "${SERVERPW}";
}

autoproxy {
  no_quick_check_seconds = 0;
  quick_connect_timeout = 1;
}

ipcache {
  cache_size = 8;
  cache_file = "${PREFIX}/redsocks2/ipcache.txt";
  stale_time = 7200;
  autosave_interval = 3600;
  port_check = 1;
}

EOF

#------------------------------------------------------------------------------------
# Add service to auto start
echo -e $INFO Adding service to wan-start...
if [ -f /jffs/scripts/wan-start ]; then
cat >> /jffs/scripts/wan-start <<EOF
${PREFIX}/redsocks2/redsocks.sh start
EOF

else
cat > /jffs/scripts/wan-start <<EOF
#!/bin/sh
${PREFIX}/redsocks2/redsocks.sh start
EOF
fi
chmod +x /jffs/scripts/wan-start
#------------------------------------------------------------------------------------
# Start service
echo -e $INFO Starting service...
${PREFIX}/redsocks2/redsocks.sh start
#------------------------------------------------------------------------------------

echo -e $INFO Congratulation!
echo -e $INFO Run "\033[42;4m" sh ${PREFIX}/redsocks2/redsocks.sh "\033[0m" to start/stop the service
echo -e $INFO Run "\033[42;4m" sh ${PREFIX}/redsocks2/uninstall.sh "\033[0m" to uninstall the service
echo -e $INFO First time of visiting gfwed website will be a little bit slow due to the "autoproxy" 
echo -e $INFO \function\ of redsocks2, it will be smooth enough afterwards.
echo -e $INFO Enjoy surfing internet without "Great Fire Wall"!


