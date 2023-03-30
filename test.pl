
#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."/symbol.pm";

my $ll='//REG
reg     [`DW_13-1:0]        data_dly1  ;
//WIRE
wir8e   [`DW_PH-1:0]           tmp_dina  ;
wire    [`DW_PH-1:0]        tmp_dinb  ;

wire   [`DW_13-1:0]        tmp       ;';


my @lines = split(/\n/,$ll);
foreach my $line (@lines){
    if( $line =~ /\s*$symbol::DECL_REGEX\s+/){
        print $line."\n";
    }else{
        #print $line."\n";
    }
}






1;