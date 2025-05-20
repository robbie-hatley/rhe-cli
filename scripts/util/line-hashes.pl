#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# line-hashes.pl
# Prints various hashes of the UTF-8 transformations of the Unicode codepoints of lines of incoming text.
# NOTE: This script is for generating hashes of individual lines of text only. To hash entire files, use
# my scripts "file-hashes.pl" instead.
#
# Edit history:
# Thu Jan 14, 2021: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Nov 25, 2021: Simplified (got rid of unnecessary temp variables). Fixed bug which was causing program to
#                   crash for all codepoints over 255 (the solution was to hash the UTF-8 transformations
#                   instead of trying to hash the raw Unicode codepoints).
# Thu Aug 10, 2023: Reduced width from 120 to 110. Upgraded to "v5.36". Got rid of "common::sense".
#                   Cleaned-up comments and experimented with alternate ways of doing this.
# Tue Mar 25, 2025: Changed shebang from "#!/usr/bin/env -S perl -CSDA" to "#!/usr/bin/env perl" and got rid
#                   of "use Encode". This way is more efficient because I no-longer have to encode anything;
#                   it's all just "bytes in, bytes out, don't mess with the bytes". Also got rid of all
#                   non-ASCII characters, "use utf8", "use strict", and "use warnings". Also reduced minimum
#                   version required from "5.36" to "5.16" as we don't need any advanced features.
# Sat May 17, 2025: Renamed from "text-hashes.pl" to "line-hashes.pl" to more-clearly indicate function.
##############################################################################################################

use v5.16;
use Digest::MD5   qw( md5_hex );
use Digest::SHA   qw( sha1_hex sha224_hex sha256_hex sha384_hex sha512_hex );

=pod
When creating hashes of text, one is faced with these two problems:
1. The hashes in Digest::MD5 and Digest::SHA can't handle codepoints over 255;
   they trigger "wide character in subroutine entry" errors.
2. What is "text"???
   a. Is it the glyphs we see on a screen or page? Yes, but that  can't be "hashed".
   b. Is it the corresponding Unicode codepoints?  Yes, but those can't be "hashed".
   c. Is it the UTF-8 transformations of the Unicode encodings of the glyphs?
   I would argue that choice (a) is the closest to truth, choice (b) is second-closest, and choice (c) is
   pretty far from what "text" is. However, only choice (c) can be hashed, because only choice (c) consists
   of bytes, and hashing functions hash bytes. So UTF-8 it is.
There are two ways of sending UTF-8 transformations of text to hashing functions:
1. Put "-CSDA" on the shebang line, store and handle and print all text as Unicode, and transform the text
   to UTF-8 using Encode::encode immediately before sending it to the hashing functions.
2. Strip "-CSDA" from shebang line and input, store, handle, and output all text as UTF-8 at all steps.
Either works. 2023-08-10 to 2025-03-24, I used method 1. But on 2025-03-25 I switched to method 2, because
that way I don't have to encode anything; it's all just "bytes in, bytes out, don't mess with the bytes".
=cut

my $i = 0;
for (<>) {
   ++$i;
   s/\s+$//;
   say "\nLine $i: $_";
   say "MD5    = ", md5_hex    $_ ;
   say "SHA001 = ", sha1_hex   $_ ;
   say "SHA224 = ", sha224_hex $_ ;
   say "SHA256 = ", sha256_hex $_ ;
   say "SHA384 = ", sha384_hex $_ ;
   say "SHA512 = ", sha512_hex $_ ;
}
