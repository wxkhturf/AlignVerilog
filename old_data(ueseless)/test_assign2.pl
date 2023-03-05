#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."./assign.pm";

my $in="assign  >>>  ( 1'b 1)tmp_dina[  `DW_13*0+ : `DW_13]  > {data_dly1}                    - ram1_douta[`DW_13*0 +: `DW_13] ;
assign tmp_dina[`DW_13*2+  :`DW_13]>= ram1_doutxx [`DW_13*1 +: `DW_13] - ram1_douta[`DW_13*2 +: `DW_13] ;
";


my @lines = split("\n",$in);

my @temp;
foreach my $line (@lines){
	#print $line."\n";
	@temp = split(/\s/, $line);
	foreach my $word (@temp){
		print $word."\n";
	}
	print "-"x40;
}