#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# browse-symtab.pl
# Browses the symbol table.
# Edit history:
#    Fri Feb 20, 2015: Wrote it.
#    Fri Jul 17, 2015: Upgraded for utf8.
#    Sat Apr 16, 2016: Now using -CSDA.
#    Wed Dec 27, 2017: Merged "browse-symtab.pl" with
#                      "symbol-table-test.pl" (merged 4 versions).
#    Fri Feb 05, 2021: Now v5.30, no strict, no warnings, 110 wide.

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

# say for map {s/([^\pL\pM\pN\pP\pS])/sprintf "[%02X]", ord $1/gre}
#         map {s/:://gr}
#         sort keys %main::;
# exit 0;

*main::PI       = sub {3.14159265358979};
sub E {return 2.71828182845905;}
our %GlobalHash = ('argle' => PI());
our $aardvark   = 5;
our ($value, @value, %value);
foreach my $key (sort keys %main::)
{
   local *value = $main::{$key};
   # At this point, $key is a hash KEY in the hash "main::",
   # and *value is the hash VALUE associated with $key.
   # The values of $main::{$key} are sets of references to
   # scalars, arrays, hashes, subs, etc. Let's see which references
   # actually point to something:
   $key =~ s/([^\pL\pN\pM\pP\pS])/A[${\ord($1)}]/g;
   printf("%-32s", $key);
   if (defined $value) {printf("%-32s", "\$$key");}
   if (        @value) {printf("%-32s", "\@$key");}
   if (        %value) {printf("%-32s", "\%$key");}
   if (defined &value) {printf("%-32s", "\&$key");}
   printf("\n");
}
package Frank;
say '';
say 'PI = ', main::PI();
say 'E  = ', main::E();
say '$GlobalHash{argle} = ', $main::GlobalHash{argle};
say '$aardvark = ', $main::aardvark;
our $PIE = main::PI() * main::E();
say "PIE = ", $PIE;
