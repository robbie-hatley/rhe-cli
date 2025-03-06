#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# delete-narrow-images.pl
# Deletes all images in current directory which have width < height.
# (Ignores all files that aren't pictures.)
#
# Written by Robbie Hatley.
#
# Edit history:
# Fri Nov 19, 2021: Refreshed shebang, colophon, titlecard, and boilerplate. Corrected Unicode issues.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Nov 25, 2021: Added help, and put main body of program in a block.
# Sun Dec 25, 2022: Corrected comments.
# Thu Aug 15, 2024: Narrowed from 120 to 110, "use v5.36", and removed unnecessary "use" statements.
#                   Changed name from "erase-narrow-images.pl" to "delete-narrow-images.pl".
# Tue Mar 04, 2024: Got rid of prototypes and empty sigs.
##############################################################################################################

use v5.36;
use utf8;
use Encode qw( encode_utf8 decode_utf8 );
use Cwd;
use File::Type;
use Image::Size;

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "delete-narrow-images.pl". This program deletes all image files in the
   current directory which have width < height. Other than "-h" or "--help" (which
   cause this program to print this help then exit), all options and arguments are
   ignored.

   Happy narrow image deleting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
} # end sub help

for my $arg (@ARGV) {
   if ('-h' eq $arg || '--help' eq $arg) {
      help;
      exit(777);
   }
}

# Make a file-typing functor:
my $typer = File::Type->new();

# Obtain and store decoded Current Working Directory (cwd):
my $curdir = decode_utf8 getcwd;

# Obtain and store decoded paths of all non-hidden files in current working directory:
my @paths = map {decode_utf8 $_} <*>;

# Loop through @paths and erase all narrow images:
foreach my $path (@paths) {
   # Skip this path if it doesn't point to something that actually exists:
   next if !-e encode_utf8 $path;

   # Stat this path to load its stats into Perl's internal file-info buffer (so we can use "_" to save time):
   lstat encode_utf8 $path;

   # Skip this file if it's a non-file, link, dir, blk-spc, chr-spc, pipe, socket, or tty:
   next if !-f _ || -d _ || -l _ || -b _ || -c _ || -p _ || -S _ || -t _ ;

   # Skip this file if it's not an image file:
   next if $typer->checktype_filename($path) !~ m/image/;

   # Get image width and height:
   my ($x, $y) = imgsize($path);

   # Erase this images if its width is less than its height:
   if ($x < $y) {
      say "Deleting \"$path\" ($x x $y)";
      unlink(encode_utf8($path)) or say STDERR q%Error: couldn't unlink file.%;
   }
}
