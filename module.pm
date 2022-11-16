#!usr/bin/perl

package module;


#将"module"单词置于行首,接着对module块进行对齐，其余部分直接原封不动地返回
sub head_module{
    my @lines = @_; 
    my @output;
    foreach my $line (@lines)
    {
        #因为是先进行左顶格对齐,后匹配"module",故只用匹配"空格+module"就行了
        #if ( (/\s+module[\s\(]+/) or (/^module[\s\(]+/))
        if ( $line =~ /\s+module[\s\(]+/){
            #push(@output, detect_module($line));
            #my @test = detect_module($line);
            @output = (@output,detect_module($line)); 
        }else{
            push(@output,$line);
        }
    }
    return @output;
}

#检测"module"行,并将其置于开头
sub detect_module{
    my $module = $_[0]; 
    my @module_line;
    my @tmp_array;
    if ( $module =~ /\s+module[\s\(]+/)
    {
        @module_line = split(/\s+module[\s\(]+/, $module);
        if(1 == scalar(@module_line)){
            push(@module_line,$module);
        }elsif (2 == scalar(@module_line)){
            #print $module;
            @tmp_array = split(/$module_line[0]/,$module);
            @tmp_array = split(/\s/,$tmp_array[1],2);#去除module前面的空格
            $module_line[1] = $tmp_array[1];
            $module_line[0] = $module_line[0]."\n";
            #print $module_line[1];
        }else{
            print "more than one module a line or module_line wrong\n";
        }
    }else{
        push(@module_line,$module);
    }
    return @module_line;
}




#扫描第一遍
sub scan_module{
    (my $const_cnt , my @lines)  = @_;
    my @output;
    my $flag    = 0;
    my $len_sb  = 0;
    my $len_var = 0;
    #扫描第1遍,找到对齐的方式:这里只判断是否有
    #1. "input/output" => 1
    #2. "reg/wire"     => 2
    #3. "中括号"       => 4
    my $cnt = $const_cnt;
    my @tmp;
    my @tmp2;

    while($cnt < scalar(@lines)){
        my $line = $lines[$cnt];
        @tmp = split(/,/,$line);#因为一行可能出现多句,按最大匹配原则进行匹配
        foreach $line (@tmp){
            ($flag,$len_sb,$len_var,$_) = scan_core($line,$flag,$len_sb,$len_var);
            #print $flag."\t".$len_sb."\t".$len_var."\t".$_."\n";
            return ($flag,$len_sb,$len_var) if($line =~ /\)/);
        }
        $cnt++;
    }
}


sub scan_core{
    (my $line, my $flag, my $len_sb, my $len_var) = @_;
    my $tmp_len_sb = 0;
    my $var = '';
    my $temp;
    my @tmp;
    #1. "input/output" => 1
    #2. "reg/wire"     => 2
    #3. "中括号"       => 4
    # input/output
    foreach my $keywords (@symbol::IO){
        if($line =~ /^[\s\,\(]*$keywords[\s+\[]/){
            $flag = $flag | 1;
            @tmp = split(/^[\s\,\(]*$keywords[\s+\[]/,$line,2);
            $line = $tmp[1];
        }
    }

    # reg/wire
    foreach my $keywords (@symbol::NET){
        if($line =~ /\s+$keywords[\s+\[]/){
            $flag = $flag | 2;
            @tmp  = split(/\s+$keywords[\s+\[]/,$line,2);
            $line = $tmp[1];
        }
    }

    # []:计算长度
    foreach my $keywords (@symbol::SQUARE_B){
        if($line =~ /$keywords/){
            $flag = $flag | 4;
            #因为@symbol::SQUARE_B里有"\",在index前需要先删掉
            @tmp = split(/\\/,$keywords,2);
            $tmp_len_sb = index($line,$tmp[1]) - $tmp_len_sb ;#index('[')-index(']')
            $len_sb = $tmp_len_sb -1 if($len_sb < $tmp_len_sb - 1);
        }
    }      

    # []:分割
    foreach my $keywords (@symbol::SQUARE_B){
        if($line =~ /$keywords/){
            my @tmp = split(/$keywords/,$line,2);
            $line = $tmp [1];
        }
    }
    # 变量:计算变量长度
    $line = " ".$line;#前头补上一个空格,便于split(空格)
    @tmp = split(/\s+/,$line,2);
    $var = $tmp[1];
    $var =~s/^ +| +$//g ;#删除前导和拖尾空格
    #print($var."\n");
    #字母or下划线开头,后面可以是 字母 or 数字 or $ or下划线
    if($tmp[1] =~ /^[_a-zA-Z]+[\w\$_]+/){
        #@tmp = split(/,/,$tmp[1],2);#因为已经采用split后的foreach循环
        @tmp = split(/\)/,$tmp[1]);
        #$temp = $tmp[]
        $len_var = length($tmp[0]) if ($len_var < length($tmp[0]));
    }else{
        $var = $tmp[1];
    }
    return ($flag,$len_sb,$len_var,$var);
}


#扫描第二遍并对齐
sub align_module{
    (my $const_cnt , my $flag, my $len_sb, my $len_var,@lines)   = @_;
    #print ($const_cnt,$flag,$len_sb, $len_var);
    my @output;
    #扫描第2遍,开始对齐
    #flag=1时,说明有input或output ; flag=0时,说明没有input或output
    #以此类推
    my $cnt = $const_cnt;
    my $end_cnt = $const_cnt;
    my $flag_detect_parentheses = 0;
    my $head = '';
    my $len_prefix;
    while($cnt < scalar(@lines)){
        my $line = $lines[$cnt];
        my $cnt_comma = $line =~ tr/,/,/; 
        $line =~s/ +$//g ;#删除拖尾空格
        my @split_comma = split(/,/,$line);
        my $cnt_foreach = 1;#因为即使没有逗号,split后其scalar值也是1
        my $out_line='';
        foreach $line (@split_comma){
            my $io='';
            my $net='';
            my $square='';
            my $var='';
            my $new_line='';
            my @tmp;
            my $len_prefix = 0;
            # input/output
            #print $flag."\n";

            #首先检测"module+若干空格+("字样,并判断其后是否还有字母
            if($cnt == $const_cnt){#因为"module"字样一定在$const_cnt行
                if($line =~ /.*\(/){
                    #print $line."xx";
                    $flag_detect_parentheses = 1;
                    @tmp = split(/\(/,$line,2);
                    if($tmp[1] =~/^\s*$/){
                        #即"module (",小括号后没有字母
                        $head = ' 'x4;
                        push(@output,$line);
                        $cnt ++ ;
                        next; 
                    }else{
                        #小括号后有字母,则有前缀长度
                        $head = $tmp[0]."(";
                        $line = $tmp[1];
                        $len_prefix = length($head);
                    }
                }
            }else{
                if($len_prefix >4){
                    $head = ' 'x$len_prefix;
                }else{
                    $head = ' 'x4;#前面至少留4个空格,看着好看
                }
            }

            #input/output
            if($flag & 1){
                foreach my $keywords (@symbol::IO){
                    if($line =~ /^[\s\,\(]*$keywords[\s+\[]/){
                        $io = $keywords ;
                        #print $io."\n";
                        last;
                    }
                }
                $io = $io . ' 'x($symbol::IO_LEN - length($io));
            }else{
                $io = '';
            }
            
            # reg/wire
            if($flag & 2){
                foreach my $keywords (@symbol::NET){
                    if($line =~ /\s+$keywords[\s+\[]/){
                    $net = $keywords;
                    last;
                    }
                }
                $net = $net . ' 'x($symbol::NET_LEN - length($net));
            }else{
                $net = '';
            }

            # []
            if($len_sb){
                foreach my $keywords (@symbol::SQUARE_B){
                    if($line =~ /$keywords/){
                        my @tmp2 = split(/$keywords/,$tmp[1]);
                        @tmp  = split(/$keywords/,$line);
                        $square = '[' . $tmp2[0] . ']' . ' 'x($len_sb +2 - length($tmp2[0]));
                    }else{
                        $square = ' 'x($len_sb + 2 + 2);
                        last;
                    }
                }
            }else{
                $square = '';
            }

            # variable 
            ($_,$_,$_,$var) = scan_core($line,$flag,$len_sb,$len_var);
            $var =~s/ +$//g ;#删除拖尾空格
            #print($var."\t".length($var)."\t$len_var\n");
            $var = $var . " "x($len_var - length($var));

            #最后开始拼接
            $new_line = $io . $net . $square . $var; 
            if($cnt_foreach <= $cnt_comma){
                $out_line = $out_line . $new_line ." ,";
            }else{
                $out_line = $out_line . $new_line;
            }
            #if($new_line =~ /^\s*$/){
            #    #push(@output,$new_line);
            #    $out_line = $new_line;
            #}else{
            #    #############################################################################
            #   $new_line = $head . $io . $net . $square . $var ;
            #   push(@output,$new_line);
            #}
            last if($cnt_foreach == scalar(@split_comma));
            $cnt_foreach ++ ;
        }
        $out_line = $head . $out_line . "\n";
        push(@output,$out_line);
        ##########################################################################
        #检测是否结束 module(xxxxx);,因为注释均已剔除即检测最后的";"
        if($line =~ /;/){
            $end_cnt = $cnt;#enc_cnt指向的当前行
            last;
        }
        $cnt ++;
    }
    return ($end_cnt,@output);
}


1;