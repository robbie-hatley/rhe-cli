#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# qp-to-ascii.pl
# Converts all *.eml files in current directoy from "quoted printable" to
# ASCII (and maybe also to Unicode?).
#
# Edit history:
# Thu Jan 01, 2015: Wrote it. (Date is approximate.)
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Tue Nov 30, 2021: Fixed list-context bug in FILE loop (added "scalar" to force scalar context).
# Mon Mar 03, 2025: Got rid of "common::sense" and "Sys::Binmode".
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
########################################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use MIME::QuotedPrint;

use RH::WinChomp;
use RH::Dir;

my $db        = 0      ; # debug?
my @filenames = ()     ; # names of email files to be processed
my $filename  = ''     ; # name of a file
my $dirname   = ''     ; # name of current working directory
my $section   = 'head' ; # section indicator ('head' or 'body')
my $blflag    = 0      ; # previous-line-was-blank  flag
my $dh        = undef  ; # directory handle

# Iterate through current directory, collecting info on all "*.eml" files:
$dirname = cwd;
opendir($dh, $dirname) or die "Can\'t open directory \"$dirname\". $!.";
my @names = readdir $dh;
FILE: foreach $filename (@names) {
   if ($db) {
      say "In qp-to-ascii, at top of FILE loop.";
      say "Current filename = $filename";
   }

   # We're only interested in "regular" files (not directories, symbolic links,
   # etc), so if current file isn't a regular file, move on to next file:
   next FILE if not -f $filename;

   # We're only interested in "*.eml" files, so if $filename is less than
   # 5 characters in length, move on to next file:
   next FILE if (length($filename) < 5);

   # We're only interested in "*.eml" files, so if last 4 characters of
   # file name are not ".eml", move on to next file:
   next FILE if (not(substr($filename,-4,4) eq '.eml'));

   # If we get to here, push current file name onto list:
   push(@filenames, $filename);
};

closedir($dh);

EMAIL: foreach my $emlname (@filenames)
{
   say "Processing file $emlname.";
   my $txtname = $emlname;
   substr($txtname,-4,4,'.txt');
   open(EHANDLE, '<', $emlname)
      or warn "Cannot open email file $emlname for  input."
      and next EMAIL;
   open(THANDLE, '>', $txtname)
      or warn "Cannot open text  file $txtname for output."
      and close(EHANDLE)
      and next EMAIL;

   $section = 'head';  # The first few lines are always the header.
   $blflag  = 0;       # We haven't yet printed any blank lines.

   # Process each line of text in current email, converting from
   # "quoted printable" to ASCII and deleting junk lines:
   LINE: while (<EHANDLE>)
   {
      # INITIAL GLOBAL ACTIONS (actions I take regardless of section):

      # Windows-chomp:
      winchomp;

      # SECTION SWITCH (take different actions depending on section):

      # Header section:
      if ($section eq 'head')
      {
         # If this line starts with 'Content-Type: text/plain',
         # next line is beginning of body section:
         if (m#Content-Type: text/plain#)
         {
            $section = 'body';
         }

         # Skip unnecessary headers:
         next LINE if not m#^(?:Date:|Subject:|To:|From:)#i;
      }

      # Body section:
      else
      {
         # If this line starts with 'PPID' do not print this line and exit
         # LINE loop here, because the first line marked 'PPID' is the first
         # line of the lengthy HTML gibberish section which comes after the
         # legible "plain text" section:
         last LINE if 'PPID' eq substr($_, 0, 4);

         # Otherwise, decode from quoted-printable to ASCII.
         #
         # Note that I'm purposely mis-using decode_qp() here. Normally, it converts
         # each " =\x0d\x0a" at line ends into a single space, so that the lines of
         # each paragraph are merged into one paragraph with one "\x0d\x0a" at the end.
         #
         # But the emails I'm printing already have lines chopped to just the length
         # I like, so I'm retaining "one CRLF per line" instead of going over to
         # "one CRLF per paragraph". So to purposely sabotage decode_qp() from merging
         # lines, I chomp-off the \x0d\x0a at the ends of all lines (see "INITAL GLOBAL
         # ACTIONS section above).
         #
         # This does necessitate manually getting rid of the " =" at the ends of lines,
         # but that is easily accomplished:

         $_ = decode_qp($_); # Decode quoted-printable to ASCII.
         s/ =$//g;           # Get rid of " =" line endings.

      }

      # FINAL GLOBAL ACTIONS (actions I take regardless of section):

      # Strip all leading and trailing whitespace from current line.
      # (If line consists only of whitespace, line will now become ''.)
      s/^\s+//g; # strip all leading  whitespace
      s/\s+$//g; # strip all trailing whitespace

      # If the last line we printed was blank,
      # and if the current line is also blank,
      # then don't print current line:
      if ($blflag)        # if the previous line we printed was blank
      {
         if ($_ eq '')    #    if current line is also blank,
         {
            next LINE;    #       skip current line.
         }                #
         else             #    otherwise,
         {
            $blflag = 0;  #       reset "blank line" flag to false
         }
      }
      else                # else if previous line was NOT blank,
      {
         if ($_ eq '')    #    if current line IS blank,
         {
            $blflag = 1;  #       set the "blank line" flag to true
         }
         else             #    otherwise,
         {
            ;             #       do nothing.
         }
      }

      # Print line:
      print(THANDLE "$_\x0d\x0a");
   }                      # end LINE loop
   close(EHANDLE);        # close *.eml handle
   close(THANDLE);        # close *.txt handle
}                         # end EMAIL loop
exit 0;                   # Exit program and return "success" code.
