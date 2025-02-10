#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/find-modules
# Displays all available Perl modules.
# Edit history:
#    Fri Jul 17, 2015 - Stole it from The Camel Book.
#    Fri Apr 15, 2016 - Upgraded for utf8.
#    Sat Apr 16, 2016 - Now using -CSDA.
#    Thu Dec 21, 2017 - Got rid of nusance warnings.
#    Tue Dec 26, 2017 - use v5.025_001.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

no  warnings "utf8";
no  warnings "uninitialized";
use File::Find;

my %names;

my $wanted = sub {
   return unless /\.pm\z/;
   open(my $fh, "<", $File::Find::name)
   or die "can't open $File::Find::name\n$!\n";
   OUTER: while( <$fh> )
   {
      next unless /\A =head1 \s+ NAME/x;
      INNER: while( <$fh> )
      {
         next if /\A \s* \z/x;
         / (?<name>\S+) \s* -+ \s* (?<desc>.*) /x;
         $names{ $+{name} } = $+{desc};
         last OUTER;
      }
   }
};

find($wanted, @INC);

for my $name (sort keys %names)
{
   printf "%-25s - %s\n", $name, $names{$name};
}
