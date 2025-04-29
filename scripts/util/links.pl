#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# links.pl
# Announces any symbolic links in current directory.
#
# Edit history:
# Wed Apr 22, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Mon Apr 04, 2015: Simplied.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Sep 23, 2016: Now also prints targets of links.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as its first
#                   argument, target as second, and regexp (instead of wildcard) as third.
# Sun Jul 25, 2021: Added help.
# Sat Jul 31, 2021: Now 120 characters wide.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense".
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e". Increased min var "5.32" -> "5.36".
########################################################################################################################

use v5.36;
use strict;
use warnings;
use utf8::all;
use Cwd::utf8;
use RH::Dir;

if (@ARGV && ($ARGV[0] eq '-h' || $ARGV[1] eq '--help'))
{
   say 'This program ("links.pl") lists any links, hard or soft, which exist in';
   say 'the current directory. This program takes no options or arguments other';
   say 'than "-h" or "--help", either of which will print this help and exit.';
   say 'All other command-line arguments will be ignored.';
}

my $cwd   = cwd;
my $files = GetFiles($cwd, 'A', '^.+$');

foreach my $file (@$files)
{
   my $p = $file->{Path};
   my $n = $file->{Name};
   my $t = $file->{Target};
   if ( ! -e $p )                       # NOEX
   {
      say "Warning: File \"$n\" does not exist.";
      next;
   }

   lstat $p;

   if ( -l _ )
   {
      # Now that we've established that this is a link,
      # get stats on what the link points to:
      stat $p;

      if ( -d _ )                         # SYMLINKD
      {
         say "SYMLINKD: $p => $t";
      }

      else                                # SYMLINKF
      {
         say "SYMLINKF: $p => $t";
      }

      if ( ! -e $t )                    # NOTARG
      {
         say "Warning: Target \"$t\" does not exist.";
         next;
      }
   } # end if link
} # end for each file
