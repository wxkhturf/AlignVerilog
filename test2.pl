#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."/symbol.pm";





my $ll1='always@(posedge clk)
if(!rst_n)
    begin
        functions <= 0;  parameters <= 0;
    end
    else if(start_poly) 
        begin
            functions <= ins[4:3];  parameters <= ins[2:1];
        functions <= ins[4:3]; parameters <= ins[2:1];
            functions <=    ins[4:3];  parameters <= ins[2:1];
        end
endmodule
    else
    begin
        functions <= functions; parameters <= parameters;
    end

    assign slfdjl
    ';

my $ll2 = 'always@(posedge clk)
if(!rst_n)
    begin
        functions <= 0;  parameters <= 0;
    end
    assign a = b;
';


my $NO_ELSE = 3;#如果连续3行没有检测到else,则认为if结束

my @lines = split(/\n/,$ll1);
my $cnt = 0;
while($cnt < scalar(@lines)){
    $lines[$cnt] = $lines[$cnt] . "\n";
    ++$cnt;
}
#######################################################################
my @level = get_level(@lines);
#print @level;
my @output = part_align(@lines);
print @output;


########################################################################
sub get_level{
    my @lines = @_; 
    #initial array
    #my @level = (0) x scalar(@lines);#这个初始化数组为全0
    my @level;

    my $cnt_level = 0;
    #while($cnt < scalar(@lines)){
    foreach my $line (@lines){
        $cnt_level =level_cal($cnt_level, $line);
        push(@level,$cnt_level);
    }
    return @level;
}
sub level_cal{
    (my $cnt_level, my $line) = @_;
    $cnt_level = level_cal_begin($cnt_level,$line);
    $cnt_level = level_cal_if($cnt_level,$line);
    $cnt_level = level_cal_case($cnt_level,$line);
    return $cnt_level;
}

#begin-end计数(这里不是对齐里的层,不计数if-else,
#因为always块中可以只有if没有else)
sub level_cal_begin{
    (my $cnt_be, my $line) = @_;
    ##################################################
    #begin
    my $tmp = () = $line =~ /\sbegin\s/g;
    $tmp = $tmp +(() = $line =~ /^begin\s/g);
    $cnt_be = $cnt_be + $tmp;
    ##################################################
    ##################################################
    #end
    $tmp = () = $line =~ /\send\s/g;
    $tmp = $tmp +(() = $line =~ /^end\s/g);
    $cnt_be = $cnt_be - $tmp;
    ##################################################
    return $cnt_be;
}

#if-else计数
#因为always块中可以只有if没有else
#所以对与这种可有可无的东西,需要对齐计数以判断always过程块结束
#下面的cnt_ie表示count_if_else
sub level_cal_if{
    (my $cnt_ie, my $line) = @_;
    ##################################################
    #begin
    my $tmp = () = $line =~ /\sif(\s|\()/g;
    $tmp = $tmp +(() = $line =~ /^if(\s|\()/g);
    $cnt_ie = $cnt_ie + $tmp;
    ##################################################
    ##################################################
    #end
    $tmp = () = $line =~ /\selse\s/g;
    $tmp = $tmp +(() = $line =~ /^else\s/g);
    $cnt_ie = $cnt_ie - $tmp;
    ##################################################
    return $cnt_ie;
}

#case--endcase
sub level_cal_case{
    (my $cnt_ce, my $line) = @_;
    ##################################################
    #begin
    #由于casex和casez都包括'case'字符串,且都以endcase结束
    my $tmp = () = $line =~ /\scase[xz]*(\s|\()/g;
    $tmp = $tmp +(() = $line =~ /^case[xz]*(\s|\()/g);
    $cnt_ce = $cnt_ce + $tmp;
    ##################################################
    ##################################################
    #end
    $tmp = () = $line =~ /\sendcase\s/g;
    $tmp = $tmp +(() = $line =~ /^endcase\s/g);
    $cnt_ce = $cnt_ce - $tmp;
    ##################################################
    return $cnt_ce;
}