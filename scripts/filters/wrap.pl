#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wrap.pl
# Outputs a word-wrapped paragraph for each input string (input remains unchanged).
# Written by Robbie Hatley.
# Edit history:
# Fri Mar 31, 2023: Wrote it.
# Sat Aug 03, 2024: Reduced width from 110 to 120; got rid of "use strict"; got rid of "use warnings";
#                   got rid of "use Sys::Binmode".
##############################################################################################################

use v5.36;
use utf8;

use Text::Wrap qw(wrap $columns $huge);

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Settings:            Meaning:                         Range:   Default:
my $db       =  0;   # Debug?                           bool     0
my $Columns  = 72;   # Wrap Length.                     1-200    72
my $Indent   = '';   # First-line indent.               string   ''
my $Tab      = '';   # Subsequent-line indent.          string   ''
my $Blank    = '';   # Blank line between paragraphs.   string   ''

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{
   argv;
   $columns = $Columns + 1;
   $huge = 'wrap';
   $_ =~ s/\s+$//, say wrap $Indent, $Tab, $_, $Blank for (<STDIN>);
   exit 0;
}

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   for (@ARGV){
      if ( $_ eq '-h' || $_ eq '--help' ){
         help;
         exit 0;}
      if ( $_ =~ m/^-[^-]*c((?:0(?:b|x)?)?\d+)/ || $_ =~ m/^--columns=((?:0(?:b|x)?)?\d+)$/ ){
         my $colstr = $1;
         $Columns = $colstr =~ m/^0/ ? oct $colstr : $colstr;
         say "\$Columns = $Columns" if $db;
      }
      if ( $_ =~ m/^-[^-]*i/ || $_ eq '--indent' ){
         $Indent = "   ";
      }
      if ( $_ =~ m/^-[^-]*(?<![^\d]0)b/ || $_ eq '--blank' ){
         $Blank = "\n";
      }
   }
   return 1;
} # end sub argv

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "wrap.pl". This program wraps lines of text according to
   either built-in default settings (width=72, no first-line indent,
   no blank line between paragraphs), or according to settings supplied
   by user via options. Input is via STDIN and output is via STDOUT.

   The input is not altered. This program is intended to be used as a
   "filter" in a Unix or Linux "pipeline", so it prints no text other than
   a wrapped version of its input.

   Command lines:
   program-name.pl -h | --help   (to print this help and exit)
   program-name.pl [options]     (to print wrapped version of input)

   Description of options:
   Option:                  Meaning:
   "-h"  or "--help"        Print this help and exit.
   "-c#" or "--columns=#"   Wrap at # columns.
   "-i"  or "--indent"      Indent first line.
   "-b"  or "--blank"       Insert blank lines between paragraphs.

   Single-letter options may be combined. For example, -bc010i would give
   blank lines between paragraphs, 8 columns (010 is octal for 8), and
   first-line indenting.

   This program ignores all options and arguments other than the above.

   Happy text wrapping!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
