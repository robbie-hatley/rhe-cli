#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# get_correct_suffix.pl
# Given a valid path to a data file as first argument, tries hard to determine correct file-name suffix;
# if this can't be done, returns original suffix (if there is one) or ".unk" (if there isn't). Basically
# a skeletal version of my program "get-suffixes.pl" that's not dependent on my "RH" modules.
#
# Written by Robbie Hatley starting on Tue Aug 15, 2023.
#
# Edit Log:
# Tue Aug 15, 2023: Wrote first draft.
# Mon Aug 28, 2023: Changed "$db" to $Db". Got rid of prototypes. Now using Signatures. Improved formatting.
# Wed Sep 06, 2023: Added & edited some comments.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Fri Mar 14, 2024: Got rid of "return on error".
##############################################################################################################

use v5.36;
use utf8;
use Time::HiRes qw( time );
use Encode      qw( :DEFAULT encode decode :fallbacks :fallback_all );
use File::Type;
use List::Util  qw( sum0 );

my $Db = 0; # Debug?

# Prepare constant "EFLAGS" which contains bitwise-OR'd flags for Encode::encode and Encode::decode :
use constant EFLAGS => LEAVE_SRC | WARN_ON_ERR | ;

# Decode from UTF-8 to Unicode:
sub d {
      if (0 == scalar @_) {return Encode::decode('UTF-8', $_,    EFLAGS);}
   elsif (1 == scalar @_) {return Encode::decode('UTF-8', $_[0], EFLAGS);}
   else              {return map {Encode::decode('UTF-8', $_,    EFLAGS)} @_ };
} # end sub d

# Encode from Unicode to UTF-8:
sub e {
      if (0 == scalar @_) {return Encode::encode('UTF-8', $_,    EFLAGS);}
   elsif (1 == scalar @_) {return Encode::encode('UTF-8', $_[0], EFLAGS);}
   else              {return map {Encode::encode('UTF-8', $_,    EFLAGS)} @_ };
} # end sub e

# Is a line of text encoded in ASCII?
sub is_ascii ($text) {
   my $is_ascii = 1;
   foreach my $ord (map {ord} split //, $text) {
      if ($Db) {say STDERR "In is_ascii(), at top of foreach. \$ord = $ord"}
      next if (  9 == $ord ); # HT
      next if ( 10 == $ord ); # LF
      next if ( 11 == $ord ); # VT
      next if ( 13 == $ord ); # CR
      next if ( 32 == $ord ); # SP
      next if ( $ord >=  33
             && $ord <= 126); # ASCII glyph
      # If we get to here, all of the above tests failed, which means that our current character
      # is neither commonly-used ASCII whitespace nor an ASCII glyphical character,
      # so set $is_ascii to 0 and break from loop:
      $is_ascii = 0;
      last;
   }
   if ($Db) {say STDERR "In is_ascii(), about to return. \$is_ascii = $is_ascii"}
   return $is_ascii;
} # end sub is_ascii ($text)

# Is a line of text encoded in iso-8859-1?
sub is_iso_8859_1 ($text) {
   my $is_iso = 1;
   foreach my $ord (map {ord} split //, $text) {
      if ($Db) {say STDERR "In is_iso_8859_1(), at top of foreach. \$ord = $ord"}
      next if (  9 == $ord ); # HT
      next if ( 10 == $ord ); # LF
      next if ( 11 == $ord ); # VT
      next if ( 13 == $ord ); # CR
      next if ( 32 == $ord ); # SP
      next if ( $ord >=  33
             && $ord <= 126); # ASCII glyph
      next if ( $ord >= 160
             && $ord <= 255); # iso-8859-1 character
      # If we get to here, all of the above tests failed, which means that our current character
      # is neither commonly-used iso-8859-1 whitespace nor an iso-8859-1 glyphical character,
      # so set $is_iso to 0 and break from loop:
      $is_iso = 0;
      last;
   }
   if ($Db) {say STDERR "In is_iso_8859_1(), about to return. \$is_iso = $is_iso"}
   return $is_iso;
} # end sub is_iso_8859_1 ($text)

