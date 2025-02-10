#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

sub review()
{
   print ((<<'   END_OF_REVIEW') =~ s/^   //gmr);
   Perl is my favorite computer programming language.
   Some of the specific things I like about Perl are
   the following:

    1. @All $of %the $nouns @are $distinguished $from
       verbs %by @sigils. (Once you understand that,
       you'll start to appreciate its value.)

    2. Perl's usage of "{", "}", and ";" is exactly
       like in C, C++, CSS, Sed, Awk, etc, so people
       who are familiar with any of the older languages
       will find Perl a breeze.

    3. Formatting and white space is optional, except
       for the need to have at least one space between
       tokens so they don't get runtogether and confuse
       the Perl interpreter. (Whereas in Python, if the
       formatting and whitespace isn't just perfect,
       the program won't even run. And some of those
       whitespace errors are literally invisible and
       require turning-on "show non-printing characters"
       in your text editor and wasting time visually
       inspecting your whitespace instead of doing
       actual programming.)

    4. Perl excels at processing Unicode (whereas most
       other languages handle it clumsily or not at all).

    5. Perl excels at accessing files, walking directory
       trees, and maintaining file systems (whereas most
       other languages handle it clumsily or not at all).

    6. Perl scripts are often able to combine a sequence
       of operations in one short line, whereas the same
       thing in other languages would be many pages of code.
       Print-out the lines of a text file in reverse-sorted
       order? Easy: "print for reverse sort <>;" That's the
       entire Perl program for that!

    7. If you make your subroutines return 1 for success
       or 0 for failure, then you can use the "and" and "or"
       keywords to make natural-language phrases such as
       "process_file and print_result or cleanup_mess and
       die;" which does exactly what it says.

    8. Most things can be done in multiple ways in Perl.
       "TIMTOWTDI", as Perl programmers like to say; that's
       short for "There Is More Than One Way To Do It".

    9. People who merely like Perl call it "Practical
       Extraction and Report Language". But people who
       truly love Perl call it "Pathologically Eclectic
       Rubbish Lister". And it's just that: a language
       with a large, eclectic collection of features,
       many borrowed from other languages.

   10. CPAN (Comprehensive Perl-module Archive Network)
       is a vast global network of Perl modules you can
       download, install, and use for free, to accomplish
       nearly any task you can imagine (and some that you
       CAN'T imagine).

   So there's a lot to like about Perl, which is why it's
   on my short list of the first 4 languages every
   computer programmer should learn: C, C++, Perl, Python.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_REVIEW
   return 1;
} # end sub review()
review();
exit 0;
