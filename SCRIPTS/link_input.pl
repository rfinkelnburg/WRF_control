#!/usr/bin/perl -w
# 
# link_input.pl
#
# Created on: Jan 28, 2009
# Author: Roman Finkelnburg
# Copyright: Roman Finkelnburg (2009)
# Description: This script is links meteorological input files for 
# WPS. If no IFF's are used files have to be ungribed befor metgrid.
#

use strict;
use Date::Simple ('date');
use Date::Calc qw(Add_Delta_Days Delta_Days Days_in_Month);
use Cwd ('abs_path');

#-----------------------------
my $wps_name = "namelist.wps";
my $input_res_hours = 6;
my @file_types = ('FNL', 'FNL2', 'ECMWF_const', 'ECMWF_pl', 'ECMWF_sfc', 'SST1', 'SST2', 'SST3', 'SST4', 'ICE', 'XICE', 'IFF');
#-----------------------------

#prints help text
sub print_help
{
	my @file_types = @_;

	print "$0 $1 $2 $3 $4\n";
	print "\n";
	print "Usage: $0 <PATH> <FILE TYPE> <WPS FILE> <RESOLUTION>\n";
	print "\n";
	print "<WPS FILE>: name of namelist.wps (default ./namelist.wps)\n";
	print "<RESOLUTION>: resolution in hours of input files [>0 and <=24] (default 6)\n";
	print "<PATH>: path to input files (setting required!)\n";
	print "<FILE TYPE>: type of input file (setting required!)\n";
	print "             Known types:\n";

	foreach my $entry (@file_types) {
		print "             $entry\n";
	} 

	print "\n";
}

#generates file name using appropriate syntax
sub gen_file_name
{
	use Switch;

	my $date = shift;
	my $hour = shift;
	my $type = shift;
	my $short_year = $date->year - int($date->year/100)*100;
	my $str  = undef;

	my $check_date1  = Date::Simple->new(str2date('2009-07-01'));
	my $check_date2  = Date::Simple->new(str2date('2008-09-30'));

	switch ($type) {
		case 'FNL'	{
			if($date >= $check_date1) {
				$str = sprintf(
					"%04i/%04i.%02i/fnl_%04i%02i%02i_%02i_00_c",
					$date->year,
					$date->year,
					$date->month,
					$date->year,
					$date->month,
					$date->day,
					$hour);
			} else {
				if(($date < $check_date2) or (($date == $check_date2) and ($hour < 12))) {
					$str = sprintf(
						"%04i/%04i.%02i/fnl_%02i%02i%02i_%02i_00",
						$date->year,
						$date->year,
						$date->month,
						$short_year,
						$date->month,
						$date->day,
						$hour);
				} else {
					$str = sprintf(
						"%04i/%04i.%02i/fnl_%02i%02i%02i_%02i_00_c",
						$date->year,
						$date->year,
						$date->month,
						$short_year,
						$date->month,
						$date->day,
						$hour);

				}
			}
		}
                case 'FNL2'      {
                        if($date >= $check_date1) {
                                $str = sprintf(
                                        "%04i/%04i.%02i/fnl_%04i%02i%02i_%02i_00_c.changed",
                                        $date->year,
                                        $date->year,
                                        $date->month,
                                        $date->year,
                                        $date->month,
                                        $date->day,
                                        $hour);
                        } else {
                                if(($date < $check_date2) or (($date == $check_date2) and ($hour < 12))) {
                                        $str = sprintf(
                                                "%04i/%04i.%02i/fnl_%02i%02i%02i_%02i_00.changed",
                                                $date->year,
                                                $date->year,
                                                $date->month,
                                                $short_year,
                                                $date->month,
                                                $date->day,
                                                $hour);
                                } else {
                                        $str = sprintf(
                                                "%04i/%04i.%02i/fnl_%02i%02i%02i_%02i_00_c.changed",
                                                $date->year,
                                                $date->year,
                                                $date->month,
                                                $short_year,
                                                $date->month,
                                                $date->day,
                                                $hour);

                                }
                        }
                }
 
		case 'ECMWF_pl'	{$str = sprintf("ECMWF_pl_%04i-%02i-%02i.grb", $date->year, $date->month, $date->day)}
		case 'ECMWF_sfc'	{$str = sprintf("ECMWF_sfc_%04i-%02i-%02i.grb", $date->year, $date->month, $date->day)}
		case 'SST1'	{$str = sprintf("para_rtg_sst_grb_hr_0.083.%04i%02i%02i", $date->year, $date->month, $date->day)}
		case 'SST2'	{$str = sprintf("rtg_sst_grb_0.5.%04i%02i%02i", $date->year, $date->month, $date->day)}
		case 'SST3'	{$str = sprintf("rtg_sst_grb_hr_0.083.%04i%02i%02i", $date->year, $date->month, $date->day)}
		case 'SST4'	{$str = sprintf("SST:%04i-%02i-%02i_%02i", $date->year, $date->month, $date->day, $hour)}
		case 'ICE'	{$str = sprintf("ICE:%04i-%02i-%02i_%02i", $date->year, $date->month, $date->day, $hour)}
		case 'XICE'	{$str = sprintf("AMSR_E_L3_SeaIce12km_V??_%04i%02i%02i.grb", $date->year, $date->month, $date->day)}
		case 'IFF'	{$str = sprintf("WRF:%04i-%02i-%02i_%02i", $date->year, $date->month, $date->day, $hour)}
		else 		{print "Unknown file type: $type\n"; exit (0);}
	}

	return $str;
}

