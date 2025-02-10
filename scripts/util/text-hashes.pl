#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# text-hashes.pl
# Prints various hashes of the UTF-8 transformations of the Unicode codepoints of incoming text.
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
##############################################################################################################

use v5.36;
use strict;
use warnings;
use utf8;
use Digest::MD5   qw( md5_hex );
use Digest::SHA   qw( sha1_hex sha224_hex sha256_hex sha384_hex sha512_hex );
use Encode 'encode';

# WOMBAT : When creating hashes of text, one is faced with this pair of problems:
# 1. The hashes in Digest::MD5 and Digest::SHA can't handle codepoints over 255;
#    they trigger "wide character in subroutine entry" errors.
# 2. What is "text"???
#    a. Is it the glyphs we see on a screen or page? Yes, but that  can't be "hashed".
#    b. Is it the corresponding Unicode codepoints?  Yes, but those can't be "hashed".
#    c. Is it the UTF-8 transformations of the Unicode encodings of the glyphs?
#    I would argue that choice (a) is the closest to truth, choice (b) is second-closest, and choice (c) is
#    pretty far from what "text" is. HOWEVER, we're stuck with choice (c), because nether glyphs nor numbers
#    other than in the [0..255] range can be hashed by hashing subroutines. If we send, say, the 茶 character
#    to the MD5 or SHA subs, we die with "wide character in subroutine entry". So we're stuck with sending
#    UTF-8 transformation of our text to the hashing functions.
#
#    There are two ways of doing that:
#    1. Put "-CSDA" on the shebang line, "use Sys::Binmode", store and handle and print all text as Unicode,
#       and transform text to UTF-8 immediately before sending it to the hashing functions.
#    2. Strip "-CSDA" from our shebang line, DON'T "use Sys::Binmode", input and store and handle and output
#       all text as UTF-8 at all steps.
#    Either should work, and the hashes generated should be the same either way. (1) is cleaner, though.

my $i = 0;
for (<>)
{
   ++$i;
   s/\s+$//;
   say "\nLine $i: $_";
   say "MD5    = ", md5_hex    encode 'utf8', $_;
   say "SHA001 = ", sha1_hex   encode 'utf8', $_;
   say "SHA224 = ", sha224_hex encode 'utf8', $_;
   say "SHA256 = ", sha256_hex encode 'utf8', $_;
   say "SHA384 = ", sha384_hex encode 'utf8', $_;
   say "SHA512 = ", sha512_hex encode 'utf8', $_;
}
