#!/usr/bin/perl
open(DIR_PIPE, '-| :encoding(utf8)', 'ls -al');
open(SOR_PIPE, '|- :encoding(utf8)', 'sort -r'  );
my $Line;
my @Fields;
while ($Line = <DIR_PIPE>)
{
   @Fields = split(" ", $Line);
   $Size = @Fields[4];
   printf(SOR_PIPE "%20d\n", $Size);
}
close(DIR_PIPE);
close(SOR_PIPE);
