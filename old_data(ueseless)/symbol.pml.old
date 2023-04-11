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
#用于block检测:如always/forever/initial等


#正则字符串
@BLOCK_BOUNDRY_START = ('if', 'begin','case[xz]*'); 
@BLOCK_BOUNDRY_END   = ('else', 'end','endcase');
#检测到以下开头认为当前block块结束
@THE_HEAD = (@DECL_WORDS,'assign','always','initial','forever','fork','endmodule');
#***************************************************************************************




1;