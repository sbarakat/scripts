#!/bin/sh -e

# Start or stop ASSP
#
# Ivo Schaap <ivo@lineau.nl>

PATH=/bin:/usr/bin:/sbin:/usr/sbin

case "$1" in

    start)
        echo "Starting the Anti-Spam SMTP Proxy"
        cd /opt/assp
        perl assp.pl
    ;;

    stop)
        echo "Stopping the Anti-Spam SMTP Proxy"
        kill -9 `ps ax | grep "perl assp.pl" | grep -v grep | awk '{ print $1 }'`
    ;;

    restart)
        $0 stop || true
        $0 start
    ;;
   
    *)
    echo "Usage: /etc/init.d/assp {start|stop|restart}"
    exit 1
    ;;

esac

exit 0
