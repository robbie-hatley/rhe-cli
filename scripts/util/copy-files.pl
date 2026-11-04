#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# copy-files.pl
# Given the paths of two directories, Source and Destination, this program copies all regular files matching
# a regexp from Source to Destination, enumerating each file for which a file exists in Destination with the
# same name root. Optionally, the program can be instructed to NOT copy any files for which duplicates exist
# in the destination, and/or change the name of the file to its own SHA1 hash.
#
# NOTE: You must have Perl and my RH::Dir module installed in order to use this script. Contact Robbie Hatley
# at <lonewolf@well.com> and I'll send my RH::Dir module to you.
#
# Edit history:
# Sat Jan 02, 2021: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Sun Nov 21, 2021: Fixed 4 missing encodes in process_argv.
# Mon Nov 22, 2021: Heavily refactored. Now using sub "copy_files" in RH::Dir instead of local, and using
#                   a regular expression instead of a wildcard to specify files to copy. Also, now subsumes
#                   the script "copy-large-images.pl".
# Tue Nov 23, 2021: Fixed "won't handle relative directories" bug by using the chdir & cwd trick.
# Sat Dec 04, 2021: Fixed minor error in titlecard ("wildcard"->"regexp").
# Tue Oct 03, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Got rid of CPAN module
#                   "common::sense" (antiquated). Now using "d getcwd" instead of "cwd_utf8".
# Thu Aug 15, 2024: -C63; erased unnecessary "use" statements; put protos & sigs on all subs.
# Tue Mar 04, 2025: Got rid of prototypes and empty sigs. Added comments to subroutine predeclarations.
#                   Now using "BEGIN" and "END" blocks to print entry and exit messages.
# Fri Apr 25, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d" and "e". Added [-c|--correct] option, telling program to correct the
#                   file-name suffix of each copied file if necessary.
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
# Mon Aug 25, 2025: Fixed typo in help ("Move only large" → "Copy only large").
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
##############################################################################################################

# ======= PRAGMAS AND MODULES: ===============================================================================
use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our $t0   ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program entry.
our $t1   ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program exit.

# ------- Local variables: -----------------------------------------------------------------------------------

# Setting:    Default:   Meaning of setting:            Range:    Meaning of default:
my $Debug     = 0    ;   # Debug?                       bool      Don't debug.
my $Recurse   = 0    ;   # Recurse?                     bool      Don't recurse.
my $srcdir    = ''   ;   # Source      directory.       string    empty
my $dstdir    = ''   ;   # Destination directory.       string    empty
my @copy_args = ()   ;   # Arguments for copy_files().  array     empty

# ======= BEGIN AND END BLOCKS: ==============================================================================

# NOTE: Don't try to call this directly; it's automatically ran when the program begins:
BEGIN {
   $t0 = time;
   my $pname = get_name_from_path($0);
   say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
}

