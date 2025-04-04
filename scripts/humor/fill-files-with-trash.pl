#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/util/fill-files-with-trash.pl
# "Fill Files With Trash". Destroys all files in current directory matching a given regular expression
# by filling them with 25-250 rows of 35-70 columns of random characters of various different kinds.
# WARNING: THIS PROGRAM WILL DESTROY THE CONTENTS OF ALL YOUR FILES!!!
# ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???
# Edit history:
# Sun Jul 12, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Dec 20, 2017: Cleaned up formatting, improved comments.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Thu Apr 03, 2025: Reduced width from 120 to 110. Increased min ver from "5.32" to "5.36". Shortened sub
#                   names. Got rid of prototypes. Now using signature. All subs now return 1 on success.
#                   Now using "utf8::all" and "Cwd::utf8". Got rid of "d", "e", and "cwd_utf8".
##############################################################################################################

use v5.36;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use utf8::all;
use Cwd::utf8;

use RH::Util;
use RH::Dir;

my $db = 1;
my @Arguments;
my @Options;
my %Settings = (             # Meaning of setting:        Possible values:
   Help         => 0,        # Print help and exit?       (bool)
   Regexp       => '.+',     # Regular expression.        (regexp)
   Recurse      => 0,        # Recurse?                   (bool)
);
my $direcount = 0;
my $filecount = 0;

sub argv;
sub curdire;
sub curfile;
sub stats;
sub error;
sub help;

# main
{
   argv;

   # If user wants help, just print help and bail:
   if ($Settings{Help}) {
      help;
      exit 777;
   }

   # If number of arguments is out of range, bail:
   if ( @Arguments > 1 ) {
      error;
      exit 666;
   }

   # Give user final warning:
   say 'WARNING: THIS PROGRAM WILL DESTROY THE CONTENTS OF ALL YOUR FILES!!!';
   say 'ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???';
   say 'PRESS $ (SHIFT-4) TO CONTINUE OR ANY OTHER KEY TO ABORT.';
   my $character = get_character();
   exit 0 unless $character eq '$';

   # Destroy files:
   $Settings{Recurse} and RecurseDirs {curdire} or curdire;

   # Print stats:
   stats;

   # We be done, so scram:
   exit 0;
}#end main

sub argv {
   foreach (@ARGV) {
      if ('-' eq substr($_,0,1)) {push(@Options  , $_);}
      else                       {push(@Arguments, $_);}
   }
   foreach (@Options) {
      if ('-h' eq $_ || '--help'    eq $_) {$Settings{Help}    = 1;}
      if ('-r' eq $_ || '--recurse' eq $_) {$Settings{Recurse} = 1;}
   }
   if (@Arguments >= 1) {
      $Settings{Regexp} = $Arguments[0];
   }
   return 1;
}

sub curdire {
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd;
   say '';
   say '';
   say "Directory # $direcount:";
   say $curdir;

   my $curdirfiles = GetFiles($curdir, 'F', $Settings{Regexp});
   foreach my $file (@{$curdirfiles}) {
      process_current_file($file);
   }
   return 1;
}

sub process_current_file ($file) {
   my $fh;
   my $nextchar;
   my $chars =
   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'              .
   'abcdefghijklmnopqrstuvwxyz'         x  2 .
   'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ'          .
   'ßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'   x  2 .
   'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'       .
   'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'  x  2 .
   ' '                                  x 80 .
   '麦藁雪富士川町山梨県茶京愛永看的星道你是。、'           .
   '☺♪♫♭♮♯'                                   .
   '☿♀♁♂♃♄♅♆♇'                                ;
   open $fh, '>', $file->{Path}
   or warn "Error in fill-files-with-trash:\n".
   "can't open file $file->{Path} for output.\n".
   "$!.\nMoving on to next file.\n"
   and return 0;
   my $rows      = rand_int(25, 250);
   my $cols_base = rand_int(35,  70);
   for (1..$rows)
   {
      my $cols = $cols_base + rand_int(-8,+8);
      for (1..$cols)
      {
         $nextchar = substr $chars, int rand length $chars, 1;
         print($fh "$nextchar");
      }
      print($fh "\n");
   }
   ++$filecount;
   return 1;
}

sub stats {
   say "Overwrote $filecount files in $direcount directories with gibberish.";
   return 1;
}

sub error {
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);
   Error: This program takes at most 1 argument, which (if present) must be
   a Perl-Compliant Regular Expression specifying which files to trash.
   END_OF_ERROR
   return 1;
}

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "Fill Files With Trash", Robbie Hatley's file trashing Utility.
   This program fills all regular files in current directory matching a given
   regular expression with 25-250 rows of 35-70 columns of random characters.
   (It also trashes all subdirectories if "-r" or "--recurse" is used.)

   Command line:
   fill-files-with-trash.pl [-h|--help] | [Arg1] [-r|--recurse]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Also process all subdirectories.

   Description of arguments:
   This program can accept 1 optional argument, which, if present, must be
   a Perl-Compliant Regular Expression specifying which files to trash.
   All further arguments after the first are ignored.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
