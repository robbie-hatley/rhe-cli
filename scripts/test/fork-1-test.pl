#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################
# /rhe/scripts/test/fork-test.pl
##############################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use POSIX ":sys_wait_h";
use Errno qw(EAGAIN);
use Time::HiRes;

use RH::Dir;
use RH::Util;

our $child_pid;
our $result;

FORK:
{
   if ($child_pid = fork)
   {
      # parent here
      # child process pid is available in $pid
      say "This is parent process. My child's id# is $child_pid.";
      for ( my $count_down = 10 ; $count_down >= 0 ; --$count_down )
      {
         say "parent countdown = $count_down";
         Time::HiRes::sleep(1.0);
      }
      kill "INT", $child_pid;
      do
      {
         $result = waitpid(-1, WNOHANG);
         say $result if $result > 0;
      } until $result == -1;
      exit 0;
   }

   elsif (defined $child_pid)
   {
      # child here
      # $pid is zero here if defined
      # parent process pid is available with getppid
      say "This is child process. My parent's id# is ", getppid, ".";
      for ( my $count_down = 20 ; $count_down >= 0 ; --$count_down )
      {
         say "child coundown = $count_down";
         Time::HiRes::sleep(1.0);
      }
      exit 0;
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

