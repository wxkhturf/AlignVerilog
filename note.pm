#!usr/bin/perl
package note;

my $tab_num = "    ";

#第1步:将Tab键替换为空格
#第2步:删除前导和拖尾空格
sub tab_space_convert{
  my @lines = @_; 
  my $line;
  my @output;
  foreach (@lines){
    $line = $_;
    $line =~s/\t/$tab_num/g;
    $line =~s/^ +| +$//g;
    push(@output,$line);
  }
  return @output;
}


#删除注释:
# 1./**/
# 2.//
sub delete_note{
    my @lines = @_;
    my @output;
    my $flag = 0;
    my $type = 0;
    foreach (@lines)
    {
        if (/\/\/.*/){s/\/\/.*//g;}

        if ((/\/\*/) && (/\*\//))
          {
            s/\/\*.*\*\///g;
            $flag=0; $type=0;
          }
        if (/\/\*/)
          {
            $flag=1; $type=1;
          }
        elsif (/\*\//)
          {
            $flag=1; $type=0;
          }
        else
          {
            $flag=0;
          }

        if (($flag==0) && ($type==0))
          {
              push(@output , $_) ; 
          }
    }
    return @output;
}

#给"/**/"型注释换行
sub wrap_note{
    my @lines = @_;
    my @output;
    my @tmp;
    foreach(@lines){
        if(/.+\/\*/){
            @tmp = split(/\/\*/);
            push(@output,$tmp[0]."\n");
            push(@output,'/*'.$tmp[1]);
        }elsif(/\*\/.+/){
            @tmp = split(/\*\//);
            push(@output,$tmp[0].'*/'."\n");
            push(@output,$tmp[1]);
        }else{
            push(@output,$_);
        }
    }
    return @output;
}

#标记行号并存储"//"型注释
#标记完成后,删除"//"型注释
# $return_select==1时,返回删除"//"型注释后的数组
# $return_select==2时,返回"//"型注释的带行号映射的哈希
sub cut_note1{
    (my $return_select,my @lines) = @_;
    my @output;
    my %note;

    my @tmp;
    my $line;
    my $cnt = 0;
    while($cnt < scalar(@lines)){
        $line = $lines[$cnt];
        #print($line."\n");
        if($line =~ /\/\//){
            @tmp = split(/\/\//,$line,2);
            $tmp[0] =~s/ +$//g;#删除拖尾空格
            push(@output,$tmp[0]."\n");
            $note{$cnt} = $tmp[1];
        }else{
            push(@output,$line);
        }
        $cnt ++;
    }

    if($return_select == 1){
        return @output;
    }elsif($return_select == 2){
        return %note;
    }
}

#标记行号并存储"/**/"型注释
#标记完成后,删除"/**/"型注释
# $return_select==1时,返回删除"/**/"型注释后的数组
# $return_select==2时,返回"/**/"型注释的带行号映射的哈希
sub cut_note2{
    (my $return_select,my @lines) = @_;
    my @output;
    my %note;

    my $flag = 0;
    my $line;
    my $cnt = 0;
    while($cnt < scalar(@lines)){
        $line = $lines[$cnt];
        if($line =~ /\/\*/){
            $flag = 1;
            $flag = 0 if($line =~ /\*\//);#如果"/*"与"*/"在同一行
            $note{$cnt} = $line;
            push(@output,"\n");
        }elsif($line =~ /\*\//){
            $flag = 0;
            $note{$cnt} = $line;
            push(@output,"\n");
        }elsif($flag ==1){
            $note{$cnt} = $line;
            push(@output,"\n");
        }else{
            push(@output,$line);
        }
        $cnt ++;
    }

    if($return_select == 1){
        return @output;
    }elsif($return_select == 2){
        return %note;
    }
}


1;