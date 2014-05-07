#!/bin/bash
#
# run_wrf.sh
#
# Created on: Mar 17, 2014
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2014)
# Description: This script is intended to run wrf.exe. 
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WRF_PATH=$DIR/../WRF
LANDUSETBL=$DIR/../TABLES/LANDUSE.TBL
VEGPARMTBL=$DIR/../TABLES/VEGPARM.TBL

dstr=`date +%Y-%m-%d_%H:%M:%S`
log_file=wrf.config.$dstr
echo "###########RUN_WRF##############" >> $log_file
echo "WRF_PATH=$WRF_PATH" >> $log_file

###########
# RUN WRF #
###########
ulimit -s unlimited
cp -f $WRF_PATH/run/* .
cp -f $LANDUSETBL .
cp -f $VEGPARMTBL .
date > time.log.$dstr
./wrf.exe 2>&1 | tee wrf.mylog.$dstr 
date >> time.log.$dstr
FILES=`ls $WRF_PATH/run/`
for FILE in $FILES
do
	if [ "$FILE" != "LANDUSE.TBL" ] && \
	   [ "$FILE" != "VEGPARM.TBL" ] ; then
	    rm $FILE
        fi
done
#rm wrfbdy*
#rm wrfinput*
#rm wrflowinp*
