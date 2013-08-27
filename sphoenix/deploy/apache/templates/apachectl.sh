#!/bin/sh

ARGV="$@"

cd `dirname $0`/..
BASE=`pwd`
HOST=`hostname`

HTTPD="/opt/taobao/install/httpd/bin/httpd -f $HOME/@sysname@-run/apache/conf/httpd.conf"

#
# pick up any necessary environment variables
if test -f /opt/taobao/install/httpd/bin/envvars; then
  . /opt/taobao/install/httpd/bin/envvars
fi
#
# a command that outputs a formatted text version of the HTML at the
# url given on the command line.  Designed for lynx, however other
# programs may work.  
LYNX="lynx -dump"
#
# the URL to your server's mod_status status page.  If you do not
# have one, then status and fullstatus will not work.
STATUSURL="http://localhost:80/server-status"
#
# Set this variable to a command that increases the maximum
# number of file descriptors allowed per child process. This is
# critical for configurations that use many file descriptors,
# such as mass vhosting, or a multithreaded server.
ULIMIT_MAX_FILES="ulimit -S -n `ulimit -H -n`"
# --------------------                              --------------------
# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||

# Set the maximum number of file descriptors allowed per child process.
if [ "x$ULIMIT_MAX_FILES" != "x" ] ; then
    $ULIMIT_MAX_FILES
fi

ERROR=0
if [ "x$ARGV" = "x" ] ; then 
    ARGV="-h"
fi

case $ARGV in
start|stop|restart|graceful)
    $HTTPD -k $ARGV
    ERROR=$?
    ;;
startssl|sslstart|start-SSL)
    $HTTPD -k start -DSSL
    ERROR=$?
    ;;
configtest)
    $HTTPD -t
    ERROR=$?
    ;;
status)
    $LYNX $STATUSURL | awk ' /process$/ { print; exit } { print } '
    ;;
fullstatus)
    $LYNX $STATUSURL
    ;;
*)
    $HTTPD $ARGV
    ERROR=$?
esac

exit $ERROR
