#!/usr/bin/perl -w
use strict;

use Cwd qw( getcwd abs_path);
my $path = abs_path(getcwd()); 
require $path."/module.pm";
require $path."/note.pm";
require $path."/assign.pm";
require $path."/decl.pm";
require $path."/block.pm";
require $path."/symbol.pm";



open(FILEIN,"<./file_list.f");
my @all_files = <FILEIN>;
close FILEIN;

system ("mkdir -p temp");

foreach $a (@all_files)
{
    open (FILETEMP,"< $a");
    my @lines = <FILETEMP>;
    close FILETEMP;
    open(FILEOUT,"> ./temp/$a");
    #add user function***************************************************

    my @cont;
    my %note_parall;
    #将"/**/"型注释单独搞成几行:即"/*"置于行首,"*/"后直接就是换行符
    @cont = note::wrap_note(@lines);
    #将"module"块的"module"字样置于行首
    @cont = module::head_module(@cont);

    #将"/**/"型注释剪切到哈希中
    my %note_2      = note::cut_note2('2',@cont);
    @cont           = note::cut_note2('1',@cont);
    
    #将"//"型注释剪切到哈希中
    my %note_1  = note::cut_note1('2',@cont);
    @cont    = note::cut_note1('1',@cont);


    #将Tab键转换为空格
    @cont = note::tab_space_convert(@cont);

    #开始检测并对齐
    @cont = sum_align(@cont);


    #最后加上注释
        #加上"//"型注释
        while(my ($num,$value) = each (%note_1)){
            my $tmp = $cont[$num+1];
            chomp($tmp);
            #print $num."\t".$value."\n";
            $tmp =~s/ +$//g;
            chomp($value);
            $cont[$num+1] = $tmp .'//' . $value ."\n";
        }
        #加上"/**/"型注释
        while(my ($num,$value) = each (%note_2)){
            #print $num."\t".$value."\n";
            #chomp($value);
            $cont[$num] = $cont[$num].$value;
        }

    #add user function**********************************************

    foreach (@cont){
        print FILEOUT $_;
    }
    close FILEOUT;
}

#主体检测并对齐
sub sum_align{
    my @lines = @_;
    my @output;
    my $const_cnt;
    my $cnt = 0;
    my $end_cnt;
    my @result;
    while($cnt < scalar(@lines)){
        my $line = $lines[$cnt];
        if($line =~ /^\s*$/){
            push(@output,$line);
        } elsif($line =~ /^module[\s\(]+/){
            #module块的对齐
            $const_cnt = $cnt;
            my ($flag, $len_sb, $len_var) = module::scan_module($const_cnt,@lines);
            my ($end_cnt,@result) = module::align_module($const_cnt,$flag,$len_sb, $len_var,@lines);
            $cnt = $end_cnt + 1;
            @output = (@output,@result);
            next;
        } elsif ( $line =~ /^\s*assign\s+/){
            ($cnt,@result) = assign::align_assign($cnt,@lines);
            @output = (@output,@result);    
            #assign语句对齐
            #assign::head_assign(@output);
        #} elsif( $line =~ /^\s*$symbol::DECL_WORDS\s+/){
        } elsif( $line =~ /^\s*$symbol::DECL_REGEX(\s+|\[)/){
            ($cnt,@result) = declaration::align_decl($cnt,@lines);
            @output = (@output,@result);    
        } elsif($line =~ /^\s*always(\s*|@|#|\()/){
            ($cnt,@result) = block::align_block($cnt,@lines);
            @output = (@output,@result);    
        } elsif($line =~ /^\s*endmodule\s+/){
            $line =~ s/^\s+//g ;
            push(@output,$line);
        }

        #   elsif($line =~/^((parameter)|(localparam)|(wire)|(reg)|(integer)|(real)|(genvar))\s+/){
        #       #变量声明语句的对齐
        #   }elsif($line =~/^((always)|(initial)|(for)|(generate))\s+/){
        #       #过程块语句的对齐
        #   }elsif($line =~/^assign\s+/){
        #       #assign语句的对齐
        #       
        #  }
        else{
            push(@output,$line);
        }
        $cnt ++;
    }
    return @output;
}

1;
