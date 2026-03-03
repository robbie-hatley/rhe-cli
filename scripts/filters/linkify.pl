#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# linkify.pl
# Converts any text document into an HTML document with all of the contents
# of the original, but with any HTTP URLs converted to clickable hyperlinks.
# Input is from the file(s) given as argument(s) on the command line.
# If no file(s) (is)|(are) specified, input is from stdin.
# (To redirect input from a file, use "<" on the command line.)
# Output is to stdout.
# (To redirect output to  a file, use ">" on the command line.)
#
# Written by Robbie Hatley on Saturday January 10, 2015.
#
# Edit history:
# Sat Jan 10, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Sep 16, 2020: Changed "print" to "say". Changed "http" to "https".
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Fri Aug 02, 2024: Upgraded to "v5.36"; got rid of "common::sense"; got rid of "Sys::Binmode".
# Sat Aug 03, 2024: Added "use utf8". Got rid of "use RH::Util" (unneeded).
########################################################################################################################

use v5.36;
use utf8;

# First print the standard opening lines of an HTML file.
# The title will be "Linkifyed HTML Document",
# the body text is in a "div" element,
# and the paragraphs will have 5-pixel margins on all 4 sides:
say '<html>';
say '<head>';
say '<title>Linkifyed HTML Document</title>';
say '<style>p{margin:5px;}</style>';
say '</head>';
say '<body>';
say '<div>';
say '<pre>';

# A valid URL must consist solely of the following 82 characters
#
#    alphanumeric:       [:alnum:]       62
#    reserved:           ;/?:@=&          7
#    anchor-id:          #                1
#    encoding:           %                1
#    special:            $_.+!*'(),-     11
#                                 Total: 82

# Make a regex character class string consisting of the above 82
# URL-legal characters:
my $Legal = q<[[:alnum:];/?:@=&#%$_.+!*'(),-]>;

# Make a regex string specifying a cluster of 2-63 DNS-valid characters:
my $Dns = q<[0-9A-Za-z-]{1,63}>;

# Make a regex string specifying a URL header:
my $Header = q<s?https?://>;

# Make a regex string specifying a URL suffix:
my $Suffix = qq<(?:$Dns\\.){1,62}$Dns/$Legal+>;

# $Regex1 says "find a string which is probably a URL suffix, either at the
# beginning of a line or preceded by some white space or a double quote,
# and save any such found probable-suffix as a backreference":
my $Regex1 = qr{((?:^$Suffix)|(?:(?<=[\s"])$Suffix))};
#print $Regex1,"\n";

# $Regex2 says "find a string which is probably a URL with header, either at the
# beginning of a line or preceeded by some white space or a double quote,
# and save any such found probable-URL as a backreference":
my $Regex2 = qr{((?:^$Header$Suffix)|(?:(?<=[\s"])$Header$Suffix))};
#print $Regex2,"\n";

# Loop through the lines of the files specified by the command-line argument.
# (If no files were specified, "while (<>)" reads from stdio instead.)
while (<>)
{
   # Tack 'https://' onto be beginning of any strings which are probably URLS but
   # lack 'https?://':
   $_ =~ s{$Regex1}{https://$1}g; # and print "Regex1 matched $& \n";

   # Wrap each found URL in an html anchor element with the found URL used both
   # as the "href" atttribute and as the text:
   $_ =~ s{$Regex2}{<a href="$1">$1</a>}g; # and print "Regex2 matched $& \n";

   # Print the edited line.  If the line did not contain a URL, it will be
   # printed unexpurgated, including the original endline character, which
   # is never chomped.

   print;

}

# Print element-closure tags for pre, div, body, html:
print ("</pre>\n");
print ("</div>\n");
print ("</body>\n");
print ("</html>\n");
