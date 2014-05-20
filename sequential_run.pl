#!/usr/bin/perl -w
#
# sequential_run.pl
#
# Created on: Mar 17, 2014
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2014)
# Description: This script is intended to run WPS and WRF for consecutive time 
# sequences. run_hours, run_minutes, run_seconds, start_hour, start_minute,
# start_second, end_hour, end_minute, and end_second in ./TEMPLATES/namelist.input.tpl
# have to be set to 0. Furthermore, frames_per_outfile and interval_secondsin have to 
# be set such that frames_per_outfile*interval_seconds=86400, i.e. a new wrf output file 
# is generated every 24h. The path to the hourly intermediate format files (IFF's) input
# has to be set in ./SCRIPTS/run_wps.sh and the path to the static geographical data has
# to be set in ./TEMPLATES/namelist.wps.tpl.  
#

use strict;
use Date::Simple ('date');
use FindBin;

### GENERAL SETTINGS ###
#!!! PLEASE SET PATH's IN ./SCRIPTS/run_wps.sh and ./TEMPLATES/namelist.wps.tpl !!!
my $result_path = "PATH_TO_RESULTS_DIRECORY";  #directory to store results
my $mailaddr    = 'yourname@yourprovider.net'; #mail address (if $mail is set ne 0)

### TIME SETTINGS ###
my $date_start    = Date::Simple->new('2007-09-01'); #start date of consequtive runs
my $date_end      = Date::Simple->new('2008-09-01'); #end date of consecutive runs
my $sequence_days = 30;                              #number of days for one continues run
my $spinup_days   = 1;                               #number of additional days for spin-up

### RESTART AND ADAPTIVE TIME STEP ###
my $restart           = 0;  #set to ne 0 to do a restart from $date_start
my $adaptve_time_step = 1;  #set to ne 0 to use adaptive time step
my $max_time_step     = 12; #set to ne 0 (-1 or positive value) to set maximum adaptive time step

### ERROR HANDLING AND DEBUGGING ###
my $mail  = 0; #set to ne 0 to enable error mailing using ssmtp (see e.g. https://wiki.archlinux.org/index.php/SSMTP)
my $debug = 0; #set to ne 0 to just output commands (no execution)

### PATH TO SCRIPTS AND TEMPLATE FILES (DO NOT EDIT)###
my $TOOLPATH        = $FindBin::Bin;
my $script_path     = "$TOOLPATH/SCRIPTS";
my $namelist_wps    = "$TOOLPATH/TEMPLATES/namelist.wps.tpl";
my $namelist_input  = "$TOOLPATH/TEMPLATES/namelist.input.tpl";
my $snow_change_ncl = "$TOOLPATH/TEMPLATES/snow_changes.ncl.tpl";

##############
#    SUBS    #
##############

sub error_action
{
        my $error_str = sprintf("ERROR: %s", $!);
        if (($mail ne 0) and ($debug eq 0)) {
                my $mail_str = sprintf("echo %s | mail -v -s \"ERROR: WRF Sequential Run\" %s", $error_str, $mailaddr);
                system($mail_str);
        }
        print "$error_str\n";
        exit(1);
}

##############
#    MAIN    #
##############

#generate start and end values for loop
my $str = undef;
my $in = undef;
my $out = undef;
my $found = undef;

#calculate set start and end time for first modelling
my $date_start_tmp = $date_start - $spinup_days;
my $date_end_tmp = $date_start + $sequence_days;

 #########################
 # START SEQUENTIAL RUNS #
 #########################
