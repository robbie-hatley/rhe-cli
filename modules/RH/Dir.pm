# This is a 110-character-wide UTF-8 Unicode Perl source-code text file with hard Unix line breaks ("\x{0A}").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# Dir.pm
# Robbie Hatley's Directory Tools Module
# Written by Robbie Hatley, starting 2015-03-24
# Contains various utilities for working with directories and files.
# Edit history:
# Tue Jan 23, 2015: Started writing it.
# Fri Jul 10, 2015: Upgraded for utf8.
# Wed Jul 19, 2017: Disallowed case-change rename, and updated comments.
# Mon Dec 18, 2017: Improved comments in RecurseDirs.
# Mon Dec 25, 2017: use 5.026_001, and shortened many lines and comments.
# Sun Dec 31, 2017: Now using Exporter.
# Tue Jun 05, 2018: use v5.20
# Sun Mar 08, 2020: use v5.30.3, and added sub "clone_file".
# Wed Aug 05, 2020: Did minor cleanup of some formatting (line lengths);
#                   also added some comments; also v5.30.3.
# Tue Sep 15, 2020: Clarified comments in GetFiles about the return values from glob_utf8(). Also replaced
#                   "copy" with "cp" in clone_file() as copy was smashing timestamps.
# Tue Oct 27, 2020: Added subs eight_rand_lc_letters and find_available_random.
# Thu Dec 31, 2020: Increased width of this file to 110 characters. Got rid of subs "copy_wide_jpgs",
#                   "directory_exists", "aggregate_file", "clone_file", and "merge_file". Added subs
#                   "copy_large_images_verbatim", "copy_large_images_sha1", "is_large_image", "copy_file",
#                   "copy_file_unique", "move_file", "move_file_unique".
# Fri Jan 01, 2021: Got rid of subs "copy_file_unique" and "move_file_unique". Instead, I changed subs
#                   "copy_file" and "move_file" to have prototype ($$;@) so that they can take unlimited
#                   additional arguments. They're now looking for 'unique', 'rename', and 'sha1', and I can
#                   add additional functionality at any time without breaking backwards compatibility by
#                   simply checking for more arguments.
# Sun Jan 03, 2021: Added sub "get_suffix_from_type".
# Mon Jan 11, 2021: Added sub "sha1".
# Sat Feb 13, 2021: Fixed some bugs in "glob_regexp_utf8": removed globbing and decoding of directory, which
#                   were causing trouble; this function now requires that the directory input already be
#                   decoded from (whatever) to raw Unicode. This shouldn't be a problem if d(getcwd)) is used;
#                   however, using glob() or <* .*> as source for directory will cause trouble.
# Tue Feb 16, 2021: Completely re-wrote GetFiles() to use glob_regexp_utf8. Refactored both subs to require
#                   a fully-qualified directory (starting with '/') as their first argument.
# Sat Jul 24, 2021: Merged all 6 of my hash subs into a single sub named "hash" to get rid of massive
#                   duplication.
# Wed Nov 16, 2021: Re-arranged order of UTF-8-related subs, putting the simple ones on-top. Added warning
#                   text regarding bareword file handles. Also, now using "use common::sense;".
# Sat Nov 20, 2021: use v5.32. Renewed colophon. Revamped pragmas & encodings.
# Sun Nov 21, 2021: Changed name of "find_available_name" to "find_avail_enum_name", and fixed bug which was
#                   causing "enumerate-file-names.pl" to DENUMERATE file names, due to sub
#                   "find_available_name" returning the denumerated version of a file name if that was
#                   available for use. That is stupid, because for "enumerate-file-names.pl" to work right,
#                   sub find_available_name MUST return an enumerated name!
# Mon Nov 22, 2021: Changed name of "find_available_random" to "find_avail_rand_name".
#                   Changed name of "copy_large_images" to "copy_files" and widened its scope of usefulness.
#                   Changed name of "move_large_images" to "move_files" and widened its scope of usefulness.
#                   Massively refactored multiple subs. Fixed many errors which I'd introduced in the process.
# Fri Nov 26, 2021: Clarified some comments.
# Fri Aug 19, 2022: Got rid of "#use Win32API::File;" as my scripts are all now dual-OS (Linux+Windows).
# Sun Feb 19, 2023: Added "is_valid_qual_dir".
# Sat Mar 11, 2023: Made MANY changes, mostly regarding skipping problematic directories in Windows and Linux.
# Sat Jul 29, 2023: Dramatically improved handling of existent links to non-existent things, by first dumping
#                   the contents of an lstat into an array "@stats" then checking the scalar of that array;
#                   if it's 13, everything is hunky-dory; if < 13 then the lstat failed so do special handing.
#                   Also fixed a bug which I inadvertently introduced by doing "if ( ! -e $path )" when I
#                   should have written "if ( ! -e e $path )" instead. ($path MUST be encoded before sending
#                   it to either lstat or any of the file-test operators.) Also reduced width to 110.
# Tue Aug 08, 2023: Updated from "v5.32" to "v5.36". Inserted many instances of ":prototype" before every
#                   prototype, both in all subroutine predeclarations AND all subroutine definitions.
#                   Converted bracing to C-style (no left braces on their own lines).
# Thu Aug 09, 2023: Added *.mp4 type, and set "$type = lc $type".
# Sun Aug 12, 2023: Re-enabled "use Filesys::Type;".
# Mon Aug 14, 2023: Morphed "get_suffix_from_type" into "get_correct_suffix".
# Tue Aug 15, 2023: Re-DIS-abled "use Filesys::Type;"; it's too slow and buggy.
# Fri Jun 14, 2024: Wrote "get_dirname_from_path".
# Wed Jul 31, 2024: Got rid of unused variables $OldDir and $NewDir in rename_file().
#                   Changed "rename to 'existing' path" criteria to "$PLATFORM is 'Win64', old and new names
#                   are different, and fc($OldName) eq fc($NewName)".
# Thu Oct 03, 2024: Dramatically-simplified RecurseDirs (got rid of unnecessary restrictions on directories
#                   and removed personal identifying information). Got rid of Sys::Binmode.
# Fri Mar 14, 2025: Changed settings for "d" and "e" so that they leave source intact, use substitution
#                   characters, warn on error, and continue until encoding or decoding is FINISHED.
#                   (They now don't "return on error"). Also, trimmed all dividers and lines to 110 max.
# Fri Apr 25, 2025: Fixed bug in readdir_regexp_utf8 which was causing files NOT in the current working
#                   directory to be erroneously reported as not existing, due to lstat being called on the
#                   file's NAME instead of the file's PATH. Added "corr" option to hash() and copy_file(),
#                   telling them to correct the file-name suffix of the target file if necessary.
# Sun May 04, 2025: Fixed encoding error in is_data_file() (existence check wasn't encoded).
##############################################################################################################

# ======= POD: ===============================================================================================

=encoding utf8

=head1 NAME

RH::Dir - Robbie Hatley's Directory Utilities Module

=head1 DESCRIPTION

A collection of subroutines for managing file systems (especially EXT4 file systems on Linux, but most
of these subroutines are also usable on Microsoft Windows and the NTFS file system if Cygwin is used).

=head1 SUBROUTINES:

=cut

# ======= PACKAGE: ===========================================================================================

package RH::Dir;

# ======= PRAGMAS: ===========================================================================================

# Pragmas:
use v5.36;
use strict;
use warnings;
use utf8;
use warnings FATAL => "utf8";

# Encodings:
use open ':std', IN  => ':encoding(UTF-8)';
use open ':std', OUT => ':encoding(UTF-8)';
use open         IN  => ':encoding(UTF-8)';
use open         OUT => ':encoding(UTF-8)';
# NOTE: these may be over-ridden later. Eg, "open($fh, '< :raw', e $path)".

# ======= MODULES: ===========================================================================================

use parent 'Exporter';
use POSIX 'floor', 'ceil', 'strftime';
use Cwd;
use Digest::MD5   qw( md5_hex );
use Digest::SHA   qw( sha1_hex sha224_hex sha256_hex sha384_hex sha512_hex );
use Encode        qw( encode decode :fallbacks :fallback_all );
use File::Type;
use File::Copy;
use Image::Size;
use List::Util    qw( sum0 none );
use Time::HiRes   qw( time sleep );
use Filesys::Type qw( fstype );
use Switch;

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

# Counters used by subs GetFiles and GetRegularFilesBySize.
# NOTE: These are all reset to 0 EVERY time one of those
# two subs runs, so if you want to accumulate counts of events over multiple
# entries to those subs, you need to store those accumulations in separate
# variables.
our $totfcount = 0; # Count of all directory entries seen, of all types.
our $noexcount = 0; # Count of all files which do not exist.
our $ottycount = 0; # Count of all tty files.
our $cspccount = 0; # Count of all character special files.
our $bspccount = 0; # Count of all block special files.
our $sockcount = 0; # Count of all sockets.
our $pipecount = 0; # Count of all pipes.
our $brkncount = 0; # Count of all symbolic links to nowhere.
our $slkdcount = 0; # Count of all symbolic links to directories.
our $linkcount = 0; # Count of all symbolic links to non-directories.
our $weircount = 0; # Count of all symbolic links to weirdness.
our $sdircount = 0; # Count of all directories.
our $hlnkcount = 0; # Count of all regular files with  > 1 hard links (extroverts).
our $regfcount = 0; # Count of all regular files with == 1 hard links (normies).
our $orphcount = 0; # Count of all regular files with == 0 hard links (orphans).
our $zombcount = 0; # Count of all regular files with  < 0 hard links (zombies).
our $unkncount = 0; # Count of all files of unknown nature.

# ------- Local Variables: -----------------------------------------------------------------------------------

my $Debug = 0; # Set to 1 for debugging, 0 for no debugging.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

# Section 1, Private subroutines (NOT exported):
sub rand_int               :prototype($$)   ; # Get a random integer in closed interval [arg1, arg2].
sub is_ascii               :prototype($)    ; # Is a given text string encoded in ASCII?
sub is_iso_8859_1          :prototype($)    ; # Is a given text string encoded in ISO-8859-1?
sub is_utf8                :prototype($)    ; # Is a given text string encoded in UTF-8?
sub eight_rand_lc_letters  :prototype()     ; # Get a random string of 8 lower-case English letters.

# Section 2, UTF-8-related subroutines:
sub d                                       ; # utf8-decode.
sub e                                       ; # utf8-encode.
sub glob_regexp_utf8       :prototype(;$$$$); # Regexp file globber using opendir/readdir/closedir.
sub readdir_regexp_utf8    :prototype(;$$$$); # Regexp dir  reader  using opendir/readdir/closedir.

# Section 3, Major Subroutines (code is long and complex):
sub GetFiles               :prototype(;$$$$); # Get array of filerecords.
sub GetRegularFilesBySize  :prototype(;$$$) ; # Get hash of arrays of same-size filerecords.
sub FilesAreIdentical      :prototype($$)   ; # Are two files identical?
sub RecurseDirs            :prototype(&)    ; # Recursively walk directory tree.
sub copy_file              :prototype($$;@) ; # Copy a file from source path to destination directory.
sub move_file              :prototype($$;@) ; # Move a file from source path to destination directory.
sub copy_files             :prototype($$;@) ; # Copy files  from source directory to destination directory.
sub move_files             :prototype($$;@) ; # Move files  from source directory to destination directory.

# Section 4, Minor Subroutines (code is (relatively) short and simple):
sub debug                  :prototype(;$)   ; # Turn on debugging in this module.
sub BLAT                   :prototype($)    ; # Print messages only if debugging.
sub rename_file            :prototype($$)   ; # Rename a file, taking precautions.
sub time_from_mtime        :prototype($)    ; # Get time from mtime.
sub date_from_mtime        :prototype($)    ; # Get date from mtime.
sub get_prefix             :prototype($)    ; # Get prefix from file name.
sub get_suffix             :prototype($)    ; # Get suffix from file name.
sub get_dir_from_path      :prototype($)    ; # Get full  directory name from file path.
sub get_dirname_from_path  :prototype($)    ; # Get local directory name from file path.
sub get_name_from_path     :prototype($)    ; # Get name from file path.
sub denumerate_file_name   :prototype($)    ; # Remove all numerators from a file name.
sub enumerate_file_name    :prototype($)    ; # Add a random numerator to a file name.
sub annotate_file_name     :prototype($$)   ; # Annotate a file name (with a note).
sub find_avail_enum_name   :prototype($;$)  ; # Find available enumerated file name for given name root & dir.
sub find_avail_rand_name   :prototype($$$)  ; # Find available   random   file name for given dir & suffix.
sub is_large_image         :prototype($)    ; # Does a file contain a large image?
sub get_correct_suffix     :prototype($)    ; # Return correct file-name suffix for file at given path.
sub cyg2win                :prototype($)    ; # Convert Cygwin  path to Windows path.
sub win2cyg                :prototype($)    ; # Convert Windows path to Cygwin  path.
sub hash                   :prototype($$;$$); # Return hash or hash-based file-name of a file.
sub shorten_sl_names       :prototype($$$$) ; # Shorten directory and file names for Spotlight.
sub is_data_file           :prototype($)    ; # Return 1 if a given string is a path to a -f !-l !-d file.
sub is_meta_file           :prototype($)    ; # Return 1 if a given string is a path to a meta-data file.
sub is_valid_qual_dir      :prototype($)    ; # Is a given string a fully-qualified path to an existing dir?
sub update_sha1            :prototype(;$)   ; # Create/update ".sha1" file in directory & return table & flags
sub sha1                   :prototype($)    ; # Return hex SHA-1 hash of a data file.

# ======= EXPORT LISTS: ======================================================================================

# Symbols exported by default:
our @EXPORT =
   qw
   (
      d                       e                       glob_regexp_utf8
      readdir_regexp_utf8

      GetFiles                GetRegularFilesBySize   FilesAreIdentical
      RecurseDirs             copy_file               move_file
      copy_files              move_files

      rename_file             time_from_mtime         date_from_mtime
      get_prefix              get_suffix              get_dir_from_path
      get_dirname_from_path   get_name_from_path      path
      denumerate_file_name    enumerate_file_name     annotate_file_name
      find_avail_enum_name    find_avail_rand_name    is_large_image
      get_correct_suffix      cyg2win                 win2cyg
      hash                    shorten_sl_names        is_data_file
      is_meta_file            is_valid_qual_dir       update_sha1
      sha1
   );

# Symbols which it is OK to export by request:
our @EXPORT_OK =
   qw
   (
      $totfcount $noexcount $ottycount $cspccount $bspccount
      $sockcount $pipecount $brkncount $slkdcount $linkcount
      $weircount $sdircount $hlnkcount $regfcount $orphcount
      $zombcount $unkncount debug
   );

# ======= IMPORTER: ==========================================================================================

=pod

