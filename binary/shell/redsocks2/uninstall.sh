#!/bin/sh

BOLD="\033[42;1m"
NORM="\033[0m"
INFO="$BOLD Info: $NORM"
ERROR="$BOLD Error: $NORM"
PREFIX="/jffs"

# kill all redsocks2 process
echo
echo -e $INFO stop redsocks2 service...
${PREFIX}/redsocks2/redsocks.sh stop
echo -e $INFO done

clear startup
echo -e $INFO clear service auto start...
sed -i '/jffs\/redsocks2\/sredsocks.sh/ start/d' /jffs/scripts/wan-start
echo -e $INFO done

# Change the work foler
cd ${PREFIX}

# delete redsocks2 folder
echo
echo -e $INFO Delete redsocks2 folder...
rm -rf ${PREFIX}/redsocks2
echo -e $INFO done

