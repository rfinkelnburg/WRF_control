#!/bin/bash
#
# run_real.sh
#
# Created on: Mar 17, 2014
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2014)
# Description: This script is intended to run real.exe.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WRF_PATH_REAL=$DIR/../WRF

dstr=`date +%Y-%m-%d_%H:%M:%S`
log_file=real.config.$dstr
echo "###########RUN_REAL#############" >> $log_file
echo "WRF_PATH_REAL=$WRF_PATH_REAL" >> $log_file
echo "NAMELIST.INPUT:" >> $log_file
cat namelist.input >> $log_file

############
# REAL.EXE #
############
cp -f $WRF_PATH_REAL/run/real.exe .
./real.exe 2>&1 | tee real.mylog.$dstr 
rm real.exe  
rm met_em*
