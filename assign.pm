#!usr/bin/perl

package assign;

sub align_assign{    
    (my $const_cnt1 , my @lines)  = @_;
    my @output;
    my $const_cnt2;
    ($const_cnt2,@output) = head_assign($const_cnt1, @lines);
    if($const_cnt2 - $const_cnt1 gt 1){
        @output               = spaceCtr_assign(@output);
    }else{
        push(@output,$lines[$const_cnt1]);
    }

    return ($const_cnt2,@output);
}

#将"assign"单词置于行首,接着对assign语句进行对齐，其余部分直接原封不动地返回
sub head_assign{
    (my $const_cnt1,my @lines) = @_; 
    my @output;
    my $const_cnt2 = $const_cnt1;
    while($const_cnt2 < scalar(@lines)){
        my $line = $lines[$const_cnt2];
        #因为是先进行左顶格对齐,后匹配"assign",故只用匹配"空格+assign"就行了
        if($const_cnt2 - $const_cnt1 > 200){
            #防止内存爆炸
            last;
        }elsif( $line =~ /\s*assign\s+/){
            if ( $line =~ /^\s+assign\s+/){
                my @tmp = split(" ",$line,1);
                push(@output,$tmp[0]);
            }else{
                push(@output,$line);
            }
        }else{
            last;
        }
        $const_cnt2 ++;
    }
    return ($const_cnt2,@output);
}

sub spaceCtr_assign{
    #(my $const_cnt1, my $const_cnt2, my @lines) = @_; 
    my @lines = @_; 
    my @output;
    my $cnt = $const_cnt1;
    
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

    my $line='';
    my $num=0;
    #while($cnt >= $const_cnt1 and $cnt < $const_cnt2){
    foreach my $line (@lines){
        #$line = $lines[$cnt];
        #------------------------------------------------------------------------
        #1 operator
        #先替换'>'和'=',之后再替换'>=',同时还有'<'和'<='
        #Verilog中'> ='会报错,必须写成'>=':see ./src/operators(Verilog-2005).png    
        $num = 0;
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
        push(@output,$line."\n");
        #++ $cnt;
    }
    return @output;
}




#扫描第一遍
sub scan_assign{
    (my $const_cnt1, my $const_cnt2, my @lines)  = @_;
    my $cnt = $const_cnt1;
    while($cnt >= $const_cnt1 and $cnt < $const_cnt2){
        my $line = $lines[$cnt];
        
        $cnt++;
    }
}

1;