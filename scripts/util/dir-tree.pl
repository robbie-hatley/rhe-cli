#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# dir-tree.pl
# Prints tree of all sub-directories of the current working directory.
#
# Edit history:
# Fri Apr 24, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Thu Apr 14, 2016: Now using -CSDA.
# Sat Feb 13, 2021: Changed encoding of this file to ASCII. Changed width to 110. Dramatically simplified
#                   method of passing code ref to RecurseDirs.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Feb 09, 2023: Can now print dir-tree of any directory, not just curdir.
# Thu Sep 07, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Got rid of CPAN module
#                   "common::sense" (antiquated). Can now run RecurseDirs once for each argument.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Thu Mar 13, 2025: Reduced min ver from "5.36" to (tacit) "5.00".
# Thu Apr 03, 2025: Increased min ver from "5.00" to "5.16" to get "say". Now using CPAN modules "utf8::all"
#                   and "Cwd::utf8". Got rid of "d" and "e". Shebang = "#!/usr/bin/env perl".
# Sun Apr 27, 2025: Increased min ver from "5.16" to "5.36" to get automatic "strict" and "warnings".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core". Made other minor tweaks.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use RH::Dir;

my $starting_directory = cwd;

sub help;

for ( @ARGV ) {if ( /^-h$/ || /^--help$/ ) {help;exit}}

if ( @ARGV ) {
   for ( @ARGV ) {
      chdir $_
      or warn "Couldn't chdir to directory \"$_\".\n"
      and (chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n")
      and next;
      RecurseDirs {say cwd};
      chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n";
   }
}
else {
   RecurseDirs {say cwd};
   chdir $starting_directory or die "Couldn't chdir to directory \"$starting_directory\".\n";
}

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "dir-tree.pl". This program This program prints the directory
   structure of the current working directory, or of directories given as
   arguments.

   -------------------------------------------------------------------------------
   Command lines:

   dir-tree.pl -h | --help   (to print this help and exit)
   dir-tree.pl               (to print directory tree of cwd)
   dir-tree.pl args          (to print directory trees of given directories)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   If one-or-more non-option arguments are given, then this program will construe
   those arguments as being paths to directory trees to be printed, and print
   those instead of printing the directory tree descending from the current
   working directory.


   Happy directory tree printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
