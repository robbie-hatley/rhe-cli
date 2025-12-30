#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# dir-count.pl
# Counts directories in tree of current working directory or of directories given as arguments.
# Written by Robbie Hatley.
# Edit history:
# Fri Dec 26, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use RH::Dir;

my $starting_directory = cwd;
my $count = 0;

sub help;

for ( @ARGV ) {if ( /^-h$/ || /^--help$/ ) {help;exit}}

if ( @ARGV ) {
   for ( @ARGV ) {
      chdir $_
      or warn "Couldn't chdir to directory \"$_\".\n"
      and (chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n")
      and next;
      RecurseDirs {++$count};
      chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n";
   }
}
else {
   RecurseDirs {++$count};
   chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n";
}
say "Traversed $count directories.";

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "dir-count.pl". This program prints a count of all directories in
   the tree of the current working directory, or of directories in the trees of
   directories given as arguments.

   -------------------------------------------------------------------------------
   Command lines:

   dir-count.pl -h | --help   (to print this help and exit)
   dir-count.pl               (to print count of dirs in cwd tree)
   dir-count.pl args          (to print count of dirs in given dir trees)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   If one-or-more non-option arguments are given, then this program will construe
   those arguments as being paths to directory trees to be traversed, and print
   a count of all directories in those trees, rather than printing a count of all
   directories in the tree descending from the current working directory.


   Happy directory counting!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
