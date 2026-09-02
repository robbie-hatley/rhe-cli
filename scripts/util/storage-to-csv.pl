#!/usr/bin/env perl

use v5.42;
use utf8::all;
use Time::Piece;

my $decimal_year =  1970.000000  ;
my $line         = '1970.000000' ;

while (<>) {
    chomp;

    if (
        m/^Storage\s+usage\s+as\s+of\s+
          (\d{2}:\d{2}:\d{2})\s+
          ([AP]M)\s+
          \S+,\s+
          \w+\s+
          (\w+\s+\d{1,2},\s+\d{4}):
        $/x
    ) {
        my ($clock, $ampm, $date) = ($1, $2, $3);

        my $time = Time::Piece->strptime(
            "$date $clock $ampm",
            '%B %d, %Y %I:%M:%S %p'
        );

        my $year = $time->year;

        my $start = Time::Piece->strptime(
            "$year-01-01 00:00:00",
            '%Y-%m-%d %H:%M:%S'
        );

        my $end = Time::Piece->strptime(
            ($year + 1) . '-01-01 00:00:00',
            '%Y-%m-%d %H:%M:%S'
        );

        my $elapsed      = $time->epoch - $start->epoch;
        my $year_length  = $end->epoch  - $start->epoch;

        $decimal_year = $year + $elapsed / $year_length;
        $line = sprintf("%.6f", $decimal_year);
        next;
    }

    elsif (m#^/\s+\d+(?:\.\d+)?GB\s+(\d+(?:\.\d+)?)GB\s+#) {
        $line .= sprintf(",%s", $1);
    }

    elsif (m#^/home/aragorn/Data\s+\d+(?:\.\d+)?GB\s+(\d+(?:\.\d+)?)GB\s+#) {
        $line .= sprintf(",%s", $1);
        say $line;
    }
}
