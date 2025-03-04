#!/usr/bin/env -S perl -C63

# This is a 90-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|

##########################################################################################
# rotate-string.pl
# Prints the string given by the first argument, rotated by the number of characters given
# by second argument. A positive rotation amount rotates rightward, and a negative
# rotation amount rotates leftward. The rotation amount can be any integer.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense", "Sys::Binmode", "RH::Math", "v5.36".
#                   Now rotates either direction and rotation amount can be any integer.
##########################################################################################

sub is_integer {
   my $x = shift;
   $x =~ m/^-[1-9]\d*$|^0$|^[1-9]\d*$/;
}

sub Rotate {
   my $s = shift;
	my $r = shift;
   my $n = length($s);
   my $m = $r%$n;
   my $o =
      substr ( $s, $n-$m,  $m   ) .
      substr ( $s,   0,   $n-$m );
   return $o;
}

die "Error.\n" if 2!=scalar(@ARGV) || !is_integer($ARGV[1]);
print Rotate($ARGV[0], $ARGV[1]),"\n";