# NOTE: Don't try to call this directly; it's automatically ran when the program ends:
END {
   $t1 = time; my $te = $t1 - $t0; my $ms = 1000*$te;
   my $pname = get_name_from_path($0);
   say    STDERR "\nNow exiting program \"$pname\" at timestamp $t1.";
   printf STDERR "Execution time was %.3fms.\n", $ms;
}

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub help    ; # Print help.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process argv:
   argv;

   # Get working directory on program entry:
   my $oridir = cwd;

   # Get FULLY-QUALIFIED versions of source and destination directories by CDing to each, running getcwd,
   # then CDing back to $cur. WARNING: ALWAYS CD BACK TO $oridir BEFORE TRYING TO CD TO $src or $dst, BECAUSE
   # $src AND $dst start off possibly relative to $oridir.

   chdir $srcdir;
   $srcdir = cwd;
   chdir $oridir;

   chdir $dstdir;
   $dstdir = cwd;
   chdir $oridir;

   # If debugging, print final values of $srcdir and $dstdir and exit:
   if ( $Debug ) {
      say "\nIn copyfiles.pl, in main body.";
      say "Final value of \$oridir = \"$oridir\"";
      say "Final value of \$srcdir = \"$srcdir\"";
      say "Final value of \$dstdir = \"$dstdir\"";
      exit 0;
   }

   # Set current working directory to $srcdir, just before copying files:
   chdir $srcdir;

   # If recursing, run "RecurseDirs" on "curdire":
   if ( $Recurse ) {
      RecurseDirs {curdire};
   }

   # Otherwise, just run curdire:
   else {
      curdire;
   }

   # We're done, so exit program, returning success code 0 to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Declare and define certain variables we'll need:
   my $e = 0;                # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   my @opts = ();            # options

   # Pull all options OUT of @ARGV and put them in @opts instead:
   for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
      # If current item is end-of-options marker, remove it from @ARGV, set "$e", and consider all remaining
      # contents of @ARGV to be "arguments" rather than "options":
      if ( '--' eq $ARGV[$i] ) {
         $e = 1;
         splice @ARGV, $i, 1;
         --$i;
      }
      # Else if current item is an "option", remove it from @ARGV and push it to @opts:
      elsif ( !$e && ( $ARGV[$i] =~ /^-(?!-)$s+$/ || $ARGV[$i] =~ /^--(?!-)$d+$/ ) ) {
         push @opts, splice @ARGV, $i, 1;
         --$i;
      }
      # Otherwise, this item is an argument, so leave it in @ARGV:
      else {
         ; # Do nothing.
      }
   }
   # @ARGV now contains NO options. If any items remain, they will be construed as being "arguments".

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit(0)                        ;
      /^-$s*e/ || /^--emulate$/ and $Debug = 1 and RH::Dir::rhd_debug('on') ;
      /^-$s*l/ || /^--local$/   and $Recurse = 0                            ; # DEFAULT
      /^-$s*r/ || /^--recurse$/ and $Recurse = 1                            ;
      /^-$s*S/ || /^--sl$/      and push @copy_args, 'sl'                   ;
      /^-$s*s/ || /^--sha1$/    and push @copy_args, 'sha1'                 ;
      /^-$s*u/ || /^--unique$/  and push @copy_args, 'unique'               ;
      /^-$s*g/ || /^--large$/   and push @copy_args, 'large'                ;
      /^-$s*c/ || /^--correct$/ and push @copy_args, 'corr'                 ;
   }

   # Get number of arguments:
   my $NA = scalar(@ARGV);

   # Set settings and check their validity:
   if ($NA < 2 || $NA > 3) {die "Error: Must have 2 or 3 arguments. Use -h or --help to get help.\n" ; }
   $srcdir = $ARGV[0];
   if ( ! -e $srcdir )     {die "Error: source directory $srcdir doesn't exist.\n"                   ; }
   if ( ! -d $srcdir )     {die "Error: source directory $srcdir isn't a directory.\n"               ; }
   $dstdir = $ARGV[1];
   if ( ! -e $dstdir )     {die "Error: destination directory $dstdir doesn't exist.\n"              ; }
   if ( ! -d $dstdir )     {die "Error: destination directory $dstdir isn't a directory.\n"          ; }
   if ( 3 == $NA     )     {push @copy_args, 'regexp=' . $ARGV[2]                                    ; }

   # If debugging, print @Db, @copy_args, $src, $dst:
   if ($Debug) {
      my $NC = scalar(@copy_args);
      warn "\nIn copy-files.pl, at bottom of sub argv.\n".
           "\$Debug = $Debug\n".
           "\$Recurse = $Recurse\n".
           "\$srcdir = \"$srcdir\"\n".
           "\$dstdir = \"$dstdir\"\n".
           "\@copy_args has $NC elements: " . join(" ", @copy_args) . "\n";
   }

   # We're finished, so return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   my $curdir = cwd;
   copy_files($curdir, $dstdir, @copy_args);
}

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "copy-files.pl", Robbie Hatley's nifty file-copying utility.
   This program copies all files matching a regexp from a source directory
   (let's call it "dir1") to a destination directory (let's call it "dir2"),
   enumerting each file if necessary, but skipping all "Thumbs*.db",
   "pspbrwse*.jbf", and "desktop*.ini" files. Optionally, this program can
   skip any files in dir1 for which duplicates exist in dir2, and/or rename
   the copied files' name roots to the files' own SHA1 hashes.

   If a "-r" or "--recurse" option is used, this program will operate
   recursively, copying all matching files from all subdirectories of dir1
   into dir2, enumerating as necessary and optionally skipping duplicates.

   Command lines:
   copy-files.pl [-h|--help]                    (to print this help and exit)
   copy-files.pl [options] dir1 dir2 [regexp]   (to copy files)

   Description of options:
   Option:             Meaning:
   "-h" or "--help"    Print help and exit.
   "-e" or "--emulate" Print diagnostics, emulate file copying, and exit.
   "-S" or "--sl"      Shorten names for when processing Windows Spotlight images.
   "-s" or "--sha1"    Change name root of each file to its own hash.
   "-u" or "--unique"  Don't copy files for which duplicates exist in destination.
   "-g" or "--large"   Copy only large image files (W=1200+, H=600+).
   "-c" or "--correct" Correct missing or wrong file name suffixes.
   "-r" or "--recurse" Operate recursively.
   "-l" or "--local"   Operate locally. (DEFAULT)
   "--"                All items to right are arguments, not options.
   All other options will be ignored.
   Multiple single-letter options can be stacked after a single hypen.
   To use arguments that look like options, first use a "--" option; all further
   command-line arguments will be construed as arguments rather than options.

   Description of arguments:
   "copy-files.pl" takes two mandatory arguments, "dir1" and "dir2", which must be
   paths to existing directories; dir1 is the source directory and dir2 is the
   destination directory.

   Additionally, "copy-files.pl" can take a third, optional argument which,
   if present, must be a Perl-Compliant Regular Expression describing which files
   to copy. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy file copying!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
