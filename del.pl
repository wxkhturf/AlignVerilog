my @length;

my $line = " assijgn ";
$line =~ s/^\s+|\s+$//g ;
my @temp = split(/\s/,$line);




# my $cnt = 0;
# if($temp[$cnt] =~ /^assig$/  ){
# 	print "shit\n";
# 	print $temp[$cnt];
# }
#print(scalar(@temp));

if($temp[0] =~ /[^(assign)]/ ){
	print "shit\n$temp[0]\n";
}