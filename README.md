首先划分为三个结构

>==module结构==
>
><u>moudule块内容由**我完全控制**，原顺序全部作废。</u>
>
><u>每行一个变量声明</u>
>
>以下内容按顺序
>
>1. timescale：`timescale`+`1*空格`+`数字`+`单位1`+`空格`+`/`+`数字`+`单位2`
>2. `空一行`
>3. module部分：(带parameter的module记得单独考虑)每行只有一个变量，先input，后output

> ==主体内容==
>
> 1. parameter：`parameter(左对齐)`+`2*若干空格`+`字母对齐`+`2*若干空格`+`等号对齐`+`内容`+`2*若干空格`+`分号对齐`
> 2. localparam：
> 3. input
> 4. output
> 5. reg
> 6. wire
> 7. assign

> ==endmodule==

## 1.2 要点

1. begin... end缩进
2. generate ... endgenerate缩进
3. always、for等缩进
4. 记得分号后的注释

## 1.3 扫描顺序与结构

==三步走==：**按顺序操作**

> 给自己看的：
>
> 1. 所有`Tab`键替换为空格
> 2. 所有内容全部顶格对齐（删除前导和拖尾空格）
> 3. 把`module`置至开头，``timescale 1 ps / 1 ps module fifo(`，比如moduel和timescale在一起，所以需要置至开头
> 4. `module部分`按逗号进行分割为第1列区域、第2列...
> 5. `主体内容`按分号进行分割为第1列区域、第2列...
> 6. 对齐方式：不同always块不互相对齐，只在一个always块里对齐，同理还有generate块
> 7. <u>不对`/**/`这种注释进行除左对齐外的其他任何处理</u>
> 8. 对齐字母、标点符号、注释。<u>由于不可能完全对齐，优先保证等号、分号、逗号对齐</u>
> 9. 若一行只含有字母，比如跨行，则将其最后一个字母与上一句的最后一个字母对齐
> 10. <u>实例化模块不做任何处理</u>(因为有可能需要更改接口，所以不对此进行变化)

>1. 删除所有注释，
>2. 合并所有跨行为一行
>3. 禁止一行中包括两句，含两句以上的拆成一行一句
>4. 按input、output、wire、reg、assign、always等块进行分块归类

>1. 遍历变量（不改动input、output）这样保证接口功能正常
>2. 随机打乱变量顺序，进行随机分配

## 1.4 代码块检测方法

> 1. `module`块检测方案：首先检测"`module`"字样，检测到";"停止(`endmodule`处理方式同`module`)
> 2. `always`块检测方案：首先检测"`always`"字样，接着判断`)`后的第一个字母是不是" `begin`"，如果是则以`end`为边界，如果不是，则以"`;`"或关键词(比如"`if`")为新块，在新块中递归。（`for`、`generate`、`initial`等块同样这样操作，使用一个数组存储这些块关键词）
> 3. `input`、`output`、`wire`、`reg`、`integer`等声明对齐。首先使用一数组存储上述关键词，在首次检测出关键词后，接着向后检测。检测到`;`后的第一个单词是否还是上述关键词，若是则接着向后检测；若不是则说明对齐的只有这几行。然后开始对这几行进行对齐。
> 4. 检测到关键词`endmodule`则停止

> ==注意：==
>
> 1. 第一个块结尾检测是否另起一行，举个例子`moudule(xxxx);abc`，在`module`块结尾标志`);`后还有个`abc`，那么如何处理`abc`呢？将`abc`另起一行，并左顶格对齐
> 1. <u>记得考虑不删注释的情况，专门写个函数把注释给保留！</u>
> 1. 标号，比如：`begin:name`

## 1.5 结构

|          |         |        |         |           |         |      |         |      | 备注 |
| -------- | ------- | ------ | ------- | --------- | ------- | ---- | ------- | ---- | ---- |
| `input`  |         | `reg`  |         |           |         |      |         |      |      |
| `output` | 2个空格 | `wire` | 2个空格 | `[xx:xx]` | 2个空格 | xxxx | 1个空格 | ，   |      |
| 6        | 2       | 4      | 2       | 不定      | 2       | 不定 | 1       | 1    |      |

固定的部分：

6+2 = 8

4+2=6









```perl
#!/usr/bin/perl -w


open(FILEIN,"<./file_list");
@all_files = <FILEIN>;
close FILEIN;

system ("mkdir -p temp");
$tab_num = "    ";
foreach $a (@all_files)
{
        open (FILETEMP,"< $a");
        @lines = <FILETEMP>;
        close FILETEMP;

        open(FILEOUT,"> ./temp/$a");

        my @cont = delete_note(@lines);
        @cont = tab_space_convert(@cont);
        foreach (@cont){
            print FILEOUT $_;
        }
        close FILEOUT;
}

#第1步:将Tab键替换为空格
#第2步:删除前导和拖尾空格
sub tab_space_convert{
  my $lines = scalar(@_) ;
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


#删除注释
sub delete_note{
    my $lines = scalar(@_);
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

#匹配并调整module的头部分,其余部分直接原封不动地返回
sub head_module{

}
```

```perl
#modle分行测试通过
#!/usr/bin/perl 

$module = 'aaaaa module 
bbbbbbbbbbbbb
ccccccccccccc';
$b = 'module (
    sflsjfl';
my @module_line;
my @tmp_array;
if ( $module =~ /\s+module[\s\(]+/)
    {
        @module_line = split(/\s+module[\s\(]+/, $module);
        if(1 == scalar(@module_line)){
            @module_line[0] = $module;
        }elsif (2 == scalar(@module_line)){
            @tmp_array = split(/@module_line[0]/,$module);
            @tmp_array = split(/\s/,@tmp_array[1],2);#去除module前面的空格
            @module_line[1] = @tmp_array[1];
        }else{
            print "module_line wrong\n";
        }
    }


foreach(@module_line){
    print $_."\n"; 
}    
```