#returns first time stamp of search string matching line maching in namelist.wps
sub get_wps_time_info
{
	my $file_name = shift;
	my $search_str = shift;

	#reading time information from file
	open(DAT, $file_name) || die "can't open $file_name: $!";
	my @data=<DAT>;
	close(DAT);

	#zerlegung des time stamp strings
	my @line = grep /$search_str/, @data;
	my @str = split(/'/, $line[0]);
	return $str[1];
}

#checks if directory exists
sub check_dir_exists
{
	my $name = shift;
	if (!opendir(DIR, $name)) {
		return (0);
	}
	closedir(DIR);
	return (1);
}

#checks number of given arguments
sub check_args
{
	my $error = 0;	
	my $arg_num = pop(@_);

	if ($arg_num gt 2) {
		my $input_res_hours = pop(@_);
		if ($input_res_hours > 24 or $input_res_hours <= 0 or ((24 % $input_res_hours) != 0)) {
			print "\nRESOLUTION SETTINGS INCORRECT: $input_res_hours\n";
			$error = 1;
		}
	}
	if ($arg_num gt 1) {
		my $wps_name = pop(@_);
		if (!open(DAT, $wps_name)) {
			print "\nFILE NOT FOUND: $wps_name\n";
			$error = 1;
		}
		close(DAT);
	}

	my $type = pop(@_);
	my $path = pop(@_);
	my @file_types = @_;

	#checking path argument
	my $found = check_dir_exists(abs_path($path));
	if ($found eq 0) {
		print "\nDIRECTORY NOT FOUND: $path\n";
		$error = 1;
	}

	#checking input file type
	$found = 0;
	foreach my $sys_type (@file_types) {
		if ($type eq $sys_type) {
			$found = 1;
		}
	}

	if ($found eq 0) {
		$error = 1;
		print "\nFILE TYPE NOT FOUND: $type\n";
	}

	if ($error eq 0) {
		return;
	}
	
	print_help(@file_types);
	exit (1);
}

#extracting date from given time stamp
sub str2date
{
	my $str = shift;
	my @str = split(/_/,$str);
	return $str[0];
}

#extracting date from given time stamp
sub str2date2
{
	my $str = shift;
	my @str = split(/_/,$str);
	@str = split(/-/,$str[0]);
	return @str;
}

#extracting number of hours from given time stamp
sub str2hour
{
	my $str = shift;
	my @str = split(/_/,$str);
	@str = split(/:/,$str[1]);
	return $str[0];
}

#extracting number of minutes from given time stamp
sub str2minute
{
	my $str = shift;
	my @str = split(/_/,$str);
	@str = split(/:/,$str[1]);
	return $str[1];
}

#extracting number of seconds from given time stamp
sub str2second
{
	my $str = shift;
	my @str = split(/_/,$str);
	@str = split(/:/,$str[1]);
	return $str[2];
}

#generates start values of counting variables for input file list generation
sub gen_start_time_values
{
	my $start = shift;
	my $start_hour = shift;
	my $input_res_hours = shift;
	my $hour_tmp = 0;
	my $date_tmp = 0;

	$hour_tmp = int($start_hour / $input_res_hours) * $input_res_hours;
	$date_tmp = $start;

	return ($date_tmp, $hour_tmp);
}

#generates end values of counting variables for input file list generation
sub gen_end_time_values
{
	my $end = shift;
	my $end_hour = shift;
	my $end_minute = shift;
	my $input_res_hours = shift;
	my $hour_end = $end_hour;
	my $date_end = $end;

	if ($end_minute > 0) {
	  $hour_end++;
	}

	if ($hour_end > (24 - $input_res_hours)) {
		$date_end++;
		$hour_end = 0;
	}

	my $factor = int($hour_end / $input_res_hours);

	if (($hour_end % $input_res_hours) > 0) {
		$factor++;
	}

	$hour_end = $factor * $input_res_hours;

	return ($date_end, $hour_end);
}

#generates input data file list for given format
sub gen_file_list 
{
	use Switch;

	my $start_str = pop(@_);
	my $end_str = pop(@_);
	my $input_res_hours = pop(@_);
	my $type = pop(@_);
	my @file_types = @_;

	#getting time values
	my $start  = Date::Simple->new(str2date($start_str));
	my $end  = Date::Simple->new(str2date($end_str));
	my $start_hour = str2hour($start_str);
	my $end_hour = str2hour($end_str);
	my $end_minute = str2minute($end_str);

	#checking input data resolution settings
	if ($input_res_hours > 24 or $input_res_hours <= 0 or ((24 % $input_res_hours) != 0)) {
		 die "Incorrect setting of input data resolution: $input_res_hours";
	}

	#generate start and end values for loop
	my ($date_tmp, $hour_tmp) = gen_start_time_values($start, $start_hour, $input_res_hours);
	my ($date_end, $hour_end) = gen_end_time_values($end, $end_hour, $end_minute, $input_res_hours);

	#generate input file list
	my $year_tmp = 0;
	my $fnl_name = '';
	my $limit = 24 - $input_res_hours;
	my @filelist;

	do {
		if ($date_tmp == $end){
			$limit = $hour_end;
		} 
		do {	
			switch ($type) {
				case ($file_types[0])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[1])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[3])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[4])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[5])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[6])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[7])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[8])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[9])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[10])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				case ($file_types[11])	{push(@filelist, gen_file_name($date_tmp, $hour_tmp, $type))}
				else 			{print "File type $type is not implemented yet!\n"; exit(0);}
			}
			$hour_tmp += $input_res_hours;
		} until ($hour_tmp > $limit);

		$hour_tmp = 0;
		$date_tmp++;

	} until ($date_tmp gt $date_end);
	
	return @filelist;
}

