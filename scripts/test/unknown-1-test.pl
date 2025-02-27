#!/usr/bin/perl
#test.pl
#Generic perl test program.
my $Var1 = "Apple";
my $Var2 = "Bravo";
print 'She ate my $Var1!  $Var2!', "\n";
print "She ate my $Var1!  $Var2!\n";
print "She ate my '$Var1!'  $Var2!\n";
print "She ate my `$Var1!`  $Var2!\n";
print 'She ate my "$Var1!  $Var2!"', "\n";
print `ls -aogF /rhe`;
my $price = 'mountain of cashews';
print <<"GarGoyle";
The plain and simple fact is,
the in my life,
the $price is right for
development of eczema.
GarGoyle
