#!usr/bin/perl

package block;
#my $NO_ELSE = 3;#如果连续3行没有检测到else,则认为if结束

sub align_block{    
    (my $const_cnt1 , my @lines)  = @_;
    my @output;
    my @result;
    my $const_cnt2;
    #***************************************************************
    #1.扫描block语句,得到($const_cnt1,$const_cnt2]长度的block语句
    #2.得到每列的最大长度
    ($const_cnt2,@output) = head_block($const_cnt1, @lines);
    if($const_cnt2 - $const_cnt1 ne 1){
        #下面这一步与spaceCtr_assign类似
        @output    = spaceCtr_block(@output);
    }
    #得到层级数
    my @level = get_level(@output);
    #foreach my $shit(@output){
    #    print $shit."";
    #}
    ###################################################################
    #开始对齐
    my $ll_begin = 0;
    my $ll_end = $ll_begin + 1;
    #my $line_tmp;

    while($ll_begin < scalar(@level)){
        if($ll_end == scalar(@level)){
            push(@result,$output[$ll_begin]);
            last;
        }else{
            ##############################################################################
            #不需要对齐
            my @tmp = ();#清空数组
            push(@tmp,$output[$ll_begin]);
            while($ll_end ne scalar(@level)){
                if($level[$ll_end] eq $level[$ll_end -1]){
                    push(@tmp,$output[$ll_end]);
                }else{
                    last;
                }
                ++ $ll_end;
            }
            ###############################################################################

            ###############################################################################
            #需要对齐
            if( ($ll_end - $ll_begin) eq 1){
                push(@result,@tmp);
            }else{
                #push(@result,part_align(@tmp));
                #print "6"x90;
                #print "\n";
                #print @tmp;
                ##my @shit = part_align(@tmp);
                ##print @shit;
                #print "9"x90;
                #print "\n";

                push(@result, part_align(@tmp));
            }
            ###############################################################################
        }
        $ll_begin = $ll_end;
        $ll_end = $ll_end + 1;
    }
         


    #######################################################################################
    #添加前导空格
    
    $ll_cnt = 0;

    while($ll_cnt < scalar(@result)){
        if($result[$ll_cnt] !~ /^\s*$/){
            $result[$ll_cnt] =~ s/^\s+//g ;
            $result[$ll_cnt] = '    'x($level[$ll_cnt]+1) . $result[$ll_cnt];
        }
        ++ $ll_cnt;
    }
    #****************************************************************
    #去除第1句的前导空格
    $line_tmp = $result[0];
    $line_tmp =~ s/^\s+//g ;
    $result[0] = $line_tmp;
    return ($const_cnt2,@result);#关于这里要不要减1,有待商榷
}

##############################################################################
#align
sub part_align{
    my @lines = @_;
    my @len = get_length(@lines);
    my @output;

    my $out_line;
    my @temp;
    my $WORDS_SPACE=1;
    my $cnt = 0;
    foreach my $line (@lines){
        #print $line."\n";
        if($line =~ /^\s*$/){
            push(@output,$line);
            next;
        };
        #去除前导和拖尾空格,是为了split(\s),因为去了才能方便计数
        $line =~ s/^\s+|\s+$//g ;
        @temp = split(/\s+/, $line);
        $cnt = 0;
        $out_line = '';

        foreach my $word (@temp){
            $out_line = $out_line . $word . ' 'x($len[$cnt] - length($word)) . ' 'x$WORDS_SPACE ;
            #$out_line = $out_line . $word . ' 'x(5) . ' 'x$WORDS_SPACE ;
            ++ $cnt;
        }
        $out_line = $out_line . "\n";
        #print $out_line."ppppppppp";
        push(@output,$out_line);
    }
    return(@output);
}

sub get_length{
    my @lines = @_;
    my @len;
    foreach my $line (@lines){
        #去除前导和拖尾空格,是为了split(\s),因为去了才能方便计数
        $line =~ s/^\s+|\s+$//g ;
        my @temp = split(/\s+/, $line);
        my $cnt = 0;
        foreach my $word (@temp) {
            if($cnt == scalar(@len)){
                push(@len,length($word));
            }else{
                $len[$cnt] = length($word) if(length($word) > $len[$cnt]);
            }
            ++ $cnt;
        }
    }
    return @len;
}