# Import settings INTO this module,
# and export variables and subroutines OUTOF this module:
sub import {
   # Get the "STUFF" from "use RH::Dir qw( STUFF );":
   my @STUFF = @_ ;
   # Make a reference to a scalar variable:
   my $varref = undef;
   # Take appropriate measures for each item in @STUFF:
   while ( @STUFF ) {
      # Get next item:
      my $item = shift @STUFF ;
      # 0th item is always package id; ignore:
      if ( 'RH::Dir' eq $item ) {
         ; # Do nothing.
      }
      # If we're waiting for a value for a var, store it:
      elsif ( defined $varref ) {
         if ( $varref == \$Debug ) {
            switch ($item) {
               case qr/(?i:0|off|no)/ {$$varref = 0}
               case qr/(?i:1|on|yes)/ {$$varref = 1}
            }
         }
         $varref = undef;
      }
      # If we received a debug command, point $varref to $Debug:
      elsif ( 'debug' eq $item ) {
         $varref = \$Debug;
      }
      # Otherwise, $item is something user wants us to export:
      else {
         push @EXPORT, $item;
      }
   }
   RH::Dir->export_to_level(3, @EXPORT);
}

=cut

# ======= SECTION 1, PRIVATE SUBROUTINES: ====================================================================

# Does a given scalar consist only of commonly-used ASCII whitespace and/or glyphical (visible) characters?
sub is_ascii :prototype($) ($text) {
   my ($cpac, $cfil) = caller;
   die "Fatal error: function \"is_ascii\" in module \"RH::Dir\" is private.\n"
   unless $cpac eq __PACKAGE__ && $cfil eq __FILE__;
   my $is_ascii = 1;
   foreach my $ord (map {ord} split //, $text) {
      if ($Debug) {say STDERR "In is_ascii(), at top of foreach. \$ord = $ord"}
      # Is this character a commonly-used ASCII white-space character?
      next if (  9 == $ord ); # HT
      next if ( 10 == $ord ); # LF
      next if ( 11 == $ord ); # VT
      next if ( 13 == $ord ); # CR
      next if ( 32 == $ord ); # SP
      # Is this character an ASCII glyphical (visible) character?
      next if ( $ord >=  33
             && $ord <= 126); # ASCII glyph
      # If we get to here, all of the above tests failed, which means that our current character
      # is neither commonly-used ASCII whitespace nor an ASCII glyphical character,
      # so set $is_ascii to 0 and break from loop:
      $is_ascii = 0;
      last;
   }
   if ($Debug) {say STDERR "In is_ascii(), about to return. \$is_ascii = $is_ascii"}
   return $is_ascii;
} # end sub is_ascii :prototype($) ($text)

# Is a line of text encoded in iso-8859-1?
sub is_iso_8859_1 :prototype($) ($text) {
   my ($cpac, $cfil) = caller;
   die "Fatal error: function \"is_iso_8859_1\" in module \"RH::Dir\" is private.\n"
   unless $cpac eq __PACKAGE__ && $cfil eq __FILE__;
   my $is_iso = 1;
   foreach my $ord (map {ord} split //, $text) {
      if ($Debug) {say STDERR "In is_iso_8859_1(), at top of foreach. \$ord = $ord"}
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
   if ($Debug) {say STDERR "In is_iso_8859_1(), about to return. \$is_iso = $is_iso"}
   return $is_iso;
} # end sub is_iso_8859_1 :prototype($) ($text)

# Is a line of text encoded in Unicode then transformed to UTF-8?
sub is_utf8 :prototype($) ($text) {
   my ($cpac, $cfil) = caller;
   die "Fatal error: function \"is_utf8\" in module \"RH::Dir\" is private.\n"
   unless $cpac eq __PACKAGE__ && $cfil eq __FILE__;
   my $is_utf8;
   if ( eval {decode('UTF-8', $text, DIE_ON_ERR|LEAVE_SRC)} ) {
      $is_utf8 = 1;
   }
   else {
      $is_utf8 = 0;
   }
   if ($Debug) {say STDERR "In is_utf8(), about to return. \$is_utf8 = $is_utf8"}
   return $is_utf8;
}

# Return a random integer in the range [m,n] inclusive:
sub rand_int :prototype($$) ($min, $max) {
   my ($cpac, $cfil) = caller;
   die "Fatal error: function \"rand_int\" in module \"RH::Dir\" is private.\n"
   unless $cpac eq __PACKAGE__ && $cfil eq __FILE__;
   return floor($min+rand($max-$min+1));
} # end sub rand_int

# Return a string of 8 random lower-case English letters:
sub eight_rand_lc_letters :prototype() {
   my ($cpac, $cfil) = caller;
   die "Fatal error: function \"eight_rand_lc_letters\" in module \"RH::Dir\" is private.\n"
   unless $cpac eq __PACKAGE__ && $cfil eq __FILE__;
   return join '', map {chr(rand_int(97, 122))} (1..8);
}

# ======= SECTION 2, UTF-8 SUBROUTINES: ======================================================================

# Prepare constant "EFLAGS" which contains bitwise-OR'd flags for Encode::encode and Encode::decode :

# Should we warn and return? No, let's NOT do that, because it will cause loss of remaining data:
# use constant EFLAGS => LEAVE_SRC | WARN_ON_ERR | RETURN_ON_ERR;
# That would be useful for use with buffers, but we're usually not doing that in my programs. So for my
# "d" and "e" subroutines, let's leave the source intact, use substitute characters, warn user on errors,
# and continue (don't return until encoding or decoding is complete):
use constant EFLAGS => LEAVE_SRC | WARN_ON_ERR;

=head2 d

Decodes items from UTF-8 to raw Unicode codepoints:
sub d(@args)
=cut
sub d :prototype(@) (@args) {
      if (0 == scalar @args) {return Encode::decode('UTF-8', $_,       EFLAGS);}
   elsif (1 == scalar @args) {return Encode::decode('UTF-8', $args[0], EFLAGS);}
   else                 {return map {Encode::decode('UTF-8', $_,       EFLAGS)} @args }
} # end sub d

=head2 e

Encodes items from raw Unicode codepoints to UTF-8:
sub e(@args)
=cut
sub e :prototype(@) (@args) {
      if (0 == scalar @args) {return Encode::encode('UTF-8', $_,       EFLAGS);}
   elsif (1 == scalar @args) {return Encode::encode('UTF-8', $args[0], EFLAGS);}
   else                 {return map {Encode::encode('UTF-8', $_,       EFLAGS)} @args }
} # end sub e

=head2 glob_regexp_utf8

Returns a sorted list of paths, not including "." or "..", in a given directory which match a given
target, regexp, and predicate:

glob_regexp_utf8($dir=d(getcwd), $target='A', $regexp=qr(^.+$)o, $predicate='1')

This sub is like glob(), but using UTF-8, a given directory, a target type, a regular expression
(instead of a csh-style wildcard), and a boolean file-type predicate as inputs, and returning matching
fully-qualified paths as output, with '.' and '..' stripped-out.

Vitally important: the "directory" argument must already be decoded from utf-8 to raw unicode,
otherwise this function will generate "wide character" errors and crash the calling program.
This should automatically be done for you if you use cpan modules "utf8::all" and "cwd::utf8",
or if you use "d(getcwd)", to provide the directory. Using raw "glob()" or "<* .*>" or "readdir",
however, will cause many errors on either linux or cygwin if the calling program attempts to process
file names in any language other than english. (Names such as "Говорю Русский", "ॐ नमो भगवते वासुदेवाय",
"看的星星，知道你是爱。" would crash horribly.)
=cut
sub glob_regexp_utf8 :prototype(;$$$$) ($dir=d(getcwd), $target='A', $regexp=qr(^.+$)o, $predicate='1') {

   # NOTE, RH 2025-04-10: I noticed that this entire subroutine is a duplicate of "readdir_regexp_utf8" except
   # giving fully-qualified paths instead of raw directory entries. But that can be done with "path" and
   # "map", so I just removed most of the content of this subroutine; it's now just a wrapper around
   # "readdir_regexp_utf8".

   my @names = readdir_regexp_utf8($dir, $target, $regexp, $predicate);
   my @paths = map {path($dir, $_)} @names;

   # If debugging, print paths:
   if ($Debug) {
      say STDERR '';
      say STDERR 'In glob_regexp_utf8 at end.';
      say STDERR '@paths:';
      say STDERR for @paths;
      say STDERR '';
   }

   # Return results:
   return @paths;
} # end sub glob_regexp_utf8 (;$$$)

=head2 readdir_regexp_utf8

Returns the contents of a directory, filtered by target, regexp, and predicate:

sub readdir_regexp_utf8($dir=d(getcwd), $target='A', $regexp=qr(^.+$)o, $predicate='1')

This sub is like readdir(), but using UTF-8, a given directory, a target type, a regular expression
(instead of a csh-style wildcard), and a boolean file-type predicate as inputs, and returning matching
entries from the given directory as output, with '.' and '..' stripped-out.

Vitally important: the "directory" argument must already be decoded from utf-8 to raw unicode,
otherwise this function will generate "wide character" errors and crash the calling program.
This should automatically be done for you if you use cpan modules "utf8::all" and "cwd::utf8",
or if you use "d(getcwd)", to provide the directory. Using raw "glob()" or "<* .*>" or "readdir",
however, will cause many errors on either linux or cygwin if the calling program attempts to process
file names in any language other than English. (Names such as "Говорю Русский", "ॐ नमो भगवते वासुदेवाय",
"看的星星，知道你是爱。" would crash horribly.)
=cut
sub readdir_regexp_utf8 :prototype(;$$$$) ($dir=d(getcwd), $target='A', $regexp=qr(^.+$)o, $predicate='1') {

   # If debugging, announce inputs:
   if ($Debug) {
      say STDERR "                                          ";
      say STDERR "In sub \"readdir_regexp_utf8\", near top. ";
      say STDERR "\$dir    = $dir                           ";
      say STDERR "\$target = $target                        ";
      say STDERR "\$regex  = $regexp                        ";
      say STDERR "                                          ";
   }

   # But do those inputs even make any sense?? Let's check now!
   if ( !(-e e($dir)) || !(-d e($dir)) ) {
      die "Fatal error in readdir_regexp_utf8: Invalid directory \'$dir\'.\n$!\n";
   }
   if ( $target !~ m/^[FDBA]$/ ) {
      die "Fatal error in readdir_regexp_utf8: Invalid target \'$target\'.\n$!\n";
   }
   my $re;
   if ( !eval {$re = qr/$regexp/} ) {
      die "Fatal error in readdir_regexp_utf8: Invalid regular expression \'$regexp\'.\n$!\n";
   }

   # Try to open, read, and close $dir; if any of those operations fail, die:
   my $dh = undef;
   opendir($dh, e($dir))
   or die "Fatal error in readdir_regexp_utf8(): Couldn't open  directory \"$dir\".\n$!\n";

   my @raw = sort {$a cmp $b} map {d($_)} readdir($dh);
   scalar(@raw) >= 2 # $dir should contain at least '.' and '..'!
   or die "Fatal error in readdir_regexp_utf8(): Couldn't read  directory \"$dir\".\n$!\n";

   closedir $dh
   or die "Fatal error in readdir_regexp_utf8(): Couldn't close directory \"$dir\".\n$!\n";

   # Iterate through @names, rejecting '.', '..',  and everything that doesn't match $target, $regexp, and
   # $predicate, and storing remainder in an array called @names:
   my @names = ();
   foreach my $name (@raw) {
      if ($Debug) {say STDERR "In readdir_regexp_utf8. Name from readdir: $name"}

      # Skip '.' and '..':
      next if '.'  eq $name;
      next if '..' eq $name;

      # Do NOT run an existence check here, else we will get a constant stream of nuisance warnings,
      # because it is NORMAL for many links to point to things that will not exist until some program
      # is launched or until some media is mounted:
      # if ( ! -e e($name) ) {
      #    warn "Warning in readdir_regexp_utf8(): File \"$name\" in \"$dir\" does not exist.\n";
      #    next NAME;
      # }

      # However, DO run lstat on this name's path, which should return some info even if this file is a
      # broken link. (WARNING: MUST use full path here, not the name, because there is NO guaranty that
      # $dir is the same as our current working directory!!!):
      my @stats = lstat e(path($dir,$name));

      # If lstat failed, print warning and move on to next file:
      if ( scalar(@stats) < 13 ) {
         warn "Warning in readdir_regexp_utf8(): Can't lstat \"$name\" in \"$dir\".\n"
             ."Moving on to next file.\n";
         next;
      }

      $Debug and say "Successfully got 13 stats for name \"$name\".";

      # Skip this file if it doesn't match our target:
      switch($target) {
         case 'F' { if ( !     -f _                 ) {$Debug and say STDERR "Failed F."; next;} }
         case 'D' { if ( !                 -d _     ) {$Debug and say STDERR "Failed D."; next;} }
         case 'B' { if ( ! ( ( -f _ ) || ( -d _ ) ) ) {$Debug and say STDERR "Failed B."; next;} }
         case 'A' {                     ;              $Debug and say STDERR "Accept A.";        }
         else     {                     ;              $Debug and say STDERR "Accept E.";        }
      }

      # Skip this file if it doesn't match our regexp:
      if ($name !~ m/$regexp/) {
         $Debug and say STDERR "Skipping file \"$name\" because its name doesn't match regexp.";
         next;
      }

      # Skip this file if it doesn't match our predicate:
      if ( '1' ne $predicate ) {
         local $_ = e($name);
         if ( ! eval $predicate ) {
            BLAT "Skipping file \"$name\" because it doesn't match predicate.";
            next;
         }
      }

      # If we get to here, include this file among those to be returned:
      push @names, $name;
   } # end foreach my $name (@raw)

   # If debugging, print names:
   if ($Debug) {
      say STDERR '';
      say STDERR 'In readdir_regexp_utf8 at end.';
      say STDERR '@names:';
      say STDERR for @names;
      say STDERR '';
   }

   # Return results:
   return @names;
} # end sub readdir_regexp_utf8

# ======= SECTION 3, MAJOR SUBROUTINES: ======================================================================

=head2 GetFiles

GetFiles returns a reference to an array of filerecords for all files in a user-specified directory.
Optionally, user can also specify a regular expression to match names against and a single-letter "target"
specifying which types of directory entries to process (files, dirs, both, or all):

GetFiles($dir = d(getcwd), $target = 'A', $regexp = qr(^.+$)o, $predicate = '1')

First argument, if present, must be a fully-qualified directory, starting with a '/' character.

Second argument, if present, must be a Perl-Compliant Regular Expression to match directory entries against.

Third argument, if present, must be one of the following letters:
F = regular Files only
D = Directories only (but not SYMLINKDs).
B = Both regular files and directories (but not SYMLINKDs).
A = All files (regular, directories, links, SYMLINKDs, pipes, etc, etc, etc)
=cut
sub GetFiles :prototype(;$$$$) ($dir = d(getcwd), $target = 'A', $regexp = qr(^.+$)o, $predicate = '1') {
   # "$dir"     =  What directory does user want a list of file-info packets for?
   # "$target"  =  'F' = 'Files'; 'D' = 'Directories'; 'B' = 'Both'; 'A' = 'All'.
   # "$regexp"  =  What regular expression should we use for selecting files?

   # If debugging, print diagnostics:
   if ($Debug) {
      say "Debug msg in GetFiles: \$dir       = $dir"       ;
      say "Debug msg in GetFiles: \$target    = $target"    ;
      say "Debug msg in GetFiles: \$regexp    = $regexp"    ;
      say "Debug msg in GetFiles: \$predicate = $predicate" ;
   }

   if ($dir !~ m/^\//) {
      say STDERR "Error in GetFiles: Directory \"$dir\" is invalid.\n"
                ."Directory must start with \"/\".\"\n"
                ."Returning reference to empty anonymous array.";
      return [];
   }

   # Zero all RH::Dir counters here. You should save a copy in main:: if you want to keep this info, because
   # it gets zeroed each time GetFiles or GetRegularFilesBySize are run. These are "per directory info fetch"
   # only.
   $totfcount = 0; # Count of all directory entities seen, of all types.
   $noexcount = 0; # Count of all errors encountered.
   $ottycount = 0; # Count of all tty files.
   $cspccount = 0; # Count of all character special files.
   $bspccount = 0; # Count of all block special files.
   $sockcount = 0; # Count of all sockets.
   $pipecount = 0; # Count of all pipes.
   $brkncount = 0; # Count of all symbolic links to nowhere.
   $slkdcount = 0; # Count of all symbolic links to directories.
   $linkcount = 0; # Count of all symbolic links to files.
   $weircount = 0; # Count of all symbolic links to weirdness.
   $sdircount = 0; # Count of all directories.
   $hlnkcount = 0; # Count of all regular files with  > 1 hard links.
   $regfcount = 0; # Count of all regular files with == 1 hard links.
   $orphcount = 0; # Count of all regular files with == 0 hard links.
   $zombcount = 0; # Count of all regular files with  < 0 hard links.
   $unkncount = 0; # Count of all unknown files.

   # Get fully-qualified paths of all entries (except for '.' and '..') in directory "$dir" which match
   #  target $target, regular expression $regexp, and predicate $predicate:
   my @paths = glob_regexp_utf8($dir, $target, $regexp, $predicate);

   # If debugging, print diagnostics:
   if ($Debug) {
      say 'IN GetFiles. Raw paths from glob_regexp_utf8:';
      say for @paths;
   }

   # Iterate through file paths, collecting info on files and pushing that hashes of that info onto
   # @filerecords, then returning a ref to @filerecords after the loop:
   my @filerecords = ();
   for my $path (@paths) {
      # Increment $totfcount as our first act inside the @filepaths loop, because this should be a count of
      # "all directory entries seen in this directory"; whether any such objects actually exist or are
      # regular files or not is not relevant to "totfcount":
      ++$totfcount;

      # Get the name of this directory entry from its path:
      my $name = get_name_from_path($path);

      # What type of thing is at $path? Categorize as exactly 1 type, to reduce complexity and confusion.
      # Start by determinnig if $path is non-existent. If existent, try to ascertain if it's one of the
      # more rare and dangerous types. Then work down to commonplace objects such as "directories" and
      # "regular files". If all tests fail, mark it 'U' for "unknown".
      #
      # NOTE: the -t test differs from all the others in that its argument defaults to STDIN instead of $_.
      #
      # NOTE: The only way I've been able to find to detect "files with multiple hard links" is to use
      # the "nlinks" returned by stat; if it's >1 then the file is a hard link to an inode which has multiple
      # hard links pointing to it.

      # Type of file:
      my $type;

      # Target of link:
      my $ltarg;

      # Stats variables:
      my @stats;
      my ($Ldev,   $Linode, $Lmode,  $Lnlink,
          $Luid,   $Lgid,   $Lrdev,  $Lsize,
          $Latime, $Lmtime, $Lctime, $Lbsize, $Lblcks);

      # Do an lstat before using any file-test operators, so that they can save time by
      # testing "_" instead of "$path":
      @stats = lstat e $path;

      # Non-existent paths require special handling because stat or lstat returns empty array. So if @stats
      # has fewer than 13 elements, set $type to 'N', increment $noexcount, set our stats variables to 0,
      # set $ltarg to 'NONEXISTENT FILE', and print warning:
      if ( scalar(@stats) < 13 ) {
         warn "Warning from GetFiles: Can't lstat path \"$path\" in directory \"$dir\".\n";
         $type = 'N' ;  # $type = nonexistent
         ++$noexcount;  # increment noex counter
                        # Set all of our stats to 0:
         ($Ldev,   $Linode, $Lmode,  $Lnlink,
          $Luid,   $Lgid,   $Lrdev,  $Lsize,
          $Latime, $Lmtime, $Lctime, $Lbsize, $Lblcks) = (0,0,0,0,0,0,0,0,0,0,0,0,0);
         $ltarg = 'NONEXISTENT FILE';
      } # end if path does NOT exist

      # Otherwise, set our stats variables to the 13 elements of @stats, and determine number of links,
      # target (if any), and type of file:
      else {
         ($Ldev,   $Linode, $Lmode,  $Lnlink,
          $Luid,   $Lgid,   $Lrdev,  $Lsize,
          $Latime, $Lmtime, $Lctime, $Lbsize, $Lblcks) = @stats;
         my $ml = $Lnlink > 1 ? 1 : 0;  # Do multiple incoming hard links exist to this inode?
         $ltarg = 'NO TARGET';         # Assume for now that no outgoing link target exists.
         if       (   -l _       ) {                            # If $path IS a symbolic link to something:
            if    ( ! -e e $path ) {$type = 'X'; ++$brkncount;}    # Symbolic link to nowhere.
            elsif (   -d _       ) {$type = 'R'; ++$slkdcount;}    # Symbolic link to directory.
            elsif (   -f _       ) {$type = 'L'; ++$linkcount;}    # Symbolic link to file.
            else                   {$type = 'W'; ++$weircount;}    # Symbolic link to weirdness.
            $ltarg = d(readlink(e($path)));
            if (not defined $ltarg) {
               $ltarg = 'UNDEFINED TARGET';
            }
         }
         else {                                                 # If $path is NOT a symbolic link to anything:
            if    ( ! -e e $path ) {$type = 'N'; ++$noexcount;}    # Nonexistent.
            elsif (   -d _       ) {$type = 'D'; ++$sdircount;}    # Directory.
            elsif (   -b _       ) {$type = 'B'; ++$bspccount;}    # Block special file.
            elsif (   -c _       ) {$type = 'C'; ++$cspccount;}    # Character special file.
            elsif (   -p _       ) {$type = 'P'; ++$pipecount;}    # Pipe.
            elsif (   -S _       ) {$type = 'S'; ++$sockcount;}    # Socket.
            elsif (   -t _       ) {$type = 'T'; ++$ottycount;}    # Opened to tty.
            elsif (   -f _       ) {                               # File.
                  if ($Lnlink  > 1){$type = 'H'; ++$hlnkcount;}       # File with multiple hard links.
               elsif ($Lnlink == 1){$type = 'F'; ++$regfcount;}       # File with exactly one hard link.
               elsif ($Lnlink == 0){$type = 'O'; ++$orphcount;}       # File with zero hard links (orphan).
               else                {$type = 'Z'; ++$zombcount;}       # File with  < 0 hard links (zombie).
            }
            else                   {$type = 'U'; ++$unkncount;}    # Object of unknown type.
         }
      } # end else if path DOES exist

      # Get date and time from Lmtime:
      my @LocalTimeFields = localtime($Lmtime);
      my $date = strftime('%F',   @LocalTimeFields);
      my $time = strftime("%T%Z", @LocalTimeFields);

      # Push file info record for this file onto array:
      push @filerecords,
      {
         'Path'   => $path,   # path to file
         'Name'   => $name,   # name of file
         'Type'   => $type,   # type of file
         'Date'   => $date,   # mod-date of file
         'Time'   => $time,   # mod-time of file
         'Dev'    => $Ldev,   # lstat[ 0]
         'Inode'  => $Linode, # lstat[ 1]
         'Mode'   => $Lmode,  # lstat[ 2]
         'Nlink'  => $Lnlink, # lstat[ 3]
         'UID'    => $Luid,   # lstat[ 4]
         'GID'    => $Lgid,   # lstat[ 5]
         'Rdev'   => $Lrdev,  # lstat[ 6]
         'Size'   => $Lsize,  # lstat[ 7]
         'Atime'  => $Latime, # lstat[ 8]
         'Mtime'  => $Lmtime, # lstat[ 9]
         'Ctime'  => $Lctime, # lstat[10]
         'Bsize'  => $Lbsize, # lstat[11]
         'Blocks' => $Lblcks, # lstat[12]
         'Target' => $ltarg,  # link target (or "NO TARGET"        if not link,
                              #              or "UNDEFINED TARGET" if bad link,
                              #              or "NONEXISTENT FILE" if link doesn't exist)
      };
   }; # end foreach (@filepaths)
   return \@filerecords;
} # end sub GetFiles (;$$)

=head2 GetRegularFilesBySize

Given a file-name regular expression to search for, this subroutine returns a reference to a hash of
arrays of same-size file records for all matching regular files in a given directory, with the
outer hash keyed by file size. This sub can take up to three optional arguments: a directory,
a file-selection regexp, and a file-selection predicate:

   GetRegularFilesBySize ($dir = d(getcwd), $regexp = qr(^.+$)o, $predicate = 1)

This sub is especially useful for programs which compare regular files for identicalness, preperatory to
making decisions regarding copying or deleting of files. To make such comparisons FAST, this sub stores
files records in same-file-size arrays and does not collect or return any stats.
=cut
sub GetRegularFilesBySize :prototype(;$$$) ($dir = d(getcwd), $regexp = qr(^.+$)o, $predicate = 1) {
   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "\nDebug msg in GetRegularFilesBySize(), at top:\n"
                ."\$dir       = $dir\n"
                ."\$regexp    = $regexp\n"
                ."\$predicate = $predicate";
   }
   my $files = GetFiles($dir, 'F', $regexp, $predicate);
   my %filerecords;
   foreach my $file (@$files) {push @{$filerecords{$file->{Size}}}, $file}
   return \%filerecords;
} # end sub GetRegularFilesBySize ()

