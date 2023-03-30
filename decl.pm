#!usr/bin/perl

package decl;

my $lines_threshold = 200;

sub align_decl{    
    (my $const_cnt1 , my @lines)  = @_;
    my @output;
    my $const_cnt2;
    my @result;
    #***************************************************************
    #1.扫描decl语句,得到($const_cnt1,$const_cnt2]长度的decl语句
    #2.得到每列的最大长度
    ($const_cnt2,@output) = head_decl($const_cnt1, @lines);
    if($const_cnt2 - $const_cnt1 ne 1){
        @output    = spaceCtr_decl(@output);
    }
    (my $decl_len,my @len) = get_length(@output);
    #****************************************************************
    #有了存储decl语句：@output
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
        if($temp[0] =~ /^$symbol::DECL_REGEX$/){
            $out_line = shift(@temp);
            $out_line = $out_line.' 'x$decl_len;
            $out_line = $out_line.' ';
        }else{
            $out_line = ' 'x$decl_len;
            $out_line = $out_line . ' ';
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

#将"decl"关键词置于行首,接着对decl语句进行对齐，其余部分直接原封不动地返回
sub head_decl{
    (my $const_cnt1,my @lines) = @_; 
    my @output;
    my $semicolon_flag = 0;
    my $const_cnt2 = $const_cnt1;
    while($const_cnt2 < scalar(@lines)){
        my $line = $lines[$const_cnt2];
        #因为是先进行左顶格对齐,后匹配"decl",故只用匹配"空格+decl"就行了
        if($const_cnt2 - $const_cnt1 > $lines_threshold){
            #防止内存爆炸
            last;
        }elsif( $line =~ /\s*$symbol::DECL_REGEX\s+/){
            if ( $line =~ /^\s+$symbol::DECL_REGEX\s+/){
                my @tmp = split(/\s+/,$line,1);
                push(@output,$tmp[0]);
            }else{
                push(@output,$line);
            }
            #如果不是以分号结尾,说明decl语句尚未结束,仍需要继续判断
            if( $line =~ /.*;\s*$/){
                $semicolon_flag = 0;
            }else{
                $semicolon_flag = 1;
            }
        }elsif($semicolon_flag eq 1){
            push(@output,$line);    #如果不是以分号结尾,说明decl语句尚未结束,仍需要继续判断
            $semicolon_flag = 0 if( $line =~ /.*;\s*$/);
        }else{
            #push(@output,$line);
            last;
        }
        ++ $const_cnt2;
    }
    return ($const_cnt2,@output);
}

sub spaceCtr_decl{
    #(my $const_cnt1, my $const_cnt2, my @lines) = @_; 
    my @lines = @_; 
    my @output;
    #*************************************************************************************************************************
    #下面的这些正则是assign语句的,会有冗余,但是我不想改了,以后有空再改,先实现功能    
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

    #*************************************************************************************************************************
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
    my $column = 2;
    my $decl_len=0;
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
        if($temp[0] =~ /^$symbol::DECL_REGEX$/ ){
            $decl_len = length($temp[0]) if(length($temp[0]) > $decl_len);
            shift(@temp);
        }
        #print "-"x12;
        foreach my $word (@temp) {
            if($cnt == scalar(@len)){
                push(@len,length($word));
            }else{
                $len[$cnt] = length($word) if(length($word) > $len[$cnt]);
            }
            ++ $cnt;
            print $word . "\n";
        }
    }
    return ($decl_len,@len);
}


1;
