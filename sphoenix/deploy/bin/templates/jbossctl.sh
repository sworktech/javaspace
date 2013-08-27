#!/bin/bash

# 检查输入

PROG_NAME=$0
ACTION=$1

usage() {
    echo "Usage: $PROG_NAME {start|stop}"
    exit 1;
}

if [ $# -lt 1 ]; then
    usage
fi

# 检查环境

if [ -z "$CLOUDENGINE_HOME" ]; then
  CLOUDENGINE_HOME=/opt/taobao/cloudengine
fi

if [ ! -f "$CLOUDENGINE_HOME/bin/startup.sh" ]; then
  echo "未指定CLOUDENGINE_HOME目录"
  exit 1;
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA_HOME=/opt/taobao/java
fi

if [ ! -f "$JAVA_HOME/bin/java" ]; then
  echo "未指定JAVA_HOME目录"
  exit 1;
fi

# 设置LDC环境变量
if [ -f $HOME/server.conf ]; then
  DBMODE=`grep '^dbmode' $HOME/server.conf | cut -d= -f2 | tr -d ' '`
  ZONE=`grep '^zone' $HOME/server.conf | cut -d= -f2 | tr -d ' '`
  CONFREG_URL=`grep '^confregurl' $HOME/server.conf | cut -d= -f2 | tr -d ' '`
  echo "dbmode=$DBMODE com.alipay.ldc.zone=$ZONE com.alipay.confreg.url=$CONFREG_URL"
fi

# 设置变量
DIR_BIN=@dir.core.run@/bin
ORACLE_HOME=@dir.core.run@/oracle
LD_LIBRARY_PATH=@dir.core.run@/libexec:@dir.oracle.home@:@dir.oracle.home@/lib:$LD_LIBRARY_PATH
TNS_ADMIN=@dir.oracle@/network/admin
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
LANG=zh_CN.GB18030


JAVA_OPTS="-server -Xms1700m -Xmx1700m -Xmn680m -Xss256k -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+UseStringCache -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=4 -XX:+CMSClassUnloadingEnabled -XX:+DisableExplicitGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=68 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/logs -XX:ErrorFile=/home/admin/logs/hs_err_pid%p.log -Dcom.sun.management.jmxremote.port=9981 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
DIR_LOG=/home/admin/logs
JAVA_OPTS="$JAVA_OPTS -Ddbmode=$DBMODE -Dcom.alipay.ldc.zone=$ZONE -Dcom.alipay.confreg.url=$CONFREG_URL"
FILE_STDOUT_LOG=$DIR_LOG/stdout.log
FILE_STDERR_LOG=$DIR_LOG/stderr.log

# APACHE
APACHE_VERSION="`/opt/taobao/install/httpd/bin/httpd -v| grep version | awk '{print $3}'`"
APACHE_NEW_VERSION="Apache/2.2.4"
if [ `expr $APACHE_VERSION = $APACHE_NEW_VERSION` -eq 1 ];then
echo "this is new apache version change mod_jk.so"
cp /opt/taobao/install/httpd/modules/mod_jk.so $HOME/sphoenix-run/libexec/
fi

export JAVA_HOME
DEPLOY_DIR=@dir.core.run@/deploy
WORK_DIR=@dir.core.run@/work

export ORACLE_HOME
export LD_LIBRARY_PATH
export TNS_ADMIN
export NLS_LANG
export LANG

export JAVA_OPTS

# 启/停

start()
{
    STR=`ps -C java -f | grep " $WORK_DIR"`
    if [ ! -z "$STR" ]; then
        echo "有Java进程在运行"
        exit;
    fi

    # 根据需要创建Jboss日志目录
    if [ ! -e $DIR_LOG ] ; then
        mkdir -p $DIR_LOG
    fi

    NOW=`date +%Y%m%d.%H%M%S`
    # 滚动Jboss STDOUT日志
    if [ -e $FILE_STDOUT_LOG ] ; then
        mv $FILE_STDOUT_LOG $FILE_STDOUT_LOG.$NOW
    fi

    # 滚动Jboss STDERR日志
    if [ -e $FILE_STDERR_LOG ] ; then
        mv $FILE_STDERR_LOG $FILE_STDERR_LOG.$NOW
    fi

    # 运行JBOSS
     $CLOUDENGINE_HOME/bin/startup.sh $DEPLOY_DIR $WORK_DIR >$FILE_STDOUT_LOG 2>$FILE_STDERR_LOG &
}

stop()
{
    STR=`ps -C java -f | grep " $WORK_DIR"`
    if [ ! -z "$STR" ]; then
        killall -9 java > /dev/null 2>&1
        bash $DIR_BIN/apachectl.sh stop
    else
        echo "没有Java进程"
    fi
}

wait_for_ready()
{
    exptime=0
    while true
    do
      ret=`fgrep 'Started in' $FILE_STDOUT_LOG`
      if [ -z "$ret" ]; then
        sleep 1
        ((exptime++))
        echo -n -e "\rWait Cloudengine&App Start: $exptime..."
      else
        sleep 3
        bash $DIR_BIN/apachectl.sh restart
        echo "HTTP Restart Done."
        return
      fi
    done
}

case "$ACTION" in
    start)
        start
        wait_for_ready
    ;;
    stop)
        stop
    ;;
    restart)
        stop
        start
        wait_for_ready
    ;;
    *)
        usage
    ;;
esac