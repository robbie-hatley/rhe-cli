#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-system-type.pl
# Prints the type of the file system on the partition on which the current directory is located.
# Written by Robbie Hatley.
# Edit history:
# Thu Aug 16, 2024: Wrote program (possibly based on earlier version with different name).
# Thu Mar 06, 2024: Simplified. Reduced min ver from "5.36" to "5.00".
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Mon May 05, 2025: Reverted to "-C63", "utf8", "Cwd", "Encode::decode_utf8" for Cygwin compatibility.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Encode 'decode_utf8';
use Filesys::Type 'fstype';

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);
   This program prints the file-system type of the current working directory.
   All options and arguments are ignored (except for "-h" or "--help", which
   print this help and exit).
   END_OF_HELP
}

# If user wants help, just print help and exit:
for (@ARGV) {
   /^-h$|^--help$/ and help and exit;
}

# Otherwise, print the file-system type of the current working directory:
my $cwd = decode_utf8(getcwd);
my $fst = fstype($cwd);
print "File system time for directory \"$cwd\" is \"$fst\".\n";
