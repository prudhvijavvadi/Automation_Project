#!/bin/bash

 
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
mkdir -p /tmp/httpd-logs-$myTmpFolder
sleep 1
# Installing awscli
sudo apt update
sudo apt install awscli
cp  /var/log/apache2/*.log /tmp/httpd-logs-$myTmpFolder
tar -cvf  /tmp/httpd-logs-$myTmpFolder.tar /tmp/httpd-logs-$myTmpFolder
aws s3 cp /tmp/httpd-logs-$myTmpFolder.tar s3://upgrad-venkata2501/
sudo chmod -R 777 /tmp/httpd-logs-$myTmpFolder.tar
currentTar=/tmp/httpd-logs-$myTmpFolder.tar
htmlFileSize=`ls -l /var/www/html/inventory.html| tr -s ' ' | cut -d ' ' -f 5`
IFS=''
filePrefix='httpd-logs'
cd /tmp
if [ $htmlFileSize -eq 0 ]
then
	ls -lh httpd-logs-*.tar| tr -s ' ' | cut -d ' ' -f 5,9- >fileDirList
	echo "Log Type&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Date Created&ensp;&ensp;&ensp;&ensp;Type&ensp;&ensp;Size  <BR>" >> /var/www/html/inventory.html
	while read line
	do
		fileSize=`echo $line | cut -d' ' -f1`
		fileName=`echo $line | cut -d' ' -f2`
		replace=''
		tarName=`echo $line | sed -e "s/httpd-logs-/$replace/g"`
		tarFileName=`echo $tarName | cut -d'.' -f1`
		extactTarFileName=`echo $tarFileName | cut -d' ' -f2`
		tarFileExt=`echo $tarName | cut -d'.' -f2`
		echo "$filePrefix&ensp;&ensp;&ensp;$extactTarFileName&ensp;&ensp;$tarFileExt&ensp;&ensp;&ensp;$fileSize <BR>"  >> /var/www/html/inventory.html
	done < fileDirList
else
	tarFileName=$myTmpFolder
	tarFileExt='tar'
	fileSize=`ls -lh /tmp/httpd-logs-$myTmpFolder.tar| tr -s ' ' | cut -d ' ' -f 5`

	echo "$filePrefix&ensp;&ensp;&ensp;$$tarFileName&ensp;&ensp;$tarFileExt&ensp;&ensp;&ensp;$fileSize <BR>"  >> /var/www/html/inventory.html

fi