##################################################
##################MAIN PROGRAM####################
##################################################

#checking given arguments
if ($#ARGV lt 1 or $#ARGV gt 3) {
	print "\nINCORRECT NUMBER OF ARGUMENTS\n";
	print_help(@file_types);
	exit(1);
}
check_args(@file_types, @ARGV, $#ARGV);

#extracting arguments
my $data_path = abs_path($ARGV[0]);
my $file_type = $ARGV[1];
if ($#ARGV gt 1) {
	$wps_name = $ARGV[2]
}
if ($#ARGV gt 2) {
	$input_res_hours = $ARGV[3]
}

#reading time information from namlist.wps
my $start_str = get_wps_time_info($wps_name, 'start_date');
my $end_str = get_wps_time_info($wps_name, 'end_date');

#print out time settings
print "Start time: $start_str\n";
print "End time  : $end_str\n";

#generating input file list
switch ($file_type) {
	case ('ECMWF_const') {
		my $cmd_str = sprintf("cp %s/ECMWF_lsm_1989-01-01_12.grb .", $data_path);
		print $cmd_str."\n";
		system($cmd_str);
	
		$cmd_str = sprintf("cp %s/ECMWF_z_1989-01-01_12.grb .", $data_path);
		print $cmd_str."\n";
		system($cmd_str);
	}
	else {
		my @filelist = gen_file_list(@file_types, $file_type, $input_res_hours, $end_str, $start_str);

		#checking existence of input files and linking into current folder
		foreach my $file (@filelist) {
			my $filename = sprintf("%s/%s", $data_path, $file);

			print "$filename\n";
			my $cmd_str = sprintf("cp %s* .", $filename);
			system($cmd_str);
		}
	}
}

exit(0);
