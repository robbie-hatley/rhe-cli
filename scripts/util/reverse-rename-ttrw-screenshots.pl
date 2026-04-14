#!/usr/bin/env perl
# reverse-rename-ttrw-screenshots.pl
use v5.36;
use POSIX 'tzset';
use Time::Local 'timelocal_posix';

# Renamed-ttrw-screenshot regular expression:
my $ttrw_renamed  = qr/^ttr-screenshot_\d{4}-\d{2}-\d{2}-\pL{3}_\d{2}-\d{2}-\d{2}_\d{1,18}\.png$/;

# Hash of month names keyed by month numbers, for use in renaming files:
my %months =
(
   '01' => 'Jan', '02' => 'Feb', '03' => 'Mar', '04' => 'Apr', '05' => 'May', '06' => 'Jun',
   '07' => 'Jul', '08' => 'Aug', '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Dec'
);

{ # Localize time zone.
   local $ENV{TZ} = 'America/Los_Angeles';
   tzset();
   foreach my $new_name (<*.png>) {
      # Skip this file if it doesn't exist or isn't a file:
      next if ! -e $new_name || ! -f $new_name ;
      # Skip this file if it isn't named like a new-style Corporate-Clash screenshot:
      next if $new_name !~ m/$ttrw_renamed/;
      # Get file-name prefix:
      my $prefix = $new_name =~ s/\.png$//r;
      # Get label, date, and time:
      my ($label, $date, $time, $id) = split /_/, $prefix;
      # If anything is out-of-range, skip file:
      next if (    !defined($label)  || $label !~ m/^ttr-screenshot$/
                || !defined($date)   || $date  !~ m/^\d{4}-\d{2}-\d{2}-\pL{3}$/
                || !defined($time)   || $time  !~ m/^\d{2}-\d{2}-\d{2}$/        );
      # Get year, month, day, and day-of-week:
      my ($year, $month, $day, $dow) = split /-/, $date;
      # If anything is out-of-range, skip file:
      next if (    !defined($year)   || $year  !~ m/^2\d\d\d$/
                || !defined($month)  || $month !~ m/^\d\d$/
                || !defined($day)    || $day   !~ m/^\d\d$/
                || !defined($dow)    || $dow   !~ m/^\pL\pL\pL$/ );
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
      my $old_name = "ttr-screenshot-$dow-$months{$month}-$day-$hour-$minu-$seco-$year-$id.png";
      # Skip this file if a file of this name exists in current directory:
      next if -e $old_name ;
      # Try to rename file:
      rename($new_name, $old_name)
      and say "Successfully renamed \"$new_name\" to \"$old_name\"."
      or warn "Failed to rename \"$new_name\" to \"$old_name\": $!\n";
   } # end for each file
} # end localize time zone
tzset();
