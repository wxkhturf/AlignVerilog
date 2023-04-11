
#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."/symbol.pm";





my $ll='if(!rst_n)
jslfjif
if
shit if
    begin
        functions <= 0;  parameters <= 0;
    end
    else if(start_poly) 
        begin
            functions <= ins[4:3];  parameters <= ins[2:1];
        end 
    else
    begin
        functions <= functions; parameters <= parameters;
    end
//REG
wire   [`DW_13-1:0]        tmp       ;
case
casex
casez
';



my @lines = split(/\n/,$ll);

#initial array
#my @level = (0) x scalar(@lines);#这个初始化数组为全0
my @level;

my $cnt = 0;
my $cnt_level = 0;
while($cnt < scalar(@lines)){
    my $line = $lines[$cnt];
    # if($line =~ /case[xz]*/){
    #     print $line."\n";
    # }
    #if($line =~ /(^if|\sif)(\s|\(/ ){
    if($line =~ /(^if|\sif)(\s|\()/){
    #if($line =~ /(^if|\sif)+(\s|\()+/ ){
        print $line."\n";
    }

    ++ $cnt;
    
}








1;