# Is a line of text encoded in Unicode then transformed to UTF-8?
sub is_utf8 ($text) {
   my $is_utf8;
   if ( eval {decode('UTF-8', $text, DIE_ON_ERR|LEAVE_SRC)} ) {
      $is_utf8 = 1;
   }
   else {
      $is_utf8 = 0;
   }
   if ($Db) {say STDERR "In is_utf8(), about to return. \$is_utf8 = $is_utf8"}
   return $is_utf8;
} # end sub is_utf8 ($text)

# Return 1 if-and-only-if a path points to a data file (an existing, non-link, non-dir, regular file):
sub is_data_file ($path) {
   return 0 if ! -e e $path;
   lstat e $path;
   return 0 if   -l _ ;
   return 0 if   -d _ ;
   return 0 if ! -f _ ;
   return 1;
} # end sub is_data_file ($path)

# Return the name part of a file path:
sub get_name_from_path ($path) {
   # If $path does not contain "/", then consider $path to be an unqualified
   # file name, so return $path:
   if (-1 == rindex($path,'/')) {
      return $path;
   }

   # Else if the right-most "/" of $path is to the left of the final character,
   # return the substring of $path to the right of the right-most "/":
   elsif (rindex($path,'/') < length($path)-1) {
      return substr($path, rindex($path,'/') + 1);
   }

   # Else "/" is the final character of $path, so this $path contains no
   # file name, so return an empty string:
   else {
      return '';
   }
} # end sub get_name_from_path ($path)

# Given any string, return last dot and following characters:
sub get_suffix ($string) {
   my $dotindex = rindex($string, '.');
   return ''      if -1 == $dotindex;
   return $string if  0 == $dotindex;
   return substr($string, $dotindex);
} # end sub get_suffix ($string)

