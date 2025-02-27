#!/usr/bin/perl.exe
@Aggamemnon = ("Fred", "Tom", "Sam");
open(INFILE, "second-perl.pl");
foreach $Name (<INFILE>)
{
   chomp $Name;
   print $Name, "\n";
}
close(INFILE);
