#!/bin/bash
# 
# run_wps.sh
#
# Created on: Mar 17, 2014
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2014)
# Description: This script is intended to run the WPS by using 
# hourly intermediate format files (IFF's) generated from previous 
# WRF modeling as input. The IFF names should have the format
# 'WRF:yyyy-mm-dd_hh'. The directory comprising the IFF's (IFF_PATH) 
# has to be set before running!!! 
#

IFF_PATH=PATH_TO_IFFS #!!! PLEASE SET IFF_PATH !!!

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WPS_PATH=$DIR/../WPS/
LINKER=$DIR/link_input.pl
METGRIDTBL=$DIR/../TABLES/METGRID.TBL
GEOGRIDTBL=$DIR/../TABLES/GEOGRID.TBL

dstr=`date +%Y-%m-%d_%H:%M:%S`
log_file=wps.config.$dstr
echo "###########RUN_WPS##############" >> $log_file
echo "IFF_PATH=$IFF_PATH" >> $log_file
echo "WPS_PATH=$WPS_PATH" >> $log_file
echo "LINKER=$LINKER" >> $log_file
echo "METGRIDTBL=$METGRIDTBL" >> $log_file
echo "NAMLIST.WPS:" >> $log_file
cat namelist.wps >> $log_file

###########
# GEOGRID #
###########
cp -f $WPS_PATH/geogrid.exe .
cp -f $GEOGRIDTBL GEOGRID.TBL
./geogrid.exe 2>&1 | tee geogrid.mylog.$dstr 
rm geogrid.exe

##########
# UNGRIB #
##########
$LINKER $IFF_PATH IFF ./namelist.wps 1 

###########
# METGRID #
###########
cp -f $WPS_PATH/metgrid.exe .
cp -f $METGRIDTBL .
./metgrid.exe 2>&1 | tee metgrid.mylog.$dstr
rm WRF*
rm metgrid.exe