# Attempt to get the correct suffix for the name of a file at a given path, ignoring the existing suffix
# (if any) and basing our type determination on the "checktype_filename" method of modules "File::Type"
# and/or on direct examination of the contents of the file. If we are unable to determine the correct suffix
# through these methods, then return the existing suffix (if any), or return '.unk' if there is no existing
# suffix, or return '***ERROR***' if an error occurs (no file, not-data-file, file open/read/close error,
# we don't have permission to read the file, etc).
sub get_correct_suffix ($path) {
   if ( $Db ) {
      say STDERR '';
      say STDERR "In get_correct_suffix(), at top.";
      say STDERR "\$path = $path";
   }

   # Return an error code unless $path points to an existing data file:
   return '***ERROR***' unless is_data_file($path);

   # Try to determine the correct suffix using the checktype_filename() method from module "File::Type":
   my $name  = get_name_from_path($path);
   my $suff  = get_suffix($name);
   my $typer = File::Type->new(); # File-typing functor.
   my $type  = $typer->checktype_filename($path); # Get media-type of file at $path.

   # If checktype_filename() crashed, either the file is corrupt or we don't have permission to access it;
   # either way, it's an error:
   return '***ERROR***' unless defined $type;

   # If we get to here, we've successfully obtained the media type of the file at $path.
   # Now lets "normalize" that type, converting it to all-lower-case and getting rid of cruft:
   $type = lc $type;      # Lower-case the type.
   $type =~ s%/x(-|.)%/%; # Get rid of "unregistered "markers ("x-" and variants).
   $type =~ s%\+\pL+%%;  # Get rid of alternate type interpretations (eg, xml for svg).

   # Announce type if debugging:
   if ( $Db ) {
      say STDERR '';
      say STDERR "In get_correct_suffix(), just got type.";
      say STDERR "\$type = $type";
   }

   # Match normalized type against known types and choose extension if possible:
   for ( $type ) {
      m%^video/msvideo$%                                   and return '.avi'  ;
      m%^image/bmp$%                                       and return '.bmp'  ;
      m%^application/freearc$%                             and return '.arc'  ;
      m%^text/css$%                                        and return '.css'  ;
      m%^text/csv$%                                        and return '.csv'  ;
      m%^application/msword$%                              and return '.doc'  ;
      m%^application/epub$%                                and return '.epub' ; # Also epub+zip
      m%^image/gif$%                                       and return '.gif'  ;
      m%^application/gzip$%                                and return '.gzip' ;
      m%^text/html$%                                       and return '.html' ;
      m%^image/vnd.microsoft.icon$%                        and return '.ico'  ;
      m%^application/java-archive$%                        and return '.jar'  ;
      m%^image/jpeg$%                                      and return '.jpg'  ;
      m%^text/javascript$%                                 and return '.js'   ;
      m%^application/javascript$%                          and return '.js'   ;
      m%^application/json$%                                and return '.json' ;
      m%^audio/midi$%                                      and return '.mid'  ;
      m%^audio/mp3$%                                       and return '.mp3'  ;
      m%^video/mp4$%                                       and return '.mp4'  ;
      m%^video/mpeg$%                                      and return '.mpg'  ;
      m%^application/vnd.oasis.opendocument.presentation$% and return '.odp'  ;
      m%^application/vnd.oasis.opendocument.spreadsheet$%  and return '.ods'  ;
      m%^application/vnd.oasis.opendocument.text$%         and return '.odt'  ;
      m%^audio/ogg$%                                       and return '.ogg'  ;
      m%^font/otf$%                                        and return '.otf'  ;
      m%^image/png$%                                       and return '.png'  ;
      m%^application/pdf$%                                 and return '.pdf'  ;
      m%^application/httpd-php$%                           and return '.php'  ;
      m%^application/vnd.ms-powerpoint$%                   and return '.ppt'  ;
      m%^application/vnd.rar$%                             and return '.rar'  ;
      m%^application/rtf$%                                 and return '.rtf'  ;
      m%^application/sh$%                                  and return '.sh'   ;
      m%^image/svg$%                                       and return '.svg'  ; # Also svg+xml
      m%^application/tar$%                                 and return '.tar'  ;
      m%^text/plain$%                                      and return '.txt'  ; # Never actually comes up.
      m%^image/tiff$%                                      and return '.tiff' ;
      m%^font/ttf$%                                        and return '.ttf'  ;
      m%^audio/wav$%                                       and return '.wav'  ;
      m%^audio/webm$%                                      and return '.weba' ;
      m%^video/webm$%                                      and return '.webm' ;
      m%^image/webp$%                                      and return '.webp' ;
      m%^application/vnd.ms-excel$%                        and return '.xls'  ;
      m%^text/xml$%                                        and return '.xml'  ;
      m%^application/vnd.mozilla.xul$%                     and return '.xul'  ; # Also xul+xml
      m%^application/zip$%                                 and return '.zip'  ;
      m%^application/7z-compressed$%                       and return '.7z'   ;
   }

   # If we get to here, we haven't returned a suffix yet, which means that checktype_filename() from CPAN
   # module "File::Type" was NOT able to determine the type of this file. So we'll have to use other methods.

   # If this file is at-least 32 bytes in size, let's grab AT-LEAST the first 32 bytes of its contents,
   # up to a max of 1048576 bytes, and examine the contents for clues as to what kind of file this is,
   # or if we CAN'T read at least 32 bytes, return "***ERROR***":
   my $size = -s e $path;
   my $buffer = '';
   if ( $size >= 32 ) {
      my $fh = undef;
      open($fh, '< :raw', e $path)                    or return '***ERROR***' ; # File can't be opened.
      read($fh, $buffer, 1048576)                     or return '***ERROR***' ; # File can't be read.
      close($fh)                                      or return '***ERROR***' ; # File can't be closed.
      my $bytes = length($buffer);
      $bytes >= 32                                    or return '***ERROR***' ; # Didn't read 32 bytes.

      if ( $Db ) {
         say STDERR '';
         say STDERR "In get_correct_suffix(), just loaded \$buffer.";
         say STDERR "\$size  = $size";
         say STDERR "\$bytes = $bytes";
      }

      # Pore over the contents of $buffer and try to glean clues as to what type of file this is:
      if ( $type eq 'application/octet-stream' ) {
         'wOFF' eq substr($buffer,0,4)                     and return '.woff' ; # Web Open Font Format
         is_ascii($buffer)                                 and return '.txt'  ; # ASCII      text file.
         is_iso_8859_1($buffer)                            and return '.txt'  ; # ISO-8859-1 text file.
         is_utf8($buffer)                                  and return '.txt'  ; # UTF-8      text file.
      }
      "AVI" eq substr($buffer, 8, 3)                       and return '.avi'  ; # AVI (Windows video)
      pack('C4',195,202,4,193) eq substr($buffer,0,4)      and return '.ccf'  ; # CCF (Chrome Cache File)
      'fLaC' eq substr($buffer,0,4)                        and return '.flac' ; # fLaC (high-quality sound)
      'FLV' eq substr($buffer,0,3)                         and return '.flv'  ; # FLV (FLash Video)
      'GIF' eq substr($buffer,0,3)                         and return '.gif'  ; # GIF (lo-color grphcs; anim)
      $buffer =~ m%^<!DOCTYPE HTML%                        and return '.html' ; # HTML (markup)
      '\xFF\xD8\xFF' eq substr($buffer,0,3)                and return '.jpg'  ; # JPG (lossy compression)
      'ftypmp4' eq substr($buffer,4,7)                     and return '.mp4'  ; # MP4 (good video format)
      'PAR2' eq substr($buffer,0,4)                        and return '.par2' ; # PAR2 (checksum)
      'PDF' eq substr($buffer,1,3)                         and return '.pdf'  ; # PDF (Portable Document Fmt.)
      'PNG' eq substr($buffer,1,3)                         and return '.png'  ; # PNG (Portable Network Grph.)
      'Rar' eq substr($buffer,0,3)                         and return '.rar'  ; # RAR (compressed archive)
      'WAVEfmt' eq substr($buffer,8,7)                     and return '.wav'  ; # WAV (lossless sound)
      pack('C[16]',  48,  38, 178, 117, 142, 102, 207,  17,
                    166, 217,   0, 170,   0,  98, 206, 108)
         eq substr($buffer,0,16)                           and return '.wma'  ; # WMA (Windows Media Audio)
      '\x30\x26\xB2\x75\x8E\x66\xCF\x11'.
      '\xA6\xD9\x00\xAA\x00\x62\xCE\x6C'
         eq substr($buffer,0,16)                           and return '.wmv'  ; # WMV (Windows Media Video)
   }

   # If we get to here, we've failed to definitively determine the correct suffix for-sure, so return the
   # original suffix, unless it was blank, in which case return '.unk':
   $suff eq ''                                             and return '.unk'    # File of unknown type.
                                                            or return $suff   ; # Return original suffix.
} # end sub get_correct_suffix ($path)

# Give user some help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "get-correct-suffix.pl". Given a valid path to a data file as first
   argument, this program attempts to determine the correct file-name suffix; if
   this can't be done, this program returns the original suffix (if there is one)
   or ".unk" (if there isn't).

   -------------------------------------------------------------------------------
   Command lines:

   get-correct-suffix.pl [-h|--help]    (to print this help and exit)
   get-correct-suffix.pl path           (to get correct suffix )

   -------------------------------------------------------------------------------
   Description of options:

   There are no options. Any option you attempt to use would be interpreted as a
   file path, so don't try to use options.

   -------------------------------------------------------------------------------
   Description of arguments:

   This program requires exactly one mandatory argument, which must be a path to
   an existing, regular, non-link, non-directory file.

   Happy suffix determining!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

my $NA = scalar @ARGV;
for ( @ARGV ) { /-h/ || /--help/ and help and exit ; }
($NA != 1) || !-e(e($ARGV[0])) || !-f(e($ARGV[0])) || -d(e($ARGV[0])) || -l(e($ARGV[0]))
and die "Error: this program must have one argument, which must be \n".
        "-h or --help or a path to an existing regular file.\n";
say get_correct_suffix($ARGV[0]);
