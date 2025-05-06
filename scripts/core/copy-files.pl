#!/usr/bin/env -S perl -C63

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
##############################################################################################################

# ======= PRAGMAS AND MODULES: ===============================================================================
use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= GLOBAL VARIABLES: ==================================================================================

our $t0   ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program entry.
our $t1   ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program exit.

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

# ======= PROGRAM-SETTINGS VARIABLES: ========================================================================

# Setting:    Default:   Meaning of setting:            Range:    Meaning of default:
   $"         = ', ' ;   # Quoted-array formatting.     string    Comma space.
my $Db        = 0    ;   # Debug?                       bool      Don't debug.
my $src       = ''   ;   # Srce directory.              string    empty
my $dst       = ''   ;   # Dest directory.              string    empty
my $cur       = ''   ;   # Curr directory.              string    empty
my @copy_args = ()   ;   # Arguments for copy_files().  array     empty

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv  ; # Process @ARGV.
sub help  ; # Print help.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process argv:
   argv;

   # Get current working directory:
   $cur = d(getcwd);

   # Get FULLY-QUALIFIED versions of source and destination directories by CDing to each, running getcwd,
   # then CDing back to $cur. WARNING: ALWAYS CD BACK TO $cur BEFORE TRYING TO CD TO $src or $dst, BECAUSE
   # $src AND $dst ARE RELATIVE TO $cur!!!
   chdir  e($src);
   $src = d(getcwd);
   chdir  e($cur);
   chdir  e($dst);
   $dst = d(getcwd);
   chdir  e($cur);

   # If debugging, just emulate:
   if ( $Db ) {
      say STDERR  "\nEMULATING!!!\n".
                  "At bottom of main body of \"copy-files.pl\", after qualifying dir names.\n".
                  "Fully-qualified \$src = \"$src\"\n".
                  "Fully-qualified \$dst = \"$dst\"";
   }

   # Otherwise, copy files:
   else {
      say STDERR  "\nCOPYING!!!\n";
      copy_files($src, $dst, @copy_args);
   }

   # We're done, so exit program, returning success code 0 to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # If debugging, print raw @ARGV:
   if ($Db)
   {
      my $NV = scalar(@ARGV);
      warn "In copy-files.pl, at top of sub argv.\n".
           "\@ARGV $NV elements:\n".
           join("\n", @ARGV) . "\n";
   }

   # Get options and arguments:
   my @opts = ();
   my @args = ();
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @opts, $_     # and push the "--" to @opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   # Get numbers of options and arguments:
   my $NO = scalar(@opts);
   my $NA = scalar(@args);

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit(777)       ;
      /^-$s*e/ || /^--emulate$/ and $Db = 1                  ;
      /^-$s*S/ || /^--sl$/      and push @copy_args, 'sl'    ;
      /^-$s*s/ || /^--sha1$/    and push @copy_args, 'sha1'  ;
      /^-$s*u/ || /^--unique$/  and push @copy_args, 'unique';
      /^-$s*l/ || /^--large$/   and push @copy_args, 'large' ;
      /^-$s*c/ || /^--correct$/ and push @copy_args, 'corr'  ;
   }

   # Set settings and check their validity:
   if ($NA < 2 || $NA > 3)
                      {say STDERR "Error: Must have 2 or 3 arguments. ".
                                  "Use -h or --help to get help."                         ; exit(666) }
   $src = $args[0];
   if ( ! -e e($src) ) {say STDERR "Error: source directory $src doesn't exist."          ; exit(666) }
   if ( ! -d e($src) ) {say STDERR "Error: source directory $src isn't a directory."      ; exit(666) }
   $dst = $args[1];
   if ( ! -e e($dst) ) {say STDERR "Error: destination directory $dst doesn't exist."     ; exit(666) }
   if ( ! -d e($dst) ) {say STDERR "Error: destination directory $dst isn't a directory." ; exit(666) }
   if ( 3 == $NA ) {push @copy_args, 'regexp=' . $args[2];}

   # If debugging, print @Db, @copy_args, $src, $dst:
   if ($Db) {
      my $NC = scalar(@copy_args);
      warn "\nIn copy-files.pl, at bottom of sub argv.\n".
           "\$Db = $Db\n".
           "\@copy_args has $NC elements: " . join(" ", @copy_args) . "\n".
           "Raw \$src = \"$src\"\n".
           "Raw \$dst = \"$dst\"\n";
   }

   # We're finished, so return success code 1 to caller:
   return 1;
} # end sub argv

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
   "-l" or "--large"   Move only large image files (W=1200+, H=600+).
   "-c" or "--correct" Correct missing or wrong file name suffixes.
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

   Also note that this program cannot act recursively; it copies files only from
   the root level of dir1 to the root level of dir2; the contents of any
   subdirectories of dir1 or dir2 are not touched.

   Happy file copying!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
