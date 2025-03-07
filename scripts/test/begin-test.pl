#!/usr/bin/env perl
our $mytime;
our $mydate;
BEGIN {$mytime = time; $mydate = "March 7";}
{
   print "mytime = $mytime    mydate = $mydate\n";
}
