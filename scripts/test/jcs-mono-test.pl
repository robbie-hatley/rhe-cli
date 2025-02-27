#!/usr/bin/perl
sub monotonic {
   my ($n,$d,$t)=$_[0];
   ($t=$n<=>$_)&&($d||=$t)!=$t?(return 2):($n=$_)for @_;
   return -($d||0);
}
print monotonic(@ARGV),"\n";