=head2 FilesAreIdentical

FilesAreIdentical($filepath1, $filepath2)

Compares the contents of two files. Returns 1 if files are identical, or 0 if the files are different.
=cut
sub FilesAreIdentical :prototype($$) ($filepath1, $filepath2) {
   # Get path of first file, make sure it exists, get its stats, make sure it's a regular file,
   # and get its size:
   if ( ! -e e $filepath1 ) {
      warn "Error in FilesAreIdentical: \"$filepath1\" does not exist.\n";
      return 0;
   }
   if ( ! -f e $filepath1 ) {
      warn "Error in FilesAreIdentical: \"$filepath1\" is not a regular file.\n";
      return 0;
   }
   my $size1 = -s e $filepath1;

   # Get path of second file, make sure it exists, get its stats, make sure it's a regular file,
   # and get its size:
   if ( ! -e e $filepath2 ) {
      warn "Error in FilesAreIdentical: \"$filepath2\" does not exist.\n";
      return 0;
   }
   if ( ! -f e $filepath2 ) {
      warn "Error in FilesAreIdentical: \"$filepath2\" is not regular file.\n";
      return 0;
   }
   my $size2 = -s e $filepath2;

   # If these files have different sizes, they can't be identical, so return 0:
   if ($size1 != $size2) {return 0;}

   # If both files are emtpy, they are identical, so return 1:
   if (0 == $size1 && 0 == $size2) {return 1 ;}

   # Try to open both files here, shortly before entering buffer loop.
   # They will both be closed immediately after exiting buffer loop.

   open (my $filehandle1, "< :raw", e($filepath1))
   or warn "Error in FilesAreIdentical: Couldn't open \"$filepath1\".\n"
   and return 0;

   open (my $filehandle2, "< :raw", e($filepath2))
   or warn "Error in FilesAreIdentical: Couldn't open \"$filepath2\".\n"
   and return 0;

   # Before entering buffer loop, seek both files to position 0.
   # (This is probably not necessary, but I'm electing to play it safe,
   # because having the two files out of synch would be disastrous and
   # very hard to troubleshoot.)
   seek($filehandle1, 0, 0);
   seek($filehandle2, 0, 0);

   # Create a difference flag and set it to 0:
   my $different = 0;

   # BUFFER LOOP: Read data from first and second files, in buffers of
   # 1 MiB, and compare first buffer to second buffer. If a difference is
   # found, mark files as "different" and exit loop; else continue
   # reading the files until out of data:
   BUFFER: while (1) {
      my $buffer1 = '';
      my $buffer2 = '';
      # Attempt to read 1MiB of data from first file:
      my $read_result1 = read($filehandle1, $buffer1, 1048576);

      # Abort subroutine if we failed to read from first file:
      if (not defined $read_result1) {
         warn "Error in FilesAreIdentical: Can't read first file\n";
         warn "$filepath1\n";
         warn "$!\n";
         return 0;
      }

      # Attempt to read 1MiB of data from second file:
      my $read_result2 = read($filehandle2, $buffer2, 1048576);

      # Abort execution if we failed to read from second file:
      if (not defined $read_result2) {
         warn "Error in FilesAreIdentical: Can't read second file\n";
         warn "$filepath2\n";
         warn "$!\n";
         return 0;
      }

      # If the two read results are defined but not equal, print sync-failure
      # message and abort program execution, because these two files are *supposed* to be
      # of equal size according to the directory, so if they don't reach EOF
      # simultaneously, the directory may be corrupt:
      if ($read_result1 != $read_result2) {
         die
         "Fatal Error in FilesAreIdentical: ".
         "Size difference found between these two files,\n".
         "which are supposedly the same size:\n".
         "$filepath1\n".
         "$filepath2\n".
         "Aborting program execution.\n".
         "Check integrity of directory!\n".
         "$!\n";
      }

      # If either read result is 0, then both are, and we're at EOF for both files,
      # and no difference has been found, so exit buffer loop, leaving $different set at 0:
      last BUFFER if 0 == $read_result1;

      # If buffers contain identical strings, read next buffers:
      next BUFFER if $buffer1 eq $buffer2;

      # Otherwise, set difference flag and exit buffer loop:
      $different = 1;
      last BUFFER;
   } # End BUFFER loop.

   # Close both files:
   close($filehandle1);
   close($filehandle2);

   # If $different is 1, return 0 ("no,  files AREN'T identical").
   # If $different is 0, return 1 ("yes, files  ARE   identical").
   return !$different;
} # end sub FilesAreIdentical

=head2 RecurseDirs

Given a subroutine name as input, THIS subroutine will apply THAT subroutine in every directory in the
directory tree decending from the current working directory:

RecurseDirs {MySubName}

