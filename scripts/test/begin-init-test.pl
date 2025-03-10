#!/usr/bin/perl
my $dog = 'Spot';
BEGIN {print(defined($dog)?"defined\n":"undefined\n");}
print("My dog's name is $dog.\n");
END   {print("$dog is a nice dog.\n");}
