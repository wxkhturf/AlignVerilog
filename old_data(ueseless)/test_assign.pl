#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."./assign.pm";

my $in="assign  >>>  ( 1'b 1)tmp_dina[  `DW_13*0+ : `DW_13]  > {data_dly1}                    - ram1_douta[`DW_13*0 +: `DW_13] ;
assign tmp_dina[`DW_13*2+  :`DW_13]>= ram1_doutxx [`DW_13*1 +: `DW_13] - ram1_douta[`DW_13*2 +: `DW_13] ;
";


my @lines = split("\n",$in);

#operator RegEx and txt
my @OP_REG_1=('=', '\+', '-', '\*', '\/', '%', '<' , '>', '!', '&', '\|', '~', '\^', '\?', ':');
my @OP_TXT_1=('=', '+' , '-', '*' , '/' , '%', '<' , '>', '!', '&', '|' , '~', '^' , '?' , ':');

my @OP_REG_2=('>\s+=', '<\s+=', '&\s+&', '\|\s+\|', '=\s+=', '!\s+=', '\^\s+~', '~\s+\^', '~\s+&', '~\|', '<\s+<', '>\s+>');
my @OP_TXT_2=('>='   , '<='   ,  '&&'  , '||'     , '=='   ,  '!='  , '^~'    , '~^'    , '~&'   , '~|' , '<<'   ,  '>>'   );

my @OP_REG_3=('<\s+<', '>\s+>', '=\s+=');
my @OP_TXT_3=('<<'   , '>>'   , '=='   );

#other non-operator RegEx
#'+ :' => ' +: '
#JS:Jack Sparrow
my @OP_REG_JS1=('\+\s+:', ';'  , '\(\s*', '\s*\)', '\[\s*', '\s*\]', '{\s*', '\s*}'    );
my @OP_TXT_JS1=('+:'    , ' ; ', ' ('   , ') '   , ' ['   , '] '   , ' {'  , '} '   );
my @OP_REG_JS2=('\(\s+\(', '\)\s+\)', '{\s+{', '}\s+}',                          );
my @OP_TXT_JS2=('(('     , '))'     , '{{'   , '}}'   ,                    );

my $SPACE=' ';

foreach my $line (@lines){

  my $num = 0;
  #------------------------------------------------------------------------
  #1 operator
  #先替换'>'和'=',之后再替换'>=',同时还有'<'和'<='
  #Verilog中'> ='会报错,必须写成'>=':see ./src/operators(Verilog-2005).png    
  while ($num < scalar(@OP_REG_1)){
      $line =~ s/$OP_REG_1[$num]/$SPACE$OP_TXT_1[$num]$SPACE/g;
      ++$num;
    }  
  #------------------------------------------------------------------------
  $num = 0;
  while ($num < scalar(@OP_REG_2)){
      $line =~ s/$OP_REG_2[$num]/$OP_TXT_2[$num]/g;
      ++$num;
    }  
  #------------------------------------------------------------------------
  $num = 0;
  while ($num < scalar(@OP_REG_3)){
      $line =~ s/$OP_REG_3[$num]/$OP_TXT_3[$num]/g;
      ++$num;
    }   
  #------------------------------------------------------------------------  
  $num = 0;
  while ($num < scalar(@OP_REG_JS1)){
      $line =~ s/$OP_REG_JS1[$num]/$OP_TXT_JS1[$num]/g;
      ++$num;
    }  
  #------------------------------------------------------------------------ 


  print "\n".$line."\n";

}