=cut
sub RecurseDirs :prototype(&) ($f) {

   # ------- WHO'S CALLING? ----------------------------------------------------------------------------------

   if ($Debug) {
      my ($pac,$fil,$lin)=caller;
      say STDERR "RecurseDirs called by package \"$pac\", file \"$fil\", line \"$lin\".";
   }

   # ------- RECURSION CHECKS: -------------------------------------------------------------------------------

   # This is a recursive function, being used in a chaotic and unpredictable environment with an unknown file
   # system, so it is VERY possible for runaway recursion to occur. So, to keep track of recursion, we use a
   # recursion counter, "$recursion", which is initialized to zero once only, the first time this function is
   # called during this run of this program. "$recursion" is incremented immediately before recursing and
   # decremented immediately after recursing, and it is checked each time this subroutine is run to make sure
   # it never exceeds 100 levels of recursion:
   state $recursion     = 0;
   state $max_recursion = 0;

   # If RecurseDirs() is called multiple times during a program run (rare!), "$recursion" won't be initialized
   # to 0 on the 2nd and subsequent runs. That's normally fine, because when RecurseDirs() is done recursing a
   # directory tree, "$recursion" will always be 0 immediately before the final return anyway. HOWEVER, if
   # RecurseDirs() exited unexpectedly on a previous recursive run, it may be non-zero on first entry of next
   # recursive run. So to combat that, we COULD reset it to zero if calling package is not "RH:Dir":

   # if ($Debug) {say STDERR "(1) Recursion Level = $recursion";}
   # if ('RH::Dir' ne (caller())[0]) {$recursion = 0;}
   # if ($Debug) {say STDERR "(2) Recursion Level = $recursion";}

   # NOTE RH 2025-03-23_01-06: No, let's not do that. It just wastes time, because a set of recursive calls to
   # this subroutine will either:
   # 1. Unwind, decrementing $recursion back to 0.
   # 2. Crash.
   # In neither case will an outside caller ever find $recursion anything other than 0 on first entry, even if
   # this subroutine is called multiple times in a program run (already exceedingly rare).

   # If we are more than 100 levels deep into recursion, die:
   if ( $recursion > 100 ) {
      die "Fatal error in RecurseDirs: More than 100 levels of recursion!\n$!\n";
   }

   # ------- ARGUMENT CHECK: ---------------------------------------------------------------------------------

   # Die if f is not a ref to some code (block or sub):
   if ('CODE' ne ref $f) {
      die "\nFatal error in RecurseDirs: This subroutine takes 1 argument which must be a\n".
          "{code block} or a reference to a subroutine.\n\n";
   }

   # ------- CREATE VARIABLES TO HOLD CURRENT, ORIGINAL, AND NEW DIRECTORIES: --------------------------------

   my     $curdir   = d(getcwd) ;  # Current directory at beginning of THIS recursive call (may be any level).
   state  $oridir   = $curdir   ;  # Current directory as FIRST entry (level 0 only).
   my     $new_cwd  = undef     ;  # Keep track of ACTUAL current working directory when chdir'ing!

   # ------- ORIGINAL-DIRECTORY CHECKS: ----------------------------------------------------------------------

   # If we're at the 0th recursive level (just entered, first time in):
   if (0 == $recursion) {
      # If "original" directory is something we shouldn't meddle with, then die:
      if
      (
            $oridir eq '/proc'                        # Attempting to navigate from "/proc" can crash system!
         || $oridir =~ m#/\.git$#                     # All OSs: github files
         || $oridir =~ m#/System Volume Information$# # Windows: system volume information
         || $oridir =~ m#/lost+found$#                # Linux:   Lost&Found
         || $oridir =~ m#/\.Recycle/$#i               # Windows: trash
         || $oridir =~ m#/\$Recycle\.Bin$#i           # Windows: trash
         || $oridir =~ m#/Recyler$#i                  # Windows: trash
         || $oridir =~ m#/Trash.*$#i                  # Linux:   trash
         || $oridir =~ m#/\.Trash.*$#i                # Linux:   trash
      )
      {
         die "Fatal Error in RecurseDirs:\n"
             ."Can't recurse from this problematic starting directory:\n"
             ."$oridir\n"
             ."Aborting program to prevent damage to file system.\n";
      } # end if (original directory is problematic)
   } # end if (0th recursive level)

   # ------- CURRENT WORKING DIRECTORY CHECKS: ---------------------------------------------------------------

   # We MUST have a valid "current working directory"!!!
   if ( !defined($curdir) || '/' ne substr($curdir, 0, 1) || ! -e e($curdir) || ! -d e($curdir) ) {
      die "Fatal error in RecurseDirs: unable to determine the current working directory!\n"
         ."Aborting execution to prevent damage to file system!\n"
         ."$!\n";
   }

   # If we don't have permission to read this directory, jump to bottom:
   lstat e($curdir);
   if
   (
         ! -r _ # We can't read     this directory.
      || ! -R _ # We can't read     this directory.
      || ! -x _ # We can't navigate this directory.
      || ! -X _ # We can't navigate this directory.
   )
   {
      warn "Error in RecurseDirs: Can't navigate directory \"$curdir\". Skipping this sub-tree.\n";
      chdir(e($curdir));
      $new_cwd = d(getcwd);
      if ( !defined($new_cwd) || $new_cwd ne $curdir) {
         die "Fatal error in RecurseDirs: Couldn't cd back to curdir \"$curdir\"!\n";
      }
      goto BOTTOM; # This allows directory-tree-walking to continue (or ends program if we're at level 0).
   } # end $curdir is problematic

   # ------- READ CONTENTS OF CURRENT DIRECTORY: -------------------------------------------------------------
   # Try to open current directory; if that fails, print warning and return 1:
   my $dh = undef;
   if ( ! opendir $dh, e $curdir ) {
      warn "Error in RecurseDirs: Couldn't open directory \"$curdir\".\nMoving on to next directory.\n";
      chdir(e($curdir));
      $new_cwd = d(getcwd);
      if ( !defined($new_cwd) || $new_cwd ne $curdir) {
         die "Fatal error in RecurseDirs: Couldn't cd back to curdir \"$curdir\"!\n";
      }
      goto BOTTOM; # This allows directory-tree-walking to continue (or ends program if we're at level 0).
   }

   # Try to read current directory; if that fails, print warning and return 1:
   my @subdirs = sort(d(readdir($dh))); # Subdirs & files. (We'll get rid of the files down below.)
   if ( scalar(@subdirs) < 2 ) {
      warn "Error in RecurseDirs: Couldn't read directory \"$curdir\".\nMoving on to next directory.\n";
      if ( ! closedir $dh ) {
         die "Fatal error in RecurseDirs: Couldn't close directory \"$curdir\".\n$!\n";
      }
      chdir(e($curdir));
      $new_cwd = d(getcwd);
      if ( !defined($new_cwd) || $new_cwd ne $curdir) {
         die "Fatal error in RecurseDirs: Couldn't cd back to curdir \"$curdir\"!\n";
      }
      goto BOTTOM; # This allows directory-tree-walking to continue (or ends program if we're at level 0).
   }

   # Try to close current directory; if that fails, abort program:
   if ( ! closedir $dh ) {
      die "Fatal error in RecurseDirs: Couldn't close directory \"$curdir\".\n$!\n";
   }

   if ($Debug) {
      say STDERR '';
      say STDERR "In RecurseDirs(); list of entries in directory \"$curdir\":";
      say STDERR for @subdirs;
      say STDERR '';
   }

   # ------- NAVIGATE SUBDIRS (IF ANY) OF CURRENT DIRECTORY: -------------------------------------------------
   SUBDIR: foreach my $subdir (@subdirs) {

      # ------- SUBDIR STATS CHECKS: -------------------------------------------------------------------------

      # If "$subdir" doesn't exist, skip it:
      next SUBDIR if ! -e e $subdir;                # Doesn't exist.

      # Store dir stats for $subdir in _ :
      lstat e $subdir;

      # If "$subdir" isn't a directory, skip it:
      next SUBDIR if ! -d _ ;                       # Not a directory.

      # If "$subdir" is a simlinkd, skip it:
      next SUBDIR if   -l _ ;                       # Symbolic link.

      # If "$subdir" is forbidden to us, skip it:
      next SUBDIR if ! -r _ ;                       # We can't read     this subdir!
      next SUBDIR if ! -R _ ;                       # We can't read     this subdir!
      next SUBDIR if ! -x _ ;                       # We can't navigate this subdir!
      next SUBDIR if ! -X _ ;                       # We can't navigate this subdir!

      # ------- SUBDIR NAME CHECKS: --------------------------------------------------------------------------

      # Skip certain poisonous subdirectories order to avoid loops and crashes:
      next SUBDIR if $subdir eq '.';                         # Windows/Linux/Cygwin: Hard link to self.
      next SUBDIR if $subdir eq '..';                        # Windows/Linux/Cygwin: Hard link to parent.
      next SUBDIR if $curdir eq '/' && $subdir eq 'proc';    # Linux: Navigating in here causes crashes.

      # Avoid certain specific problematic directories:
      next SUBDIR if $subdir eq '.git';                      # All OSs: don't mess with git.
      next SUBDIR if $subdir eq 'System Volume Information'; # Windows: SysVolInf is off-limits.
      next SUBDIR if $subdir =~ m/lost+found$/;              # Linux:   Lost&Found is root-only.

      # Avoid rooting in trash bins:
      next SUBDIR if $subdir =~ m/^\.Recycle/i;              # Windows trash bins.
      next SUBDIR if $subdir =~ m/^\$Recycle.Bin/i;          # Windows trash bins.
      next SUBDIR if $subdir =~ m/^Recyler/i;                # Windows trash bins.
      next SUBDIR if $subdir =~ m/^Trash/i;                  # Linux trash bins.
      next SUBDIR if $subdir =~ m/^\.Trash/i;                # Linux trash bins.

      # ------- SUBDIR PATH: ---------------------------------------------------------------------------------

      # Get fully-qualified path for $subdir:
      my $subdir_path = path($curdir, $subdir);

      # Try to chdir to $subdir; if that fails, try to cd back to $curdir (or die if that fails),
      # then move on to next subdirectory:
      chdir(e($subdir_path));
      $new_cwd = d(getcwd);
      if ( !defined($new_cwd) || $new_cwd ne $subdir_path ) {
         say STDERR "Warning from RecurseDirs: return value of getcwd is \"$new_cwd\","
                   ."but that doesn't match our presumed current directory which is \"$subdir_path\".\n"
                   ."Skipping this subdirectory and moving on to next.";
         # Try to cd back to $curdir (and die if that fails):
         chdir(e($curdir));
         $new_cwd = d(getcwd);
         if ( !defined($new_cwd) || $new_cwd ne $curdir) {
            die "Fatal error in RecurseDirs: Couldn't cd back to curdir \"$curdir\"!\n";
         }
         next SUBDIR;
      }

      # Recurse:
      ++$recursion;
      if ( $recursion > $max_recursion ) { $max_recursion = $recursion }
      if ($Debug) {say STDERR "In RecurseDirs, in \"$new_cwd\", about to recurse.";}
      RecurseDirs(\&{$f});
      if ($Debug) {say STDERR "In RecurseDirs, in \"$new_cwd\", just returned from recursion.";}
      --$recursion;

      # Try to cd back to $curdir (and die if that fails):
      chdir(e($curdir));
      $new_cwd = d(getcwd);
      if ( !defined($new_cwd) || $new_cwd ne $curdir) {
         die "Fatal error in RecurseDirs: Couldn't cd back to curdir \"$curdir\"!\n";
      }
   } # end foreach my $subdir (@subdirs)

   # ------- EXECUTE FUNCTION: -------------------------------------------------------------------------------
   # Execute f only at the tail end of SubDirs; that way if f renames immediate subdirectories of the
   # current directory (for example, f is RenameFiles running in directories mode), that's no problem,
   # because all navigation of subdirectories of the current directory is complete before f is executed.
   # In other words, each instance of RecurseDirs is only allowed to fulfill its primary task after its
   # children have all died of old age, having fulfilled their tasks.

   # But first, make sure we're back to our original current working directory!
   chdir(e($curdir));
   $new_cwd = d(getcwd);
   if ( !defined($new_cwd) || $new_cwd ne $curdir ) {
      die "Fatal error at bottom of RecurseDirs: return value of getcwd is \"$new_cwd\",\n"
         ."but that doesn't match our presumed current directory which is \"$curdir\".\n"
         ."Aborting program to avoid damaging file system.";
   }
   if ($Debug) {say STDERR "In RecurseDirs, in \"$new_cwd\", about to execute function.";}
   if ( ! $f->() ) {
      warn "Warning from RecurseDirs: Couldn't apply function in directory $new_cwd!\n";
   }

   # ------- RETURN: -----------------------------------------------------------------------------------------
   # If we get to here, we've succeeded, so return:
   BOTTOM: return $max_recursion;
} # end sub RecurseDirs (&)

