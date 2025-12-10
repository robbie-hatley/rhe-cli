#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# zero-sandwich-factors.pl
# Prints factors of all "zero sandwich" integers (integers who's decimal expansions consist of a one, followed
# by a string of zeros, followed by a one) with number of zeros from 0 through 30.
# Written by Robbie Hatley.
# Edit history:
# Tue Dec 09, 2025: Wrote it.
##############################################################################################################

my $num;
for my $idx (0..40) {
   $num = '1' . ('0' x $idx) . '1';
   print `factor $num`;
}
