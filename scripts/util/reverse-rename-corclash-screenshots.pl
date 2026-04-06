#!/usr/bin/env perl
# reverse-rename-corclash-screenshots.pl
use v5.36;
use POSIX 'tzset';
use Time::Local 'timelocal_posix';

{ # Localize time zone.
   local $ENV{TZ} = 'America/Los_Angeles';
   tzset();
   foreach my $new_name (<*.png>) {
      # Skip this file if it doesn't exist or isn't a file:
      next if ! -e $new_name || ! -f $new_name ;
      # Skip this file if it isn't named like a new-style Corporate-Clash screenshot:
      next if $new_name !~ m/^ccl-screenshot_\d{4}-\d{2}-\d{2}-\pL{3}_\d{2}-\d{2}-\d{2}\.png$/;
      # Get file-name prefix:
      my $prefix = $new_name =~ s/\.png$//r;
      # Get label, date, and time:
      my ($label, $date, $time) = split /_/, $prefix;
      # If anything is out-of-range, skip file:
      next if (    !defined($label)   || !($label   =~ m/^ccl-screenshot$/          )
                || !defined($date)    || !($date    =~ m/^\d{4}-\d{2}-\d{2}-\pL{3}$/)
                || !defined($time)    || !($time    =~ m/^\d{2}-\d{2}-\d{2}$/       ));
      # Get year, month, and day:
      my ($year, $month, $day) = split /-/, $date;
      # If anything is out-of-range, skip file:
      next if (    !defined($year)    || !($year    =~ m/^2\d\d\d$/  )
                || !defined($month)   || !($month   =~ m/^\d\d$/     )
                || !defined($day)     || !($day     =~ m/^\d\d$/     ));
      # Get hour, minute, and second:
      my ($hour, $minu, $seco) = split /-/, $time;
      # Make epoch:
      my $epoch = eval {timelocal_posix($seco-0, $minu-0, $hour-0, $day-0, $month-1, $year-1900)};
      # If that crashed, handle error:
      if ($@) {
         warn "Skipping \"$new_name\": bad date/time:\n$@\n";
         next;
      }
      # Create old name:
      my $old_name = "corporateclash-screenshot-$epoch.png";
      # Skip this file if a file of this name exists in current directory:
      next if -e $old_name ;
      # Try to rename file:
      rename($new_name, $old_name)
      and say "Successfully renamed \"$new_name\" to \"$old_name\"."
      or warn "Failed to rename \"$new_name\" to \"$old_name\": $!\n";
   } # end for each file
} # end localize time zone
tzset();