# Copy a file from a given path to a given directory.
# Mandatory arguments:
#    path of original file
#    path of destination directory
# Optional arguments:
#    'rename=newname'  =>  Set copied file's name to newname in destination directory.
#    'sha1'            =>  Set copy's name root to SHA1 hash of file.
#    'sl'              =>  Make short display names for Spotlight image processing.
#    'corr'            =>  Set suffix of destination file name to correct suffix for file.
# All other arguments are ignored.
# Note: if contradictory arguments are given (eg, 'sha1', 'rename=Fred'), later arguments override previous.
# Returns 0 for error, 1 for success, 2 for "skipped file because duplicate exists in destination".
sub copy_file :prototype($$;@)
(
   $spath, # Path of source file.
   $ddire, # Destination directory.
   @args   # Additional arguments, if any, go in here.
)
{
   my $dpath    = '';                         # Path of destination file, full  version.
   my $sdire    =  get_dir_from_path($spath); # Directory of   source    file.
   my $sname    = get_name_from_path($spath); #   Name    of   source    file.
   my $spref    = get_prefix($sname);         #  Prefix   of   source    file.
   my $ssuff    = get_suffix($sname);         #  Suffix   of   source    file.
   my $mode     = 'normal';                   # Operating mode: 'normal', 'rename', or 'sha1'.
   my $uname;                                 # User-provided name (for use in 'rename' mode).
   my $corr     = 0;                          # Correct suffix?
   my $sl       = 0;                          # Shorten names for Spotlight image processing?
   my $dpref;                                 # File-name prefix for destination file.
   my $dsuff;                                 # File-name suffix for destination file.
   my $dname;                                 # File-name        for destination file.

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                      ";
      say STDERR "In copy_file, at top. ";
      say STDERR "\$spath = \"$spath\"  ";
      say STDERR "\$ddire = \"$ddire\"  ";
      say STDERR "\@args  = (@args)     ";
      say STDERR "                      ";
   }

   # Bail if $spath is not a path to an existing regular file:
   if ( ! -e e $spath || ! -f e $spath ) {
      warn
         "\n",
         "Error in copy_file: Given path is not a path to an existing regular file:\n",
         "$spath\n",
         "File was not copied.\n",
         "\n";
      return 0;
   }

   # Bail if destination directory doesn't exist or isn't a directory:
   if ( ! -e e $ddire || ! -d e $ddire ) {
      warn
         "\n",
         "Error in copy_file: Given destination directory does not exist:\n",
         "$ddire\n",
         "File was not copied.\n",
         "\n";
      return 0;
   }

   # Process remaining arguments:
   foreach my $arg (@args) {
      switch ($arg) {
         case 'sha1' { # Make a SHA1 file name.
            $mode = 'sha1';
         }
         case m/^rename=(.+)$/ { # Rename file.
            $mode = 'rename';
            $uname = $1;
         }
         case 'corr' { # Correct the file-name suffix.
            $corr = 1;
         }
         case 'sl' { # Generate short display names for Spotlight.
            $sl = 1;
         }
      }
   }

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                                          ";
      say STDERR "In copy_file, after processing arguments. ";
      say STDERR "\$mode  = \"$mode\"                       ";
      say STDERR "\$uname = \"$uname\"                      ";
      say STDERR "\$sl    = \"$sl\"                         ";
      say STDERR "\$corr  = \"$corr\"                       ";
      say STDERR "                                          ";
   }

   # Set destination prefix and suffix depending on mode:
   switch ($mode) {
      case 'rename' {
         $dpref = get_prefix($uname);
         $dsuff = get_suffix($uname);
      }
      case 'sha1' {
         $dpref = hash($spath, 'sha1');
         if ($dpref eq '***ERROR***') {
            $dpref = $spref;
            warn
            "\n",
            "Warning from copy_file(): bad hash.\n",
            "Retaining original file-name prefix.\n",
            "\n";
         }
         $dsuff = get_suffix($sname);
      }
      else { # Otherwise we default to 'normal' mode:
         $dpref = $spref;
         $dsuff = get_suffix($sname);
      }
   }

   # If user requested suffix correction, correct the suffix:
   if ($corr) {$dsuff = get_correct_suffix($spath);}

   # Make $dname (destination name) from $dpref (destination prefix) and $dsuff (destination suffix):
   $dname = $dpref . $dsuff;

   # If $dname already exists in $ddire, try enumerating:
   if ( -e e "$ddire/$dname" ) {
      $dname = find_avail_enum_name($dname,$ddire);
   }

   # If, for whatever reason, $dname is now '***ERROR***', warn user and return "0" to indicate failure:
   if ( $dname eq '***ERROR***' ) {
      warn
         "\n",
         "Error in copy_file: Couldn't find an available name for this name and directory:\n",
         "Original file name:    $sname \n",
         "Destination directory: $ddire \n",
         "File was not copied.          \n",
         "\n";
      return 0;
   }

   # Set $dpath from $ddire and $dname:
   $dpath = path($ddire, $dname);

   # Make "display" versions of directory and file names:
   my $srcdsh = $sdire; #   Source    directory, short version. (Defaults to $sdire.)
   my $srcfsh = $sname; #   Source      file,    short version. (Defaults to $sname.)
   my $dstdsh = $ddire; # Destination directory, short version. (Defaults to $ddire.)
   my $dstfsh = $dname; # Destination   file,    short version. (Defaults to $dname.)

   # If user specified 'sl', shorten directory and file names for Spotlight use:
   if ($sl) {
      ($srcdsh, $srcfsh, $dstdsh, $dstfsh) = shorten_sl_names($srcdsh, $srcfsh, $dstdsh, $dstfsh);
   }

   # Make "display" versions of the file paths:
   my $srcpsh = path($srcdsh, $srcfsh); #   Source    path (short version)
   my $dstpsh = path($dstdsh, $dstfsh); # Destination path (short version)

   # Attempt to copy the file:
   my $success  = ! system(e "cp --preserve=timestamps '$spath' '$dpath'");
   if ($success) {
      print "Copied \"$srcpsh\" to \"$dstpsh\"\n";
      return 1;
   }
   else {
      warn
         "\n",
         "Error in copy_file: couldn't copy this file:\n",
         "Src: \"$srcpsh\"  \n",
         "Dst: \"$dstpsh\"  \n",
         "$!\n",
         "\n";
      return 0;
   }
} # end sub copy_file

# Move a file from a given path to a given directory.
# Mandatory arguments: path of original file, followed by path of destination directory.
# Optional arguments:
#    'rename=newname'  =>  Set file's name to newname in destination directory.
#    'sha1'            =>  Set file's name root to SHA1 hash of file. (Doesn't change file name extension.)
#    'sl'              =>  Shorten names for Spotlight image processing.
# All other arguments are ignored.
# Note: if contradictory arguments are given (eg, 'sha1', 'rename=Fred'), later arguments override previous.
# Returns 0 for error, 1 for success, 2 for "skipped file because duplicate exists in destination".
sub move_file :prototype($$;@)
(
   $spath, # Path of source file.
   $dst,   # Destination directory.
   @args   # Additional arguments, if any, go in here.
)
{
   my $dpath    = '';                         # Path of destination file, full  version.
   my $src      = get_dir_from_path ($spath); # Directory of   source    file.
   my $sname    = get_name_from_path($spath); #   Name    of   source    file.
   my $dname    = '';                         #   Name    of destination file. (Defaults to $sname.)
   my $mode     = 'reg';                      # Naming Mode: nrm = normal, sha = sha1, ren = rename.
   my $sl       = 0;                          # Shorten names for Spotlight image processing?

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                      ";
      say STDERR "In move_file, at top. ";
      say STDERR "\$spath = \"$spath\"  ";
      say STDERR "\$dst   = \"$dst\"    ";
      say STDERR "\@args  = (@args)     ";
      say STDERR "                      ";
   }

   # Bail if $spath is not a path to an existing regular file:
   if ( ! -e e $spath || ! -f e $spath ) {
      warn
         "\n",
         "Error in move_file: Given path is not a path to an existing regular file:\n",
         "$spath\n",
         "File was not moved.\n",
         "\n";
      return 0;
   }

   # Bail if destination directory doesn't exist or isn't a directory:
   if ( ! -e e $dst || ! -d e $dst ) {
      warn
         "\n",
         "Error in move_file: Given destination directory does not exist:\n",
         "$dst\n",
         "File was not moved.\n",
         "\n";
      return 0;
   }

   # Process remaining arguments:
   foreach (@args) {
      if ( $_ eq 'sha1' ) {        # if SHA1-ing file
         $mode = 'sha';            # set $mode to 'sha' (SHA-1 Mode)
      }
      elsif ( m/^rename=(.+)$/ ) { # elsif renaming file,
         $mode = 'ren';            # set $mode to 'ren' (Rename Mode)
      }
      elsif ( $_ eq 'sl' ) {       # elsif Spotlight,
         $sl   =  1;               # set $sl     to 1
      }
   }

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                                          ";
      say STDERR "In move_file, after processing arguments. ";
      say STDERR "\$mode = \"$mode\"                        ";
      say STDERR "\$sl   = \"$sl\"                          ";
      say STDERR "                                          ";
   }

   # Take different actions depending on naming mode:
   for ($mode) {
      # Rename Naming Mode:
      if ( /^ren$/ ) {
         # Set destination name to name user provided:
         $dname = $1;
      }

      # SHA-1 Naming Mode:
      elsif ( /^sha$/ ) {
         # Set $dname to SHA1-hash-based file name:
         $dname = hash($spath, 'sha1', 'name');

         # If $dname is now '***ERROR***', set $dname to $sname and warn user:
         if ($dname eq '***ERROR***') {
            $dname = $sname;
            warn
            (
               "\n",
               "Warning from move_file: bad hash for this file:\n",
               "$sname\n",
               "Retaining original file name.\n",
               "\n"
            );
         }
      }

      # Normal Naming Mode:
      else {
         # Set destination name equal to source name:
         $dname = $sname;
      }
   } # end for ($mode)

   # Print diagnostics if debugging:
   say STDERR "\nIn move_file, after for(\$mode).\n\$dname = \"$dname\".\n" if $Debug;

   # Regardless of what Naming Mode we just used, if $dname already exists in $dst,
   # we'll have to come up with a new name! Let's try enumerating:
   if ( -e e "$dst/$dname" ) {
      $dname = find_avail_enum_name($dname,$dst);
   }

   # If, for whateve reason, $dname is now '***ERROR***', warn user and return "0" to indicate failure:
   if ( $dname eq '***ERROR***' ) {
      warn
         "\n",
         "Error in move_file: Couldn't find available name for this name and directory:\n",
         "Name:      $dname    \n",
         "Directory: $dst      \n",
         "File was not moved.  \n",
         "\n";
      return 0;
   }

   # Otherwise, set $dpath from $dst and $dname:
   else {
      $dpath = path($dst, $dname);
   }

   # Make "display" versions of directory and file names:
   my $srcdsh = $src;   #   Source    directory, short version. (Defaults to $src.)
   my $srcfsh = $sname; #   Source      file,    short version. (Defaults to $sname.)
   my $dstdsh = $dst;   # Destination directory, short version. (Defaults to $dst.)
   my $dstfsh = $dname; # Destination   file,    short version. (Defaults to $dname.)

   # If user specified 'sl', shorten directory and file names for Spotlight use:
   if ($sl) {
      ($srcdsh, $srcfsh, $dstdsh, $dstfsh) = shorten_sl_names($srcdsh, $srcfsh, $dstdsh, $dstfsh);
   }

   # Make "display" versions of the file paths:
   my $srcpsh = path($srcdsh, $srcfsh); #   Source    path (short version)
   my $dstpsh = path($dstdsh, $dstfsh); # Destination path (short version)

   # Attempt to move the file:
   if ( ! system(e("mv -n '$spath' '$dpath'")) ) {
      say "Moved \"$srcpsh\" to \"$dstpsh\"";
      return 1;
   }
   else {
      warn
         "\n",
         "Error in move_file: Couldn't perform this file move:\n",
         "Src: \"$srcpsh\"  \n",
         "Dst: \"$dstpsh\"  \n",
         "\n";
      return 0;
   }
} # end sub move_file

# Copy files from one directory to another.
# Mandatory arguments:
#    Source            (Directory to copy files from.)
#    Destination       (Directory to copy files to.)
# Optional arguments:
#    sl                (Shorten names for when processing Windows Spotlight images.)
#    unique            (Don't copy files for which duplicates exist in destition.)
#    large             (Copy only image files which are at least 1200px wide and 600px tall.)
#    sha1              (Use the SHA-1 hash of each source file as its destination name root.)
# All arguments will also be passed-on to copy_file(), which may take further actions based on them.
sub copy_files :prototype($$;@)
(
   $src, # Source directory.
   $dst, # Destination directory.
   @args # Additional arguments, if any, go in here.
)
{
   # Settings:
   my $target   = 'F'                   ; # $target   = target (always "regular Files only")
   my $regexp   = '^.+$'                ; # $regexp   = regular expression
   my $sl       = 0                     ; # $sl       = Shorten names for Spotlight?
   my $unique   = 0                     ; # $unique   = Are we being unique?
   my $large    = 0                     ; # $large    = Are we copying only large images (W=1200+, H=600+)?
   my $both     = 0                     ; # $both     = Do files of a given size exist in both directories?

   # Arrays:
   my @sfiles   = ()                    ; # @sfiles   = Array of same-size files in   source    directory.
   my @dfiles   = ()                    ; # @dfiles   = Array of same-size files in destination directory.

   # Counters:
   my $err_cnt  = 0                     ; # $err_cnt  = count of errors
   my $cpy_cnt  = 0                     ; # $cpy_cnt  = count of files copied to $dst
   my $skp_cnt  = 0                     ; # $skp_cnt  = count of files skipped because not large images
   my $byp_cnt  = 0                     ; # $byp_cnt  = count of files bypassed because of dup in dest

   # If debugging, print diagnostics:
   if ($Debug) {
      warn "\nJust entered sub \"copy_files\".\n",
           "Src dir = \"$src\".   \n",
           "Dst dir = \"$dst\".   \n",
           "Target  = \"$target\".\n",
           "Args    =             \n",
           join "\n", @args          ,
           "\n";
   }

   # Process only those arguments we need (some will be simply passed-on to copy_file):
   foreach (@args) {
         if (/^regexp=(.+)$/) {$regexp = $1 ;} # Copy only files matching regexp.
      elsif (/^sl$/         ) {$sl     = 1  ;} # Shorten names for Spotlight.
      elsif (/^unique$/     ) {$unique = 1  ;} # Copy only files for which duplicates don't exist in dest.
      elsif (/^large$/      ) {$large  = 1  ;} # Copy only large image files (W=1200+, H=600+).
   }

   # If debugging, print diagnostics:
   if ($Debug) {
      warn "\nIn middle of sub \"copy_files\".\n",
           "RegExp  = \"$regexp\".\n",
           "SL      = \"$sl\".    \n",
           "Unique  = \"$unique\".\n",
           "Large   = \"$large\". \n";
   }

   # Create variables for the "display" versions of the directories:
   my $srcdsh = $src;   #   Source    directory, short version. (Defaults to $src.)
   my $dstdsh = $dst;   # Destination directory, short version. (Defaults to $dst.)

   # If user specified 'sl', shorten directory and file names for Spotlight use:
   if ($sl) {
      my $s1 = '/cygdrive/c/Users';
      my $s2 = '/AppData/Local/Packages';
      my $s3 = '/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy';
      my $s4 = '/LocalState/Assets';
      my $s5 = '/cygdrive/sl';
      my $u1 = '/Aragorn';
      my $u2 = '/Urgabor';
      my $u3 = '/Zebulon';
      my $u4 = '/Administrator';
      $srcdsh =~ s%$s1$u1$s2$s3$s4%/usl1%;
      $srcdsh =~ s%$s1$u2$s2$s3$s4%/usl2%;
      $srcdsh =~ s%$s1$u3$s2$s3$s4%/usl3%;
      $srcdsh =~ s%$s1$u4$s2$s3$s4%/usl4%;
      $dstdsh =~ s%$s5%/sl%;
   }

   # If being unique, don't copy files from source which have duplicates in destination:
   if ($unique) {
      say "\nJust entered \"if (\$unique)\"; about to get src & dst file hashes." if $Debug;

      # Note starting directory:
      my $startdir = d(getcwd);

      # cd to source directory and get hash-by-size of files there:
      chdir(e($src)) or die "Couldn't cd to \"$src\".\n";
      $src = d(getcwd);
      my $ssizes = GetRegularFilesBySize($src, $regexp);

      # cd back to starting directory:
      chdir(e($startdir)) or die "Couldn't cd to \"$startdir\".\n";

      # cd to destination directory and get hash-by-size of files there:
      chdir(e($dst)) or die "Couldn't cd to \"$dst\".\n";
      $dst = d(getcwd);
      my $dsizes = GetRegularFilesBySize($dst, $regexp);

      # cd back to starting directory:
      chdir(e($startdir)) or die "Couldn't cd to \"$startdir\".\n";

      # For each size of source file, copy each file of that size to destination if-and-only-if no identical
      # file exists in destination:
      SIZE: foreach my $ssize (keys %{$ssizes}) {
         say "\nProcessing size group \"$ssize\"." if $Debug;

         # Get array of file records for this size:
         @sfiles = @{$ssizes->{$ssize}};

         # Do any files of this size exist in the destination directory?
         if (exists $dsizes->{$ssize}) {
            @dfiles = @{$dsizes->{$ssize}};
            #  Set  the "files of this size exist in both directories" flag:
            $both = 1;
         }
         else {
            # Reset the "files of this size exist in both directories" flag:
            $both = 0;
         }

         # Iterate through the source file records for this size:
         SFILE: foreach my $sfile (@sfiles) {
            say "\nProcessing src file \"$sfile->{Name}\"." if $Debug;

            # If in "large" mode, skip this file if it's not a large image:
            if ( $large && ! is_large_image($sfile->{Path}) ) {
               say "\nSkipping \"$sfile->{Name}\" because it's not a large image." if $Debug;
               ++$skp_cnt;
               next SFILE;
            }

            # Bypass this file if it has a duplicate in destination:
            if ($both) { # Do files of this size exist in both directories?
               DFILE: foreach my $dfile (@dfiles) {
                  if (FilesAreIdentical($sfile->{Path}, $dfile->{Path})) {
                     say "\nBypassing \"$sfile->{Name}\" because it has a dup in dst." if $Debug;
                     ++$byp_cnt;
                     next SFILE;
                  }
               }
            }

            # Attempt to copy this file from $src to $dst:
            my $result = copy_file($sfile->{Path}, $dst, @args);
            if (0 == $result) {++$err_cnt;}
            if (1 == $result) {++$cpy_cnt;}
         } # end foreach file in current size group
      } # end foreach $size
   } # end if ($unique)

   else { # if NOT ($unique)
      # Get list of paths of existing regular files in source folder:
      my @spaths = glob_regexp_utf8($src, $target, $regexp);
      SOURCE: foreach my $spath (@spaths) {
         my $sname = get_name_from_path($spath) if $Debug;
         say "\nProcessing src file \"$sname\"." if $Debug;

         # If in "large" mode, skip this file if it's not a large image:
         if ( $large && ! is_large_image($spath) ) {
            say "\nSkipping \"$sname\" because it's not a large image." if $Debug;
            ++$skp_cnt;
            next SOURCE;
         }

         # Attempt to copy this file from $src to $dst:
         copy_file($spath, $dst, @args) and ++$cpy_cnt or  ++$err_cnt;
      } # end for each path in source directory
   } # end else if (!$unique)
   say "Copied $cpy_cnt files from \"$srcdsh\" to \"$dstdsh\".";
   if ($large) {say "Skipped $skp_cnt files because they weren't large images.";}
   if ($unique) {say "Bypassed $byp_cnt files because of identical files in destination.";}
   say "Suffered $err_cnt errors.";
   return 1;
} # end sub copy_files