##############################################################################
#level
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
    #####################################################################
    #更新层级
    #为了更好地对齐！
    my $ll_cnt = scalar(@level)-1;
        while($ll_cnt >0){
            if(($ll_cnt gt 0) and ($level[$ll_cnt] gt $level[$ll_cnt-1])){
                    $level[$ll_cnt] = $level[$ll_cnt-1];
            }
            -- $ll_cnt;
        }
    #####################################################################
    #为了更好地对齐
    $ll_cnt = 0;
    while($ll_cnt < scalar(@level)){
        $line = $lines[$ll_cnt];

        
        if($line =~ /(^\s*|\s)(end|endcase)\s/){
            if($line =~ /^\s*(end|endcase)\s*$/){
            }elsif($line =~ /\s(end|endcase)\s*$/){
                if(0 ne (level_cal_begin(0,$line) + level_cal_case(0,$line))){
                    $level[$ll_cnt] = $level[$ll_cnt]+1;
                }
            }
        }

        ###############################################
        my $tmp1 = () = $line =~ /\sif\s/g;
        $tmp1 = $tmp1 + (() = $line =~ /^if\s/g);
        my $tmp2 = () = $line =~ /\selse\s/g;
        $tmp2 = $tmp2 + (() = $line =~ /^else\s/g);
        if((0 ne $tmp1) and ($tmp1 eq $tmp2)){
            $level[$ll_cnt] = $level[$ll_cnt] -1;
        }
        ###############################################
        ++ $ll_cnt;
    }
    #####################################################################
    #为了更好地对齐

    return @level;
}

#级数计数
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



#将"block"单词置于行首,得到一整个block块的行数,中间部分直接原封不动地返回
#Writting
sub head_block{
    (my $const_cnt1,my @lines) = @_; 
    #因为always块必定是以';'或'end'结尾
    #my @END_FLAG = (';','end');
    my @output;
    my $const_cnt2 = $const_cnt1;
    #my $const_cnt2 = 0; 
    my $begin_cnt = 0;
    my $case_cnt = 0;
    my $if_cnt = 0;
    my $if_appeared = 0;#如果出现过if,则置为1
    while($const_cnt2 < scalar(@lines)){
        my $line = $lines[$const_cnt2];
        #print $line."\tuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu\n";
        #begin-end计数
        $begin_cnt = level_cal_begin($begin_cnt,$line);
        #case/casex/casez-endcase计数
        $case_cnt = level_cal_case($case_cnt,$line);
        #if-else计数
        $if_cnt = level_cal_if($if_cnt,$line);
        #是否出现过if
        if($line =~ /(^if|\sif)(\s|\()/ ){
            $if_appeared = 1;
        };
        ###################################################################
        #以分号结束,并且没碰到过if,说明always块结束了
        if(0 == $if_appeared){
            if(0 == $begin_cnt and 0 == $case_cnt){
                push(@output,$line);
                if($line =~ /;\s*$/)
                {
                    last;
                }
            }
        }elsif(0 == $begin_cnt and 0 == $case_cnt){
            foreach my $head (@symbol::THE_HEAD){
                if($line =~ /(^\s*|\s)$head\s/){
                    -- $const_2;
                    return ($const_cnt2,@output);
                } 
            }
            push(@output,$line);
        }else{
            foreach my $head (@symbol::THE_HEAD){
                if($line =~ /(^\s*|\s)$head\s/){
                    -- $const_2;
                    return ($const_cnt2,@output);
                } 
            }
            push(@output,$line);
        }
        ++ $const_cnt2;
    }
    return ($const_cnt2,@output);
}

sub spaceCtr_block{
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

    my @always_REG_JS3=('\s*always\s*@','\s*always\s*#','@\s+');
    my @always_TXT_JS3=('always@ '     ,'always# '     ,'@');

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
        #单独考虑"!"
        $line =~ s/!\s+/!/g;
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
        $num = 0;
        while ($num < scalar(@always_REG_JS3)){
            $line =~ s/$always_REG_JS3[$num]/$always_TXT_JS3[$num]/g;
            ++$num;
            }  
        #print $line;
        push(@output,$line);
    }
    return @output;
}



1;
