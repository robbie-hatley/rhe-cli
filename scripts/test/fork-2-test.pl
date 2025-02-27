#!/usr/bin/perl

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/Template.pl
# "Template" serves as a template for making new file and directory
# maintenance scripts.
# Edit history:
#    Mon May 04, 2015 - Wrote first draft.
#    Wed May 13, 2015 - Updated and changed Help to "Here Document" format.
#    Thu Jun 11, 2015 - Corrected a few minor issues.
#    Tue Jul 07, 2015 - Now fully utf8 compliant.
#    Fri Jul 17, 2015 - Upgraded for utf8.
########################################################################################################################

use v5.32;
use strict;
use warnings;

use Unicode::CaseFold;
use Unicode::Normalize qw( NFD NFC );
use POSIX ":sys_wait_h";
use Errno qw(EAGAIN);

use RH::Dir;
use RH::Util;

use open qw( :encoding(utf8) :std );
use warnings FATAL => "utf8";
use utf8;
use Encode;
BEGIN {$_ = decode_utf8 $_ for @ARGV;}

our $pid;

FORK:
{
   if ($pid = fork)
   {
      # parent here
      # child process pid is available in $pid
      my $result;
      my $counter = 1;
      do
      {
         $result = waitpid($pid, &WNOHANG);
         say $counter++;
      } while $result <= 0;
      say $result;
      exit;
   }
   elsif (defined $pid)
   {
      # child here
      # $pid is zero here if defined
      # parent process pid is available with getppid
      say "Fred";
      sleep(5);
      exit;
   }
   elsif ($! == EAGAIN)
   {
      # EAGAIN is the supposedly recoverable fork error
      sleep 5;
      redo FORK;
   }
   else
   {
      # weird fork error
      die "Can't fork: $!";
   }
}