# Move files from one directory to another.
# Mandatory arguments:
#    Source            (Directory to move files from.)
#    Destination       (Directory to move files to.)
# Optional arguments:
#    sl                (Shorten names for when processing Windows Spotlight images.)
#    unique            (Don't move files for which duplicates exist in destition.)
#    large             (Move only image files which are at least 1200px wide and 600px tall.)
#    sha1              (Use the SHA-1 hash of each source file as its destination name root.)
# All arguments will also be passed-on to move_file(), which may take further actions based on them.
sub move_files :prototype($$;@)
(
   $src, # Source directory.
   $dst, # Destination directory.
   @args # Additional arguments, if any, go in here.
)
{
   # Settings:
   my $target   = 'F'                   ; # $target   = target (always "regular Files only")
   my $regexp   = '^.+$'                ; # $regexp   = regular expression
   my $sl       = 0                     ; # $sl       = shorten names for Spotlight?
   my $unique   = 0                     ; # $unique   = are we being unique?
   my $large    = 0                     ; # $large    = Are we moving only large images?
   my $both     = 0                     ; # $both     = Do files of a given size exist in both directories?

   # Arrays:
   my @sfiles   = ()                    ; # @sfiles   = Array of same-size files in   source    directory.
   my @dfiles   = ()                    ; # @dfiles   = Array of same-size files in destination directory.

   # Counters:
   my $err_cnt  = 0                     ; # $err_cnt  = count of errors
   my $mov_cnt  = 0                     ; # $mov_cnt  = count of files moved to $dst
   my $skp_cnt  = 0                     ; # $skp_cnt  = count of files skipped because not large images
   my $byp_cnt  = 0                     ; # $byp_cnt  = count of files bypassed because of dup in dest

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                                 ";
      say STDERR "Just entered sub \"move_files\". ";
      say STDERR "Src dir = \"$src\".              ";
      say STDERR "Dst dir = \"$dst\".              ";
      say STDERR "Target  = \"$target\".           ";
      say STDERR "Args    = (@args)                ";
      say STDERR "                                 ";
   }

   # Process only those arguments we need (most will be simply passed-on to move_file):
   foreach (@args) {
         if (/^regexp=(.+)$/) {$regexp = $1 ;} # Move only files matching regexp.
      elsif (/^sl$/         ) {$sl     = 1  ;} # Shorten names for Spotlight.
      elsif (/^unique$/     ) {$unique = 1  ;} # Move only files for which duplicates don't exist in dest.
      elsif (/^large$/      ) {$large  = 1  ;} # Move only large image files (W=1200+, H=600+).
   }

   # If debugging, print diagnostics:
   if ($Debug) {
      say STDERR "                                 ";
      say STDERR "In middle of sub \"move_files\". ";
      say STDERR "RegExp  = \"$regexp\".           ";
      say STDERR "SL      = \"$sl\".               ";
      say STDERR "Unique  = \"$unique\".           ";
      say STDERR "Large   = \"$large\".            ";
      say STDERR "                                 ";
   }

   # Create variables for the "display" versions of the directories:
   my $srcdsh = $src;   #   Source    directory, short version. (Defaults to $src.)
   my $dstdsh = $dst;   # Destination directory, short version. (Defaults to $dst.)

   # If user specified 'sl', shorten directory and file names for Spotlight use:
   if ($sl) {
      my $s1 = '/cygdrive/c/Users';
      my $s2 = '/AppData/Local/Packages';
      my $s3 = '/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy';
      my $s4 = '/LocalState/Assets';
      my $s5 = '/cygdrive/sl';
      my $u1 = '/Aragorn';
      my $u2 = '/Urgabor';
      my $u3 = '/Zebulon';
      my $u4 = '/Administrator';
      $srcdsh =~ s%$s1$u1$s2$s3$s4%/usl1%;
      $srcdsh =~ s%$s1$u2$s2$s3$s4%/usl2%;
      $srcdsh =~ s%$s1$u3$s2$s3$s4%/usl3%;
      $srcdsh =~ s%$s1$u4$s2$s3$s4%/usl4%;
      $dstdsh =~ s%$s5%/sl%;
   }

   # If being unique, don't move files from source which have duplicates in destination:
   if ($unique) {
      say "\nJust entered \"if (\$unique)\"; about to get src & dst file hashes." if $Debug;

      # Note starting directory:
      my $startdir = d(getcwd);

      # cd to source directory and get hash-by-size of files there:
      chdir(e($src)) or die "Couldn't cd to \"$src\".\n";
      $src = d(getcwd);
      my $ssizes = GetRegularFilesBySize($src, $regexp);

      # cd back to starting directory:
      chdir(e($startdir)) or die "Couldn't cd to \"$startdir\".\n";

      # cd to destination directory and get hash-by-size of files there:
      chdir(e($dst)) or die "Couldn't cd to \"$dst\".\n";
      $dst = d(getcwd);
      my $dsizes = GetRegularFilesBySize($dst, $regexp);

      # cd back to starting directory:
      chdir(e($startdir)) or die "Couldn't cd to \"$startdir\".\n";

      # For each size of source file, copy each file of that size to destination if-and-only-if no identical
      # file exists in destination:
      SIZE: foreach my $ssize (keys %{$ssizes}) {
         say "\nProcessing size group \"$ssize\"." if $Debug;

         # Get array of file records for this size:
         @sfiles = @{$ssizes->{$ssize}};

         # Do any files of this size exist in the destination directory?
         if (exists $dsizes->{$ssize}) {
            @dfiles = @{$dsizes->{$ssize}};
            #  Set  the "files of this size exist in both directories" flag:
            $both = 1;
         }
         else {
            # Reset the "files of this size exist in both directories" flag:
            $both = 0;
         }

         # Iterate through the source file records for this size:
         SFILE: foreach my $sfile (@sfiles) {
            say "\nProcessing src file \"$sfile->{Name}\"." if $Debug;

            # If in "large" mode, skip this file if it's not a large image:
            if ( $large && ! is_large_image($sfile->{Path}) ) {
               say "\nSkipping \"$sfile->{Name}\" because it's not a large image." if $Debug;
               ++$skp_cnt;
               next SFILE;
            }

            # Bypass this file if it has a duplicate in destination:
            if ($both) { # Do files of this size exist in both directories?
               DFILE: foreach my $dfile (@dfiles) {
                  if (FilesAreIdentical($sfile->{Path}, $dfile->{Path})) {
                     say "\nBypassing \"$sfile->{Name}\" because it has a dup in dst." if $Debug;
                     ++$byp_cnt;
                     next SFILE;
                  }
               }
            }
            # Attempt to move this file from $src to $dst:
            my $result = move_file($sfile->{Path}, $dst, @args);
            if (0 == $result) {++$err_cnt;}
            if (1 == $result) {++$mov_cnt;}
         } # end foreach file in current size group
      } # end foreach $size
   } # end if ($unique)

   else { # if NOT ($unique)
      # Get list of paths of existing regular files in source folder:
      my @spaths = glob_regexp_utf8($src, $target, $regexp);
      SOURCE: foreach my $spath (@spaths) {
         my $sname = get_name_from_path($spath) if $Debug;
         say "\nProcessing src file \"$sname\"." if $Debug;

         # If in "large" mode, skip this file if it's not a large image:
         if ( $large && ! is_large_image($spath) ) {
            say "\nSkipping \"$sname\" because it's not a large image." if $Debug;
            ++$skp_cnt;
            next SOURCE;
         }

         # Attempt to move this file from $src to $dst:
         my $result = move_file($spath, $dst, @args);
         if (0 == $result) {++$err_cnt;}
         if (1 == $result) {++$mov_cnt;}
      } # end for each path in source directory
   } # end else if (!$unique)
   say "Moved    $mov_cnt files from \"$srcdsh\" to \"$dstdsh\".";
   if ($large)  {say "Skipped  $skp_cnt files because they weren't large images.";}
   if ($unique) {say "Bypassed $byp_cnt files because of identical files in destination.";}
   say "Suffered $err_cnt errors.";
   return 1;
} # end sub move_files

# ======= SECTION 4, MINOR SUBROUTINES: ======================================================================

# Turn on debugging in this module
# (not exported by default, but OK to export):
sub debug :prototype(;$) ($status = 'on') {
   switch ($status) {
      case qr/(?i:0|off|no)/ {$Debug = 0}
      case qr/(?i:1|on|yes)/ {$Debug = 1}
   }
}

# Print messages only if debugging:
sub BLAT :prototype($) ($string) {if ($Debug) {say STDERR $string}}

# Rename a file, with more error-checking than unwrapped rename() :
sub rename_file :prototype($$) ($OldPath, $NewPath) {
   my $OldName = get_name_from_path($OldPath);
   my $NewName = get_name_from_path($NewPath);
   my $OldDir  = get_dir_from_path($OldPath);
   my $NewDir  = get_dir_from_path($NewPath);

   # Make sure old path exists:
   if ( ! -e e($OldPath) ) {
      warn
      (
         "Error in rename_file: file \"$OldPath\" does not exist.\n"
      );
      return 0;
   }

   # Disallow renaming to exact same path:
   if ($NewPath eq $OldPath) {
      warn
      (
         "Error in rename_file: new file path is same as old:\n".
         "old path: $OldPath\n".
         "new path: $NewPath\n"
      );
      return 0;
   }

   # I want to disallow renaming a file to a name that already "exists" (according to -e), but I also want to
   # allow case changes. This is tricky, because file names in various file systems can be:
   # 1. case-nonpreserving (everything is stored as upper-case, as in FAT16)
   # 2. case-preserving and case-sensitive (file names are stored as-is; eg, Ext4)
   # 3. case-preserving and case-insensitive (file names must differ in more than case; eg, FAT32, NTFS)
   # And to make matters more confusing, NTFS file systems intended primarily for use with Microsoft Windows
   # can also be accessed from Linux by network share, so $PLATFORM does not give any clue to as file system.
   # So I'll allow a rename to an existing path only if the old and new names are different but their
   # casefolds are the same. But even then, in NTFS, Perl's "rename()" doesn't correctly perform case changes,
   # so I'll have to take a more-imaginative approach.
   if ( -e e($NewPath) ) {
      if
      (
               $OldDir   eq    $NewDir
         &&    $OldName  ne    $NewName
         && fc($OldName) eq fc($NewName)
      )
      {
         my $Intermediate = path($NewDir, 'aъ玔ò山ë懳z');
        !system(e("ln '$OldPath' '$Intermediate'"))      or return 0;
        !system(e("unlink '$OldPath'"))                  or return 0;
        !system(e("unlink '$NewPath'"))                  or return 0;
        !system(e("ln '$Intermediate' '$NewPath'"))      or return 0;
        !system(e("unlink '$Intermediate'"))             or return 0;
         return(1);
      }
      else {
         say STDERR "Error in \"rename_file\" in \"RH::Dir.pm\":";
         say STDERR "file at path \"$NewPath\" already exists.";
         return(0);
      }
   }

   # Else if the new path does NOT exist, attempt to rename the file, and return the result code, which will
   # be 1 for success, 0 for failure. Note that if $OldPath or $NewPath are relative, rather than absolute,
   # paths, then they will be construed relative to the "current directory" of the environment of the calling
   # program, NOT relative to the directory of $OldPath. So, something like "rename('asdf/qwer', 'yuio')",
   # executed from current directory "/hjkl", will rename file "/hjkl/asdf/qwer" to "/hjkl/yuio", NOT to
   # "/hhjkl/asdf/yuio".
   else {
      return(rename(e($OldPath), e($NewPath)));
   }
} # end sub rename_file

sub time_from_mtime :prototype($) ($mtime) {
   my $TimeDate = scalar localtime $mtime;
   my $Time = substr ($TimeDate, 11, 8);
   return $Time;
} # end sub time_from_mtime

sub date_from_mtime :prototype($) ($mtime) {
   my $TimeDate = scalar localtime $mtime;
   my $Date = substr ($TimeDate, 0, 10) . ', ' . substr ($TimeDate, 20, 4);
   return $Date;
} # end sub date_from_mtime

# Given any string, return all characters before last dot:
sub get_prefix :prototype($) ($string) {
   my $dotindex = rindex($string, '.');
   return $string if -1 == $dotindex;
   return ''      if  0 == $dotindex;
   return substr($string, 0, $dotindex);
} # end sub get_prefix

# Given any string, return last dot and following characters:
sub get_suffix :prototype($) ($string) {
   my $dotindex = rindex($string, '.');
   return ''      if -1 == $dotindex;
   return $string if  0 == $dotindex;
   return substr($string, $dotindex);
} # end sub get_suffix

