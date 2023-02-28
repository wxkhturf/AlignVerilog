#!usr/bin/perl

package assign;

sub align_assign{    
    (my $const_cnt1 , my @lines)  = @_;
    my @output;
    my $const_cnt2;
    ($const_cnt2,@output) = head_assign($const_cnt1,@lines);

    return ($cnt,@output);
}

#将"assign"单词置于行首,接着对assign语句进行对齐，其余部分直接原封不动地返回
sub head_assign{
    (my $const_cnt,my @lines) = @_; 
    my @output;
    my $const_cnt2 = $const_cnt;
    while($cnt < scalar(@lines)){
        my $line = $lines[$cnt];
        #因为是先进行左顶格对齐,后匹配"assign",故只用匹配"空格+assign"就行了
        if($cnt - $const_cnt > 200){
            #防止内存爆炸
            last;
        }
        elsif( $line =~ /\s*assign\s+/){
            if ( $line =~ /^\s+assign\s+/){
                my @tmp = split(" ",$line,1);
                push(@output,$tmp[0]);
            }else{
                push(@output,$line);
            }
        }else{
            last;
        }
        $cnt ++;
    }
    return ($cnt,@output);
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