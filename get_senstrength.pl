#! /usr/bin/perl
use strict;
use warnings;
use LWP::Simple;

######################################################
# Author: Runwei Qiang <qiangrw@gmail.com>
# Modify: 2012-12-9 
# Description: detect sentiment in domain 
# by site http://sentistrength.wlv.ac.uk/
######################################################

# Usuage and parameter
my $USUAGE = "perl $0 input_file output_file";
my $input_file = shift @ARGV or die $USUAGE;
my $output_file = shift @ARGV or die $USUAGE;

# Some constants
my $ROOT = "http://sentistrength.wlv.ac.uk";
my $DOMAIN = "Film";
my $SUBMIT = "Detect+Sentiment+in+Domain";

open FH,$input_file or die "can not open file $input_file.\n";
open OUT, ">", $output_file or die "can not open file $output_file for write.\n";
open ERROR, ">", "error.log" or die $!;
my $line_no = 0;
my $failed_line = 0;
while(<FH>) {
	$line_no += 1;
	my $query = $_;
	chomp($query);
	# try 10 times
	my $flag = 0;
	my $line;
	foreach(1..10) {
		$line = &get_results($query);
		if(defined $line) {
			$flag = 1;
			last;
		}
		sleep 1; # sleep for more chances 
	}
	if($flag) {
		print OUT $line;
	} else {
		print "fatal error, leave blank for line $line_no. query:$query.\n";
		print ERROR "$query\n";
		print OUT "\n"; # leave blank line
	}
}
print "Cheers,all $line_no lines processed.\n";
close ERROR;
close FH;
close OUT;

#### END OF MAIN ####

# get_results from url
# @param string query
# @return $line || NULL
sub get_results() {
	my $query = $_[0];
	my $url = "$ROOT/results.php?domain=$DOMAIN&submit=$SUBMIT&text=$query";
	my $content = get($url);
	if($content =~ /positive\s+strength\s+\<b\>(\d+)\<\/b\>\s+and\s+negative\s+strength\s+\<b\>-(\d+)\<\/b\>/gi) {
		return "$1\t-$2\n";
	} else {
		return undef;
	}
}