# Return the directory part of a file path:
sub get_dir_from_path :prototype($) ($path) {
   # If $path contains no "/", we have no idea of what directory we're in, so return an empty string:
   if (-1 == rindex($path,'/')) {
      return '';
   }

   # Else if right-most "/" in $path is at index 0, assume $path is the path of a file in the root directory,
   # so return '/':
   elsif (0 == rindex($path,'/')) {
      return '/';
   }

   # Otherwise return the part of $path to the left of the right-most "/", whether it starts with '/' or not:
   else {
      return substr($path, 0, rindex($path,'/'));
   }
} # end sub get_dir_from_path

# Return the name of the immediate parent directory of the file at a given path:
sub get_dirname_from_path :prototype($) ($path) {
   # If $path contains no "/", we have no idea of what directory we're in, so return "ERROR":
   if (-1 == rindex($path,'/')) {
      return 'ERROR';
   }

   # Else if right-most "/" in $path is at index 0, assume $path is the path of a file in the root directory,
   # so return 'fsroot' (file system root):
   elsif (0 == rindex($path,'/')) {
      return 'fsroot';
   }

   # Otherwise return the immediate parent directory of the file at $path:
   else {
      # Put a copy of $path in $dirname:
      my $dirname = $path;
      # Get rid of the file part of the path:
      $dirname =~ s/\/[^\/]+$//;
      # Get rid of any ancestors of the immediate parent directory:
      while ($dirname =~ m/\//) {
         $dirname =~ s/^[^\/]*\///;
      }
      # Return immediate parent directory name:
      return $dirname;
   }
} # end sub get_dir_from_path

# Return the name part of a file path:
sub get_name_from_path :prototype($) ($path) {
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
} # end sub get_name_from_path

# Paste-together dir & name to get path, while watching out for root and current:
sub path :prototype($$) ($dir, $nam) {
   my $path;

   # If $dir is '', assume that '' means "current working directory", so set $path to $nam:
   if ( '' eq $dir ) {
      $path = $nam;
   }

   # Else if $dir ends with "/" (eg: "/", or "/absolute/dir/", or "relative/dir/"), set $path to $dir.$nam:
   elsif ( '/' eq substr $dir, -1 ) {
      $path = $dir.$nam;
   }

   # Else if $dir DOESN'T end with "/" (eg: "/absolute/dir", or "relative/dir"), set path to $dir.'/'.$nam:
   else {
      $path = $dir.'/'.$nam;
   }

   # Return $path:
   return $path;
}

sub denumerate_file_name :prototype($) ($name) {
   my $prefix = get_prefix($name);
   my $suffix = get_suffix($name);
   $prefix =~ s/-\(\d\d\d\d\)//g;
   return $prefix . $suffix;
} # end sub denumerate_file_name

sub enumerate_file_name :prototype($) ($name) {
   my $prefix = get_prefix($name);
   my $suffix = get_suffix($name);
   $prefix =~ s/-\(\d\d\d\d\)$//g;
   my $numerator = sprintf("-(%04d)", rand_int(0,9999));
   $prefix = $prefix . $numerator;
   return $prefix . $suffix;
} # end sub enumerate_file_name

# Annotate a file's name with a note:
sub annotate_file_name :prototype($$) ($oldname, $note) {
   # $oldname  =  Original file name.
   # $note     =  Note to append.
   my $oldpref = get_prefix($oldname);
   my $oldsuff = get_suffix($oldname);
   return $oldpref . '_' . $note . $oldsuff;
} # end sub annotate_file_name

# Find an enumerated version of a file name which is NOT the name of any file in a given directory:
sub find_avail_enum_name :prototype($;$) ($name, $dir = d(getcwd)) {
   # $name  =  A valid file name.
   # $dir   =  An existing directory, defaulting to current working directory.
   my $prefix    =  get_prefix($name)  ; # Prefix of name.
      $prefix    =~ s/-\(\d\d\d\d\)//g ; # Denumerate prefix in-situ.
   my $suffix    =  get_suffix($name)  ; # Suffix of name.
   my $numerator =  ''                 ; # 4-digit numerator.
   my $tryname   =  ''                 ; # Trial file name.

   # Make sure the given directory actually does exist, and actually is a directory:
   if ( ! -e e $dir || ! -d e $dir ) {
      warn "\nError in find_avail_enum_name:\n",
           "No such directory as \"$dir\".\n",
           "$!\n";
      return '***ERROR***';
   }

   # If an un-enumerated version doesn't exist, then just use that:
   if ( ! -e e(path($dir, $name)) ) {
      return $name;
   }

   # Next, try up to 20 different random numerators:
   RAN: for ( 1 .. 20 ) {
      $numerator = sprintf("-(%04d)", rand_int(0,9999));
      $tryname   = $prefix . $numerator . $suffix;
      if ( ! -e e path($dir, $tryname) ) {
         if ($Debug) {say "Random enumeration succeeded on attempt # $_.";}
         return $tryname;
      }
   } # Stop trying random numerators.

   # If we get to here, random enumeration failed all 20 times,
   # so try sequential enumeration instead:
   SEQ: for ( 0 .. 9999 ) {
      $numerator = sprintf("-(%04d)", $_);
      $tryname = $prefix . $numerator . $suffix;
      if ( ! -e e path($dir, $tryname) ) {
         if ($Debug) {say "Sequential enumeration succeeded on attempt # $_.";}
         return $tryname;
      }
   } # Stop trying sequential numeration.

   # If we get to here, NOTHING worked, so return error code:
   return '***ERROR***';
} # end sub find_avail_enum_name

# Make up to 100 attempts to find an available random name in given directory with given prefix and suffix:
sub find_avail_rand_name :prototype($$$) ($dir, $prefix, $suffix) {
   my $random        = '';
   my $new_name      = '';
   my $attempts      = 0;
   my $name_success  = 0;

   # Make up to 100 attempts to find a random file name with given prefix
   # and suffix that doesn't already exist in given directory:
   for ( $attempts = 0, $name_success = 0 ; $attempts < 100 ; ++$attempts ) {
      $random = eight_rand_lc_letters;
      $new_name   = $prefix . $random . $suffix;
      if ( ! -e e path($dir, $new_name) ) {
         $name_success = 1;
         last;
      }
   }
   if ($name_success) {
      return $new_name;
   }
   else {
      return '***ERROR***';
   }
} # sub find_avail_rand_name ($$$)

# Is a given path a path to a file containing a large image?
sub is_large_image :prototype($) ($path) {
   # File-typing variables:
   my $FileTyper = File::Type->new(); # File-typing functor.
   my $FileType  = '';                # File type.

   # Return 0 if no object exists at path $path:
   if ( ! -e e $path ) {return 0 ;}

   # Return 0 if object at path $path is not a regular file:
   if ( ! -f e $path ) {return 0 ;}

   my $suffix = get_suffix($path);

   # Return 0 if this file is not an image file:
   $FileType = $FileTyper->checktype_filename($path);
   if ($Debug) {warn "In is_large_image. File type = \"$FileType\".\n";}
   return 0 if $FileType ne 'image/bmp'
            && $FileType ne 'image/gif'
            && $FileType ne 'image/jpeg'
            && $FileType ne 'image/png'
            && $FileType ne 'image/tiff'
           #&& $FileType ne 'image/webp' # Nope, this type returns "Application/Octet-Stream".
            && $suffix   ne '.webp';

   # Return 0 if this file doesn't contain an image which is at least 1200px wide and 600px tall:
   my ($x, $y) = imgsize($path);
   return 0 if $x < 1200 || $y < 600;

   # If we get to here, this file contains a large image, so return 1:
   return 1;
} # end sub is_large_image

