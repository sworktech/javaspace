#!/bin/bash

echo -------------------------------------------------------------------------
echo Sofa Build/Config/Deploy Script for Linux
echo -------------------------------------------------------------------------

# build
if [ "$1" == "build" ]; then
    mvn clean install -Dmaven.test.skip=true -Denv=$ENV
elif [ "$1" == "qbuild" ]; then
    mvn clean -o install -Dmaven.test.skip=true
fi

# check maven run
if [ "$?" == 1 ]; then
    echo "Error: Maven Running Not Success!";
    echo "Please Check your program!"; 
    exit 1;
fi

# config
CURRENT_DIR=`pwd`
cd assembly/ace/target/sphoenix.ace/config
antxconfig -I -d autoconf/auto-config.xml
cd $CURRENT_DIR

# call additional ant tasks 
java -classpath ./deploy/miniant/lib/ant-launcher.jar -Dant.home=./deploy/miniant org.apache.tools.ant.launch.Launcher -buildfile all.xml $1 $2 $3 $4 $5 $6 $7 $8 $9

