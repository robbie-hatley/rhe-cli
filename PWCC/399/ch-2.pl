#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:

Solution in Perl for The Weekly Challenge 399-2,
written by Robbie Hatley on Sun Nov 15, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:

Task 399-2: Longest Absolute Path
Submitted by: Mohammad Sajid Anwar
You are given a file system as string. Write  a script to return
the length of the longest absolute path to a file in the abstracted
file system. If there is no file in the system, return 0.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:

To solve this problem, I'll use the "number of leading tabs" as "depths", then keep track of "current working
directory" by pushing/popping directories on a stack. Then make the relative path (no leading slant) for each
file, and keep track of the longest.

--------------------------------------------------------------------------------------------------------------
IO NOTES:

Input is via either default data or @ARGV. If using @ARGV, provide one-or-more space-separated single-quoted
arguments. Each argument must be a string representing a directories-and-files tree using newlines and tabs.
For example:

./ch-2.pl 'Animals\n\tDogs\n\t\tTerriers\n\t\t\tFido.txt\n\tCats\n\t\tSpot.txt'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.40;
   use utf8::all;
   $"=', ';

   # What is the longest path to a file?
   sub longest_path ( $s ) {
      my $lp = 0;
      my @paths = split /\n/, $s;
      foreach my $path (@paths) {
         ;
      }
      return $lp;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? @ARGV :
(
   "dir\n\tsubdir1\n\t\tsubsubdir1\n\tsubdir2"                                    , #  0
   "file1.txt\nfile2.ext\na.png"                                                  , #  9
   "my documents\n\tproject v1.0\n\t\tnotes v1.txt\n\timage.png"                  , # 38
   "root\n\ta\n\t\tb\n\t\t\tc.txt\n\td\n\t\te.txt"                                , # 14
   "a\n\tb\n\t\tc\n\t\t\td\n\t\t\t\te.txt\n\tvery_long_directory_name\n\t\tf.txt" , # 32
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $string (@strings) {
   say '';
   my $lp = longest_path($string);
   print "Raw directory string =\n$string\n"
        ."Longest path to file = $lp\n";
}