do {
 if ( $debug ne 1 ) {
	print "***********************\n";
	$str = sprintf("%04i-%02i-%02i", $date_start_tmp->year, $date_start_tmp->month,$date_start_tmp->day);
 	print $str."\n";
	$str = sprintf("%04i-%02i-%02i", $date_end_tmp->year, $date_end_tmp->month,$date_end_tmp->day);
 	print $str."\n";
 }

 ####################
 #        WPS       #
 ####################

 #set WPS start and end time in namelist.wps
 open $in,  '<', $namelist_wps or error_action();
 open $out, '>', "namelist.wps" or error_action();
 while( <$in> )
    {
	$found = 0;
	if ( $_ =~ "start_date" ) {
 		$str = sprintf(" start_date = '%04i-%02i-%02i_00:00:00',\n",
               		$date_start_tmp->year,
               		$date_start_tmp->month,
               		$date_start_tmp->day);
    		print $out $str;
		$found = 1;
	}
	if ( $_ =~ "end_date" ) {
 		$str = sprintf(" end_date = '%04i-%02i-%02i_00:00:00',\n",
               		$date_end_tmp->year,
               		$date_end_tmp->month,
               		$date_end_tmp->day);
    		print $out $str;
		$found = 1;
	}
    	if ( $found eq 0) { print $out $_;}
    }
 close $out;
 close $in;

 #run WPS
 $str = sprintf("%s/run_wps.sh", $script_path);
 if ( $debug eq 0 ) { 
	system($str) == 0 or error_action();
 } else {
 	print $str."\n";
 }

 #####################
 #        REAL       #
 #####################
 #set WRF start and end time
 open $in,  '<', $namelist_input or error_action();
 open $out, '>', "namelist.input" or error_action();
 while( <$in> )
    {
        $found = 0;
        if ( $_ =~ "run_days" ) {
                $str = sprintf(" run_days                            = %i,\n",
                        $date_end_tmp-$date_start_tmp);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "start_year" ) {
                $str = sprintf(" start_year                          = %04i,\n",
                        $date_start_tmp->year);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "start_month" ) {
                $str = sprintf(" start_month                         = %02i,\n",
                        $date_start_tmp->month);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "start_day" ) {
                $str = sprintf(" start_day                           = %02i,\n",
                        $date_start_tmp->day);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "end_year" ) {
                $str = sprintf(" end_year                            = %04i,\n",
                        $date_end_tmp->year);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "end_month" ) {
                $str = sprintf(" end_month                           = %02i,\n",
                        $date_end_tmp->month);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "end_day" ) {
                $str = sprintf(" end_day                             = %02i,\n",
                        $date_end_tmp->day);
                print $out $str;
                $found = 1;
        }
        if ( $_ =~ "use_adaptive_time_step" ) {
		if ( $adaptve_time_step eq 0 ) {
                	$str = sprintf(" use_adaptive_time_step              = .false.,\n");
                	print $out $str;
                	$found = 1;
		} else {
                	$str = sprintf(" use_adaptive_time_step              = .true.,\n");
                	print $out $str;
                	$found = 1;
		}
        }
        if ( ($_ =~ "max_time_step") and ( $max_time_step ne 0) ) {
                $str = sprintf(" max_time_step                       = %i,\n",
                        $max_time_step);
                print $out $str;
                $found = 1;
        }
        if ( $found eq 0) { print $out $_;}
    }
 close $out;
 close $in;

 #run REAL
 $str = sprintf("%s/run_real.sh", $script_path);
 if ( $debug eq 0 ) { 
	system($str) == 0 or error_action();
 } else {
 	print $str."\n";
 }

 ####################
 #        NCL       #
 ####################

 if (($date_start_tmp ne $date_start - $spinup_days) or ($restart ne 0)) {
 	#run NCL
 	open $in,  '<', $snow_change_ncl or error_action();
 	open $out, '>', "snow_changes.ncl" or error_action();
 	while( <$in> )
    	{
        	$found = 0;
        	if ( $_ =~ "wrfout_d" ) {
                	$str = sprintf("        f = addfile(\"%s/wrfout_d01_%04i-%02i-%02i_00:00:00\", \"r\")\n",
                        	$result_path,	
				$date_start_tmp->year,
				$date_start_tmp->month,
				$date_start_tmp->day);
                	print $out $str;
                	$found = 1;
 			if ( $debug ne 0 ) { print "NCL:".$str; }
        	}
        	if ( $found eq 0) { print $out $_;}
    	}
 	close $out;
 	close $in;
	
 	$str = sprintf("%s/run_ncl.sh", $script_path);
 	if ( $debug eq 0 ) { 
		system($str) == 0 or error_action();
 	} else {
 		print $str."\n";
 	}

 }
 
 ####################
 #        WRF       #
 ####################
 #run WRF
 $str = sprintf("%s/run_wrf.sh", $script_path);
 if ( $debug eq 0 ) { 
	system($str) == 0 or error_action();
 } else {
	print $str."\n";
 }

 ##############
 # STORE DATA #
 ##############

 #remove spinup
 $str = sprintf("rm wrfout_d01_%04i-%02i-%02i_00:00:00", 
   		$date_start_tmp->year,
       		$date_start_tmp->month,
               	$date_start_tmp->day);
 if ( $debug eq 0 ) {
	print "***spinup\n"; 
	system($str) == 0 or error_action();
 } else {
	print $str."\n";
 }

 do {
    	$date_start_tmp++;

 	#copy files to result directory
 	$str = sprintf("cp wrfout_d01_%04i-%02i-%02i_00:00:00 %s", 
   		$date_start_tmp->year,
       		$date_start_tmp->month,
               	$date_start_tmp->day, 
		$result_path);
 	if ( $debug eq 0 ) { 
		print $str."\n";
		system($str) == 0 or error_action();
 	} else {
		print $str."\n";
 	}

	#check if file was successfully copies
 	$str = sprintf("diff wrfout_d01_%04i-%02i-%02i_00:00:00 %s/wrfout_d01_%04i-%02i-%02i_00:00:00", 
   		$date_start_tmp->year,
       		$date_start_tmp->month,
               	$date_start_tmp->day, 
		$result_path,
   		$date_start_tmp->year,
       		$date_start_tmp->month,
               	$date_start_tmp->day); 
 	if ( $debug eq 0 ) { 
		print $str."\n";
		system($str) == 0 or error_action();
 	} else {
		print $str."\n";
 	}
	
 	#remove files to NAS
 	$str = sprintf("rm wrfout_d01_%04i-%02i-%02i_00:00:00", 
   		$date_start_tmp->year,
       		$date_start_tmp->month,
               	$date_start_tmp->day);
 	if ( $debug eq 0 ) { 
		print $str."\n";
		system($str) == 0 or error_action();
 	} else {
		print $str."\n";
 	}
 } until ($date_start_tmp eq $date_end_tmp);

 #########################################
 # TIME SETTINGS FOR NEXT MODEL SEQUENCE #
 #########################################
 $date_start_tmp -= $spinup_days;
 $date_end_tmp += $sequence_days;
 if ($date_end_tmp gt $date_end) {$date_end_tmp = $date_end;}

} until ($date_start_tmp ge $date_end - $spinup_days);

if (($mail ne 0) and ($debug eq 0)) {
        my $mail_str = sprintf("echo FINISHED! | mail -v -s \"FINISHED: WRF Sequential Run\" %s", $mailaddr);
        system($mail_str);
}

