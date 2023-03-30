#!usr/bin/perl
package symbol;

#用于module检测使用(正则)***************************************************************
@IO=('input','output');
$IO_LEN = 8;

@NET=('wire','reg');
$NET_LEN = 6;

@SQUARE_B=('\[','\]');
#$SQUARE_B_LEN = xxx;
#**************************************************************************************
#用于declaration检测
@DECL_WORDS=('parameter','localparam','input','output',
              'reg','wire','integer','real','logic','bit',
              'int');

#生成DECL_WORDS*********************************************
foreach my $word (@DECL_WORDS){
       if(defined $DECL_REGEX){
              $DECL_REGEX = $DECL_REGEX . '|' . $word;
       }else{
              $DECL_REGEX = $word;
       }
}
$DECL_REGEX = '('.$DECL_REGEX.')';
#***********************************************************
#***************************************************************************************




1;