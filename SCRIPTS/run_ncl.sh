#!/bin/bash
#
# run_ncl.sh
#
# Created on: Mar 17, 2014
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2014)
# Description: This script is intended to subsequently run
# NCL to use the snow and albedo evolution of the former run
# as input (SNOW, SNOWH, SNOWSI, SNOWC, and SNOALB of time
# step 0 of the former run are copied into wrfinput_d01). 
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export NCARG_ROOT=$DIR/../NCL
ncl_file=snow_changes.ncl

dstr=`date +%Y-%m-%d_%H:%M:%S`
log_file=ncl.config.$dstr
echo "###########RUN_NCL##############" >> $log_file
echo "NCL_PATH=$NCARG_ROOT" >> $log_file
echo "NCL_FILE=$ncl_file" >> $log_file
cat "$ncl_file" >> "$log_file" 

$NCARG_ROOT/bin/ncl $ncl_file | tee ncl.mylog.$dstr
