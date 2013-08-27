#!/bin/bash

PROG_NAME=$0
ACTION=$1
TARGETSERVER=$2

usage() {
    echo "Usage: $PROG_NAME start|stop [服务器类�? 如dev-1-1、pay-1-1、paytask-1-1等] [-Ddbmode=prod/dev/test/perf] [-Dloglevel=debug/info/warn/error] [-Dquartz=true/false]"
   
    exit 1;
}

if [ $# -lt 1 ]; then
    usage
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA_HOME=/opt/taobao/java
fi

if [ ! -f "$JAVA_HOME/bin/java" ]; then
  echo "未指定JAVA_HOME目录"
  exit 1;
fi

export JAVA_HOME

DIR_CLOUDENGINE_RUN=$HOME/sphoenix-run
DIR_TARGET=$HOME/sphoenix/target
DIR_SETUP=$DIR_TARGET/deploy
DIR_MINIANT=$DIR_SETUP/miniant
DIR_CLOUDENGINE_HOME=/opt/taobao/cloudengine
DIR_ORACLE_HOME=/opt/taobao/oracle

export CLOUDENGINE_HOME=$DIR_CLOUDENGINE_HOME
export ORACLE_HOME=$DIR_ORACLE_HOME

if [ $ACTION = "start" ]; then
    # 重建Jboss运行环境
    if [ -e $DIR_CLOUDENGINE_RUN ]; then
        rm -rf $DIR_CLOUDENGINE_RUN
    fi

    START_OPT="-Dtargetserver=$TARGETSERVER"
    # echo "ANT HOME :${DIR_MINIANT}"

    java -classpath $DIR_MINIANT/lib/ant-launcher.jar -Dant.home=$DIR_MINIANT $START_OPT $3 $4 $5 $6 $7 $8 $9 org.apache.tools.ant.launch.Launcher -buildfile all.xml deploy

    if [ $? != 0 ]; then
        exit 1;
    fi
fi

#bash $DIR_CLOUDENGINE_RUN/bin/jbossctl.sh $ACTION
