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

if [ -z "$JBOSS_HOME" ]; then
  JBOSS_HOME=/opt/taobao/jboss
fi

if [ ! -f "$JBOSS_HOME/bin/run.sh" ]; then
  echo "未指定JBOSS_HOME目录"
  exit 1;
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA_HOME=/opt/taobao/java
fi

if [ ! -f "$JAVA_HOME/bin/java" ]; then
  echo "未指定JAVA_HOME目录"
  exit 1;
fi

# 设置变量

DIR_BIN=@dir.core.run@/bin
ORACLE_HOME=@dir.core.run@/oracle
LD_LIBRARY_PATH=@dir.core.run@/libexec:@dir.oracle.home@:@dir.oracle.home@/lib:$LD_LIBRARY_PATH
TNS_ADMIN=@dir.oracle@/network/admin/tnsnames.ora
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
LANG=zh_CN.GB18030


JBOSS_OPTS="-Djboss.server.home.dir=@dir.jboss.server@ -Djboss.server.home.url=file:@url.jboss.server@"
JAVA_OPTS="-server -XX:+UseParNewGC -Xms768m -Xmx1280m -XX:MaxNewSize=128m -XX:NewSize=128m -XX:PermSize=96m -XX:MaxPermSize=128m -XX:+UseConcMarkSweepGC -XX:+CMSPermGenSweepingEnabled -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:CMSInitiatingOccupancyFraction=1 -XX:+CMSIncrementalMode -XX:MaxTenuringThreshold=0 -XX:SurvivorRatio=20000 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0  -XX:CMSIncrementalDutyCycleMin=10 -XX:CMSIncrementalDutyCycle=30 -XX:CMSMarkStackSize=8M -XX:CMSMarkStackSizeMax=32M"

DIR_LOG=@dir.core.loggingRoot@/jboss

FILE_STDOUT_LOG=$DIR_LOG/stdout.log
FILE_STDERR_LOG=$DIR_LOG/stderr.log

# APACHE升级  自动调整apache相关配置
APACHE_VERSION="`/opt/taobao/install/httpd/bin/httpd -v| grep version | awk '{print $3}'`"
APACHE_NEW_VERSION="Apache/2.2.4"
if [ `expr $APACHE_VERSION = $APACHE_NEW_VERSION` -eq 1 ];then
echo "this is new apache version change mod_jk.so"
cp /opt/taobao/install/httpd/modules/mod_jk.so $HOME/@sysname@-run/libexec/
fi

export JAVA_HOME
export JBOSS_HOME
export ORACLE_HOME
export LD_LIBRARY_PATH
export TNS_ADMIN
export NLS_LANG
export LANG

export JAVA_OPTS

# 启/停

start()
{
    STR=`ps -C java -f --width 1000 | grep " $JBOSS_OPTS"`
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
    $JBOSS_HOME/bin/run.sh $JBOSS_OPTS >$FILE_STDOUT_LOG 2>$FILE_STDERR_LOG &
}

stop()
{
    STR=`ps -C java -f --width 2000 | grep " $JBOSS_OPTS"`
    if [ ! -z "$STR" ]; then
        $JBOSS_HOME/bin/shutdown.sh --server=localhost:@jboss.port.naming.jnp@ -S > /dev/null 2>&1
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
        echo -n -e "\rWait Jboss Start: $exptime..."
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
