#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."/module.pm";
require $path."/note.pm";
require $path."/assign.pm";
require $path."/decl.pm";
require $path."/block.pm";
require $path."/symbol.pm";

my $ll1='always@(posedge clk)
if( ! rst_n)begin 
functions <    = 0;  parameters <= 0;
end
endmodule
    else if(start_poly) begin
             functions <= ins[4:3];  parameters <= ins[2:1];
        functions <= ins[4:3];  parameters <= ins[2:1];
             functions <= ins[4:3];  parameters <= ins[2:1];
        functions <= ins[4:3];  parameters <= ins[2:1];
        functions <= ins[4:3]; parameters <= ins[2:1];
            functions <=    ins[4:3];  parameters <= ins[2:1];end
    else
    begin
        functions <= functions; parameters <= parameters;
    end

    assign slfdjl
    ';
my $ll2 = 'always@             (*)                     
begin               
if (state  ==  IDLE) 
nextstate  =  BUFFER1  ; 
else if (state  ==  BUFFER1) 
begin
case (functions) 
`NTT    : nextstate = STATE0 ; 
`INTT   : nextstate = STATE7 ; 
`Point  : nextstate = POINT  ; 
default : nextstate = POINT  ; 
endcase
end';
my @lines = split(/\n/,$ll2);
my $cnt = 0;
while($cnt < scalar(@lines)){
    $lines[$cnt] = $lines[$cnt] . "\n";
    ++$cnt;
}
$cnt = 0;
#######################################################################
($cnt,my @result) = block::align_block($cnt,@lines);
print "#"x80;
print "\n";
foreach my $ll (@result){
   print $ll."";
} 
print "#"x60;
print $cnt;