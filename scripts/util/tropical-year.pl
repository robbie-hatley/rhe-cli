#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# File name: myprog.pl
# Program name:  "Tropical Year"
# Description:   Prints length of tropical year in days ending March of 2011-2030.
# Written by Robbie Hatley.
# Edit history:
# Sat Jun 05, 2021: Wrote it.
# Sat Mar 15, 2025: Changed "say" to "print" and removed "use v5.16" (can work with any Perl version).
##############################################################################################################

use utf8;

my @lines;
for my $line (<DATA>) {
   push @lines, [split /\s+/, $line];
}
my %lengths;
for my $line (@lines) {
   my $Y = $$line[4];
   my $D = $$line[5];
   my $H = $$line[6];
   my $M = $$line[7];
   my $S = $$line[8];
   my $days = $D + $H/24 + $M/(24*60) + $S/(24*60*60);
   $lengths{$Y} = $days;
}
my $accumulator = 0;
for my $year (2011..2030) {
   print "Length-in-days of tropical year ending March $year = $lengths{$year}\n";
   $accumulator += $lengths{$year}
}
my $average = $accumulator/20;
print "Average length of tropical year 2011-2030         = $average\n";

__DATA__
March 2010 – March 2011	365	5	48	23
March 2011 – March 2012	365	5	53	56
March 2012 – March 2013	365	5	47	22
March 2013 – March 2014	365	5	55	14
March 2014 – March 2015	365	5	48	2
March 2015 – March 2016	365	5	44	56
March 2016 – March 2017	365	5	58	36
March 2017 – March 2018	365	5	46	41
March 2018 – March 2019	365	5	43	12
March 2019 – March 2020	365	5	51	4
March 2020 – March 2021	365	5	47	55
March 2021 – March 2022	365	5	55	54
March 2022 – March 2023	365	5	50	55
March 2023 – March 2024	365	5	42	8
March 2024 – March 2025	365	5	54	53
March 2025 – March 2026	365	5	44	39
March 2026 – March 2027	365	5	38	39
March 2027 – March 2028	365	5	52	27
March 2028 – March 2029	365	5	44	57
March 2029 – March 2030	365	5	49	56
