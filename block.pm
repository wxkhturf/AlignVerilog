#!usr/bin/perl

package block;

sub align_block{    
    (my $const_cnt1 , my @lines)  = @_;
    my @output;
    my $const_cnt2;
    my @result;
    #***************************************************************
    #1.扫描block语句,得到($const_cnt1,$const_cnt2]长度的block语句
    #2.得到每列的最大长度
    ($const_cnt2,@output) = head_block($const_cnt1, @lines);
    if($const_cnt2 - $const_cnt1 ne 1){
        @output    = spaceCtr_assign(@output);
    }

    my @len = get_length(@output);
    #print @len;
    #print "\n";
    #****************************************************************
    #有了存储assign语句：@output
    #有了每列的最大长度：@len
    #下面开始执行对齐操作
    my $out_line;
    my @temp;
    my $WORDS_SPACE=1;
    foreach my $line (@output){
        next if($line =~ /^\s+$/);
        #去除前导和拖尾空格,是为了split(\s),因为去了才能方便计数
        $line =~ s/^\s+|\s+$//g ;
        @temp = split(/\s+/, $line);
        my $cnt = 0;
        if($temp[0] =~ /^assign$/){
            $out_line = shift(@temp).' ';
        }else{
            $out_line = ' 'x8;
        }

        foreach my $word (@temp){
            $out_line = $out_line . $word . ' 'x($len[$cnt] - length($word)) . ' 'x$WORDS_SPACE ;
            ++ $cnt;
        }
        $out_line = $out_line . "\n";
        push(@result,$out_line);
    }

    #****************************************************************

    return ($const_cnt2-1,@result);
}


sub get_level{
    my @lines = @_; 
    #initial array
    #my @level = (0) x scalar(@lines);#这个初始化数组为全0
    my @level;

    my $cnt_level = 0;
    #while($cnt < scalar(@lines)){
    foreach $line (@lines){
        $cnt_level =level_cal($cnt_level, $line);
        push(@level,$cnt_level);
    }
    return @level;
}

#级数计数
sub level_cal{
    (my $cnt_level, my $line) = @_;
    ##################################################
    #begin
    foreach my $bd_start(@symbol::BLOCK_BOUNDRY_START){
        my $tmp = () = $line =~ /$bd_start/g;
        $cnt_level = $cnt_level + $tmp;
    }
    ##################################################
    ##################################################
    #end
    foreach my $bd_end(@symbol::BLOCK_BOUNDRY_END){
        my $tmp = () = $line =~ /$bd_end/g;
        $cnt_level = $cnt_level - $tmp;
    }
    ##################################################
    return $cnt_level;
}

#begin-end计数(这里不是对齐里的层,不计数if-else,
#因为always块中可以只有if没有else)
sub level_cal_begin_end{
    (my $cnt_level, my $line) = @_;
    ##################################################
    #begin
    my $tmp = () = $line =~ /begin/g;
    $cnt_level = $cnt_level + $tmp;
    ##################################################
    ##################################################
    #end
    my $tmp = () = $line =~ /end/g;
    $cnt_level = $cnt_level - $tmp;
    ##################################################
    return $cnt_level;
}

#将"block"单词置于行首,得到一整个block块的行数,中间部分直接原封不动地返回
#Writting
sub head_assign{
    (my $const_cnt1,my @lines) = @_; 
    #因为always块必定是以';'或'end'结尾
    my $END_FLAG = (';', 'end');
    my @output;
    my $const_cnt2 = $const_cnt1;
    my $level_cnt = 0;
    while($const_cnt2 < scalar(@lines)){
        my $line = $lines[$const_cnt2];
        if(0 == $level_cal_begin_end($level_cnt,$line)){
            if
        }


        ++ $const_cnt2;
    }
    return ($const_cnt2,@output);
}

sub spaceCtr_assign{
    #(my $const_cnt1, my $const_cnt2, my @lines) = @_; 
    my @lines = @_; 
    my @output;
    
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
    my @OP_REG_JS2=('\(\s+\(', '\)\s+\)', '{\s+{', '}\s+}',  ';');
    my @OP_TXT_JS2=('(('     , '))'     , '{{'   , '}}'   ,  ' ;');
    my $SPACE=' ';

    #while($cnt >= $const_cnt1 and $cnt < $const_cnt2){
    foreach my $line (@lines){
        #$line = $lines[$cnt];
        #------------------------------------------------------------------------
        #1 operator
        #先替换'>'和'=',之后再替换'>=',同时还有'<'和'<='
        #Verilog中'> ='会报错,必须写成'>=':see ./src/operators(Verilog-2005).png    
        my $num = 0;
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
        $num = 0;
        while ($num < scalar(@OP_REG_JS2)){
            $line =~ s/$OP_REG_JS2[$num]/$OP_TXT_JS2[$num]/g;
            ++$num;
            }  
        #------------------------------------------------------------------------ 
        #print $line;
        push(@output,$line);
    }
    return @output;
}




#扫描第一遍
sub get_length{
    my @lines  = @_;
    my $SPACE=' ';
    #***********************************************
    #simple example: assign a = b ;
    #                       0   1
    #"assign"、"=" and ";" always occupy same space
    #***********************************************
    my $column = 2;
    my @len;
    my @temp;

    foreach my $line (@lines){
        if($line =~ /^\s+$/ ){
            next;
        }
        #去除前导和拖尾空格,是为了split(\s),因为去了才能方便计数
        $line =~ s/^\s+|\s+$//g ;

        @temp = split(/\s+/, $line);
        my $cnt = 0;
        if($temp[0] =~ /^assign$/ ){
            #$cnt = 1;
            shift(@temp);
        }else{
            #$cnt = 0;
        }
        #print "-"x12;
        foreach my $word (@temp) {
            if($cnt == scalar(@len)){
                push(@len,length($word));
            }else{
                $len[$cnt] = length($word) if(length($word) > $len[$cnt]);
            }
            ++ $cnt;
            #print $word . "\n";

        }
    }
    return @len;
}


1;
