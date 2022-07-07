#!/bin/bash

var="Hello World"
 
# print it 
echo "$var"
sudo apt update -y
echo "-------Install apache2----"
sudo apt-get install apache2
apache2Status=` service apache2 status|grep "Active: active (running)"|wc -l`
echo "============================================"
if [ $apache2Status -eq 1 ]
then
	echo " Apache2 server has been running"
else
	echo " Apache2 server has not been running"
fi

echo "==========================================="

myTmpFolder=$(date '+%d%m%Y-%H%M%S')
echo "myTmpFolder-->$myTmpFolder"
mkdir -p /tmp/venkata-httpd-logs-$myTmpFolder
sleep 1
# Installing awscli
sudo apt update
sudo apt install awscli
cp  /var/log/apache2/*.log /tmp/venkata-httpd-logs-$myTmpFolder
tar -cvf  /tmp/venkata-httpd-logs-$myTmpFolder.tar /tmp/venkata-httpd-logs-$myTmpFolder
aws s3 cp /tmp/venkata-httpd-logs-$myTmpFolder.tar s3://upgrad-venkata2501/
