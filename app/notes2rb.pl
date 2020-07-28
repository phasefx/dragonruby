#!/usr/bin/perl -w
use JSON;
#0 a3
#1 a3
#1 e5
#2 a4
#2 a5
#3 a4
#3 c6
#4 a4
#4 b5
#5 a4
#5 e5
#...
my @notes = ();
while (my $line = <>) {
    chomp $line; $line =~ s/[\r\n]//g;
    my @f = split / /, $line;
    if (! defined $notes[$f[0]]) {
        $notes[$f[0]] = [];
    }
    push @{ $notes[$f[0]] }, $f[1];
}
#print Dumper(@notes) . "\n";
print encode_json(\@notes) . "\n";