# Get the correct suffix for the name of a file at a given path, ignoring the existing suffix (if any) and
# basing our type determination on the "checktype_filename" method of modules "File::Type" and/or on direct
# examination of the contents of the file. If we are unable to determine the correct suffix through these
# methods, then return the existing suffix (if any) with "_assumed" appended, or return '.unk' if there is no
# existing suffix, or return '***ERROR***' if an error occurs (file doesn't exist, file isn't a data file,
# file can't be opened/read/closed, permissions error, etc).
sub get_correct_suffix :prototype($) ($path) {
   my $name  = get_name_from_path($path);
   my $suff  = get_suffix($name);
   if ($Debug) {
      say STDERR '';
      say STDERR "In get_correct_suffix(), near top.";
      say STDERR "\$path = $path";
      say STDERR "\$name = $name";
      say STDERR "\$suff = $suff";
   }

   # Return an error code unless $path points to an existing "data file" (non-directory, non-link
   # regular file which we can read data from):
   if ( !is_data_file($path) ) {return '***NON-DATA***'}

   # If this is a "meta" file (hidden, desktop, browse, thumbnails, etc), return old suffix,
   # else we will end up discarding valid type info and mis-labeling the file:
   if ( is_meta_file($path) ) {return '***META***'}

   # Try to determine the correct suffix using the checktype_filename() method from module "File::Type":
   my $typer = File::Type->new(); # File-typing functor.
   my $type  = $typer->checktype_filename($path); # Get media-type of file at $path.

   # If checktype_filename() crashed, either the file is corrupt or we don't have permission to access it;
   # either way, it's an error:
   if ( ! defined $type ) {return '***ERROR***'}

   # If we get to here, we've successfully obtained the media type of the file at $path.
   # Now lets "normalize" that type, converting it to all-lower-case and getting rid of cruft:
   $type = lc $type;      # Lower-case the type.
   $type =~ s%/x(-|.)%/%; # Get rid of "unregistered "markers ("x-" and variants).
   $type =~ s%\+\pL+%%;   # Get rid of alternate type interpretations (eg, xml for svg).

   # Announce type if debugging:
   if ( $Debug ) {
      say STDERR '';
      say STDERR "In get_correct_suffix(), just got type.";
      say STDERR "\$type = $type";
   }

   # Match normalized type against known types and choose extension if possible:
   for ($type) {
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
      m%javascript%                                        and return '.js'   ;
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

   # If this file is at-least 10 bytes in size, let's grab AT-LEAST the first 10 bytes of its contents,
   # up to a max of 512 bytes, and examine the contents for clues as to what kind of file this is,
   # or if we CAN'T read at least 10 bytes, return "***ERROR***":
   my $size = -s e $path;
   my $buffer = '';
   if ( $size >= 10 ) {
      my $fh = undef;
      open($fh, '< :raw', e($path)) or return '***ERROR***' ; # File can't be opened.
      read($fh, $buffer, 512)       or return '***ERROR***' ; # File can't be read.
      close($fh)                    or return '***ERROR***' ; # File can't be closed.
      my $bytes = length($buffer);
      $bytes >= 10                  or return '***ERROR***' ; # Should have been able to read 10+ bytes.

      if ( $Debug ) {
         say STDERR '';
         say STDERR "In get_correct_suffix(), just loaded \$buffer.";
         say STDERR "\$size  = $size";
         say STDERR "\$bytes = $bytes";
      }

      # Pore over the contents of $buffer and try to glean clues as to what type of file this is:

      # Is this a Linux executable?
      "\x{7F}ELF" eq substr($buffer, 0, 4)                 and return ''      ; # Linux ELF executable

      # Is this a hashbang script?
      if ( '#!' eq substr($buffer, 0, 2) ) {
         my $fl = ($buffer =~ s/^(.+?)\n.*$/$1/rs);
         $fl =~ m%^#!.*apl%i                               and return '.apl'  ; # APL
         $fl =~ m%^#!.*awk%i                               and return '.awk'  ; # AWK
         $fl =~ m%^#!.*bash%i                              and return '.sh'   ; # BASH
         $fl =~ m%^#!.*node%i                              and return '.js'   ; # Javascript
         $fl =~ m%^#!.*perl%i                              and return '.pl'   ; # Perl
         $fl =~ m%^#!.*python%i                            and return '.py'   ; # Python
         $fl =~ m%^#!.*raku%i                              and return '.raku' ; # Raku
         $fl =~ m%^#!.*sed%i                               and return '.sed'  ; # Sed
      }

      # Next, see if this file is any of various non-text non-executable types:
      "AVI" eq substr($buffer, 8, 3)                       and return '.avi'  ; # AVI (Windows video)
      pack('C4',195,202,4,193) eq substr($buffer,0,4)      and return '.ccf'  ; # CCF (Chrome Cache File)
      'fLaC' eq substr($buffer,0,4)                        and return '.flac' ; # fLaC (high-quality sound)
      'FLV' eq substr($buffer,0,3)                         and return '.flv'  ; # FLV (FLash Video)
      'GIF' eq substr($buffer,0,3)                         and return '.gif'  ; # GIF (lo-color grphcs; anim)
      '\xFF\xD8\xFF' eq substr($buffer,0,3)                and return '.jpg'  ; # JPG (lossy compression)
      'ftypmp4' eq substr($buffer,4,7)                     and return '.mp4'  ; # MP4 (good video format)
      'PAR2' eq substr($buffer,0,4)                        and return '.par2' ; # PAR2 (checksum)
      'PDF' eq substr($buffer,1,3)                         and return '.pdf'  ; # PDF (Portable Document Fmt.)
      'PNG' eq substr($buffer,1,3)                         and return '.png'  ; # PNG (Portable Network Grph.)
      'Rar' eq substr($buffer,0,3)                         and return '.rar'  ; # RAR (compressed archive)
      'WAVEfmt' eq substr($buffer,8,7)                     and return '.wav'  ; # WAV (lossless sound)
      'WEBP' eq substr($buffer,8,4)                        and return '.webp' ; # WEBP (photo or video)
      pack('C[16]',  48,  38, 178, 117, 142, 102, 207,  17,
                    166, 217,   0, 170,   0,  98, 206, 108)
         eq substr($buffer,0,16)                           and return '.wma'  ; # WMA (Windows Media Audio)
      '\x30\x26\xB2\x75\x8E\x66\xCF\x11'.
      '\xA6\xD9\x00\xAA\x00\x62\xCE\x6C'
         eq substr($buffer,0,16)                           and return '.wmv'  ; # WMV (Windows Media Video)
      'wOFF' eq substr($buffer,0,4)                        and return '.woff' ; # Web Open Font Format

      # Might this be a CSS file?
      # WOMBAT RH 2023-09-06: For now, I'm commenting this out, as it's too dangerous to search the entire
      # buffer for these terms, as the buffer may be huge and these terms are a bit ubiquitous:
      # $buffer =~
      # m% background.*: | border.*:      | margin.*:    |
      #    padding.*:    | font-family.*: | font-size.*: |
      #    font-weight.*:                                %ix and return '.css'  ; # CSS (style sheets)

      # Might this be an HTML file?
      $type eq 'application/octet-stream'
      && is_utf8($buffer)
      && substr($buffer, 0, 75) =~ m%^<!doctype\s*html%i   and return '.html' ; # HTML (markup)

      # Save "txt" for last, else other types (eg, html)
      # may falsely be reported as being "txt":
      if ( $type eq 'application/octet-stream' ) {
         is_ascii($buffer)                                 and return '.txt'  ; # ASCII      text file.
         is_iso_8859_1($buffer)                            and return '.txt'  ; # ISO-8859-1 text file.
         is_utf8($buffer)                                  and return '.txt'  ; # UTF-8      text file.
      }
   }

   # If we get to here, we've failed to definitively determine the correct suffix.
   # If the original file name has no suffix (or suffix '.unk'), return '.unk':
   if ('' eq $suff || '.unk' eq $suff) {return '.unk'} # File of unknown type.
   # Otherwise, return '***ASSUMED***':
   else {return '***ASSUMED***'} # Tentatively assume that the existing suffix is correct.
} # end sub get_correct_suffix :prototype($) ($path)

# Convert a fully-qualified Cygwin path to Windows:
sub cyg2win :prototype($) ($path) {
   $path =~ s#^/cygdrive/(\p{Ll})#\U$1\E:#;
   $path =~ s#/#\\#g;
   return $path;
} # end sub cyg2win ($)

# Convert a fully-qualified Windows path to Cygwin:
sub win2cyg :prototype($) ($path) {
   $path =~ s#^(\p{Lu}):#/cygdrive/\L$1\E#;
   $path =~ s#\\#/#g;
   return $path;
} # end sub win2cyg ($)

# Get a hash or hash-based file name for a file.
# Mandatory arguments:
#    $path   (Path of file to make hash for. Eg: /home/Bob/myfile.txt)
#    $type   (Type of hash to generate. Options are: md5 sha1 sha224 sha256 sha384 sha512)
# Optional arguments:
#    $mode   (Options are: "name" (hash-based file name, eg "9e5a...b071.txt")
#                       or "hash" (default: just the hash).)
#    $suff   (Options are: "orig" (use original file-name suffix)
#                          "corr" (use correct  file-name suffix)
sub hash :prototype($$;$$)
(
   $path,                                                      # Path to source file.
   $type,                                                      # What type of hash?
   $mode = 'hash',                                             # Return raw hash, or hash-based file name?
   $suff = 'original',                                         # Use original suffix or get correct?
)
{
   return '***ERROR***' unless is_data_file($path);            # Bail unless file at $path is a data file.

   local $/ = undef;                                           # Set input record separator to EOF.
   my $fh;                                                     # File handle (initially undefined).
   open($fh, '< :raw', e($path))                               # Try to open the file for reading;
   or warn "Error in sub \"hash()\" in module \"Dir.pm\":\n".  # if file-open failed for any reason,
           "Couldn't open file \"$path\" for reading.\n"       # warn user
   and return '***ERROR***';                                   # and return '***ERROR***'.
   my $data = <$fh>;                                           # Slurrrp file into $data as one big string.
   defined $data                                               # Test if $data is defined.
   or warn "Error in sub \"hash()\" in module \"Dir.pm\":\n".  # If file-read failed for any reason
           "Couldn't read data from file \"$path\".\n"         # warn user
   and return '***ERROR***';                                   # and return '***ERROR***'.
   close($fh);                                                 # Close file.

   # Set $hash to the hash type user requested:
   my $hash;                                                   # Hash of file contents
   switch ($type) {
      case 'md5' {
         $hash = md5_hex($data);                               # Get MD-5 file hash.
      }
      case 'sha1' {
         $hash = sha1_hex($data);                              # Get SHA-1 file hash.
      }
      case 'sha224' {
         $hash = sha224_hex($data);                            # Get SHA-224 file hash.
      }
      case 'sha256' {
         $hash = sha256_hex($data);                            # Get SHA-256 file hash.
      }
      case 'sha384' {
         $hash = sha384_hex($data);                            # Get SHA-384 file hash.
      }
      case 'sha512' {
         $hash = sha512_hex($data);                            # Get SHA-512 file hash.
      }
      else {
         return '***ERROR***';                                 # Return '***ERROR***'.
      }
   } # end for ($type)

   # Take different actions depending on what mode-of-operation we're in:
   switch ($mode) {
      case 'hash' {                                            # If mode-of-operation is "hash":
         return $hash;                                         # Return hash.
      }
      case 'name' {                                            # If mode-of-operation is "name":
         my $suffix;
         switch ($suff) {
            case 'corr' {                                      # If user asked for suffix correction,
               $suffix = get_correct_suffix($path);            # get correct file-name suffix for this file.
            }
            else {                                             # Otherwise,
               $suffix = get_suffix($path);                    # just use the original suffix
            }                                                  # (or no suffix if there was none).
         }
         my $newname = $hash . $suffix;                        # Make new file name.
         ! -e e $newname and return $newname                   # If the new name doesn't exist, return it,
         or return find_avail_enum_name($newname);             # else return enumerated version.
      }
      else {                                                   # If $operation_mode is invalid:
         return '***ERROR***';                                 # Return "***ERROR***".
      }
   } # end for ($mode)
   print STDERR                                                # Here, we can't possibly arrive.
   "Over the cobbles he clattered and clashed\n".              # But if we somehow do,
   "in the dark inn-yard.\n".                                  # then we should studiously strive
   "He tapped with his whip on the shutters,\n".               # some cryptic words to spew.
   "but all was locked and barred.\n".                         # Love is not a victory march!
   "He whistled a tune to the window,\n".                      # It is a cold and broken hallelujah!
   "and who should be waiting there\n".                        # This is a dangerous meeting;
   "But the landlord’s black-eyed daughter,\n".                # danger of death it brings.
   "    Bess, the landlord’s daughter,\n".                     # But love is intoxicating (though fleeting);
   "Plaiting a dark red love-knot\n".                          # so joyfully his heart sings.
   "into her long black hair.\n";                              # A dimension not of sight and sound,
   return 'We\'re in the Twilight Zone now, baby.';            # but of pure imagination.
} # end sub hash($$;$)

# Shorten directory and file names for Spotlight:
sub shorten_sl_names :prototype($$$$) ($src_dir, $src_fil, $dst_dir, $dst_fil) {
   my $s1 = '/cygdrive/c/Users';
   my $s2 = '/AppData/Local/Packages';
   my $s3 = '/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy';
   my $s4 = '/LocalState/Assets';
   my $s5 = '/cygdrive/sl';
   my $u1 = '/Aragorn';
   my $u2 = '/Urgabor';
   my $u3 = '/Zebulon';
   my $u4 = '/Administrator';

   $src_dir =~ s%$s1$u1$s2$s3$s4%/usl1%;
   $src_dir =~ s%$s1$u2$s2$s3$s4%/usl2%;
   $src_dir =~ s%$s1$u3$s2$s3$s4%/usl3%;
   $src_dir =~ s%$s1$u4$s2$s3$s4%/usl4%;

   $src_fil =~ s%^.{8}\K.{4,}$%...%;

   $dst_dir =~ s%$s5%/sl%;

   $dst_fil =~ s%^.{8}\K.{4,}$%...%;

   return ($src_dir, $src_fil, $dst_dir, $dst_fil);
} # end sub shorten_sl_names ($$$$)

# Return 1 if-and-only-if a path points to a data file (an existing, non-dir, non-link, non-empty plain file).
# (Note: All "meta" files are "data" files, but most "data" files are not "meta" files; see next subroutine.)
sub is_data_file :prototype($) ($path) {
   return 0 if ! -e e($path);       # Nonexistent files contain no data.
   my @stats = lstat e($path);      # Try to get statistics for file.
   return 0 if 13 != scalar @stats; # Files with no statistics contain no data.
   return 0 if   -d _ ;             # Directories contain no data.
   return 0 if   -l _ ;             # Links contain no data.
   return 0 if ! -f _ ;             # Special files contain no data that we should be messing with.
   return 0 if   -z _ ;             # Empty files contain no data.
   return 1;                        # This file contains data. :-)
} # end sub is_data_file :prototype($) ($path)

# Return 1 if-and-only-if a given string is a path to a "meta" file (a file which is hidden, desktop-settings,
# windows-picture-thumbnails, paint-shop-pro-browse-thumbnails, or ID-Token). Keep in mind that "hidden"
# includes ALL files with names starting with ".", which include application settings, Free-File-Sync
# synchronization files, Dolphin ".directory" files, Kate project files, hidden directories, etc; these are
# all "meta" files, not intended for direct use by humans.
#
# Also note that this subroutine examines only the NAME of a file, and does not test if it exists, or what
# kind of file it is. This is by design. If you want to see if a file EXISTS and/or contains DATA, then use
# "is_data_file" instead. THIS subroutine tells you only whether a file has a "meta" name.`
sub is_meta_file :prototype($) ($path) {
   my $name = get_name_from_path($path);
   return 1 if $name =~ m/^\./;
   return 1 if $name =~ m/^desktop.*\.ini$/i;
   return 1 if $name =~ m/^thumbs.*\.db$/i;
   return 1 if $name =~ m/^pspbrwse.*\.jbf$/i;
   return 1 if $name =~ m/id-token/i;
   return 0;
}

# Return 1 if-and-only-if a given string is a fully-qualified path to a valid directory.
sub is_valid_qual_dir :prototype($) ($path) {
   my $valid = 1;
   if ( !defined($path) ) {
      print STDERR "\nWarning from \"is_valid_qual_dir\": path is not defined.\n";
      $valid = 0;
   }
   elsif ( length($path) < 1 ) {
      print STDERR "\nWarning from \"is_valid_qual_dir\": path is zero-length.\n";
      $valid = 0;
   }
   elsif ( substr($path,0,1) ne '/' ) {
      print STDERR "\nWarning from \"is_valid_qual_dir\": path does not start with a slash:\n$path\n";
      $valid = 0;
   }
   elsif ( ! -e e $path ) {
      print STDERR "\nWarning from \"is_valid_qual_dir\": path does not exist:\n$path\n";
      $valid = 0;
   }
   elsif ( ! -d e $path ) {
      print STDERR "\nWarning from \"is_valid_qual_dir\": path is not a directory:\n$path\n";
      $valid = 0;
   }
   return $valid;
} # end sub is_valid_qual_dir ($)

=head2  update_sha1

Updates the ".sha1" SHA-1 file-hash hash-table file in a given directory (or creates it if it doesn't exist)
and returns a reference to a hash table of all non-meta, non-empty data files in the given directory, giving
their names, sizes, timestamps, and SHA-1 hashes of their contents:

update_sha1($dir=d(getcwd))
=cut
sub update_sha1 :prototype(;$) ($dir=d(getcwd)) {
   # Make a hash table to hold info on files:
   my %ht;

   # Get a list of names of all non-meta data files in current directory:
   my @raw = readdir_regexp_utf8($dir, 'F');
   my $nr = scalar(@raw);
   my @names;
   my $nf = 0;
   foreach my $name (@raw) {
      next if !is_data_file($name);
      next if  is_meta_file($name);
      push @names, $name;
      ++$nf;
   }
   if ($Debug) {say STDERR "In update_sha1; got $nr raw files and $nf data files."}

   # Get path to ".sha1" file, if any:
   my $sha1_path = path($dir, ".sha1");

   # Do we need to make a new ".sha1" in this directory?
   my $new_flag = !(-e e($sha1_path));

   # Make a flag to indicate whether we update an existing ".sha1" file:
   my $upd_flag = 0;

   # If ".sha1" does not exist, load %ht from @names:
   if ($new_flag) {
      foreach my $name (@names) {
         my $path   = path($dir, $name);
         my @stats  = lstat e($path);
         my $size   = $stats[7];
         my $modt   = $stats[9];
         my $sha1   = sha1($path);
         $ht{$name} = {Size => $size, Modt => $modt, Sha1 => $sha1};
      }
   } # end if (".sha1" does NOT exist)

   # Else if ".sha1" DOES exist, load %ht from ".sha1",
   # then make sure that every directory entry exists in %ht and every %ht entry exists in directory:
   else {
      # Load info from ".sha1" into %ht:
      my $fh = undef;
      open($fh, '<', $sha1_path)
      or say STDERR "Error: Couldn't open file \".sha1\" in directory \"$dir\"."
      and return 0;
      while (<$fh>) {
         chomp;
         my ($name, $size, $modt, $sha1) = split '/', $_ ;
         $ht{$name} = {Size => $size, Modt => $modt, Sha1 => $sha1};
      }
      close($fh)
      or say STDERR "Error: Couldn't close file \".sha1\" in directory \"$dir\"."
      and return 0;
      # Make sure that every name in directory is accurately recorded in %ht:
      foreach my $name (@names) {
         my $path  = path($dir,$name);
         my @stats = lstat e($path);
         my $size  = $stats[7];
         my $modt  = $stats[9];
         # If $name isn't in table, or if size or mod-date have changed,
         # get new hash and update entry in table:
         if ( ! defined $ht{$name} || $size != $ht{$name}->{Size} || $modt != $ht{$name}->{Modt} ) {
            if ($Debug) {say STDERR "File \"$name\" in directory \"$dir\" is not in hash table.";}
            my $sha1 = sha1($path);
            $ht{$name} = {Size => $size, Modt => $modt, Sha1 => $sha1};
            $upd_flag = 1;
         }
      } # end for each directory entry
      # Delete any %ht entries that don't correspond to anything in @names:
      foreach my $key (keys %ht) {
         if ( none { $_ eq $key } @names ) {
            if ($Debug) {say STDERR "Hash-table key \"$key\" is not in directory \"$dir\".";}
            delete $ht{$key};
            $upd_flag = 1;
         } # end if nothing in directory corresonds to $key
      } # end foreach key in %ht
   } # end else (".sha1" DOES exist)

   # If we need a new or updated ".sha1" file, write %ht to ".sha1":
   if ($new_flag || $upd_flag) {
      my $fh = undef;
      open($fh, '>', $sha1_path)
      or say STDERR "Error: Couldn't open file \".sha1\" for writing in directory \"$dir\"."
      and return 0;
      foreach my $key (sort {$a cmp $b} keys %ht) {
         my $name = $key;
         my $size = $ht{$name}->{Size};
         my $modt = $ht{$name}->{Modt};
         my $sha1 = $ht{$name}->{Sha1};
         say $fh join('/', $name, $size, $modt, $sha1);
      }
      close($fh)
      or say STDERR "Error: Couldn't close file \".sha1\" in directory \"$dir\"."
      and return 0;
      # Always say path, to STDOUT:
      if ($new_flag) {say "Wrote new \".sha1\" file to directory \"$dir\"."}
      if ($upd_flag) {say "Wrote updated \".sha1\" file to directory \"$dir\"."}
   }
   my $htref = \%ht;
   return ($htref, $nf, $new_flag, $upd_flag);
}

=head2 sha1

Given a path to a file, this subroutine returns the SHA-1 hash of the given file:

sha1($path)
=cut
sub sha1 :prototype($) ($path) {
   my   $fh = undef;                           # File handle (initially undefined).
   local $/ = undef;                           # Set "input record separator" to EOF.
   open($fh, '< :raw', $path)                  # Try to open the file for reading in "raw" mode.
   or warn "Error: couldn't open \"$path\".\n" # If file-open failed, warn user
   and return '***ERROR***';                   # and return error code.
   my $data = <$fh>;                           # Slurp file into $data as one big string of unprocessed bytes.
   defined $data                               # Test if $data is defined.
   or warn "Error: couldn't read \"$path\".\n" # If file-read failed, warn user
   and return '***ERROR***';                   # and return error code.
   close($fh);                                 # Close file.
   return sha1_hex($data);                     # Return SHA-1 hash of file.
} # end sub sha1

1;
