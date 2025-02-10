#!/usr/bin/env -S perl -C63

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# File path:    /rhe/scripts/math/graph-equations.pl
# Program name: "Graph Equations"
# Description:  Graphs one or more equations to a bmp file, then opens that
#               bmp file in the OS's default bmp-file viewer.
# Input:   A set of up to 10 equations, written in Perl, as command-line
#          arguments to this program (which simply eval's them).
#          The equations must be written in the format "$y = $x**2+3*$x-2"
#          (that is, they must set $y equal to an expression involving $x).
# Output:  Creates temp file "graph-data.dat" in curr dir, containing
#          coordinate and color data for all points to be graphed. Then,
#          calls "plot-points.exe" (which must actually exist in user's path)
#          which plots the points to a bmp file, the name of which is can be
#          specified as an argument to this program (else it defaults to
#          "graph-pict.bmp"in the current directory).
# Edit history:
#    Fri Apr 22, 2016: Wrote first draft.
#    Fri May 06, 2016: I've gone over to using Getopt::Long to get options;
#                      all arguments are now of the form -xmin=-3.693 ,
#                      rather than a long stream of unlabeled arguments.
#                      Also, all formerly-global variables are now lexical
#                      variables in the main part of the script.
#    Mon Jan 01, 2018: Added a check to reject non-numeric y values.
#    Sun Jan 07, 2018: Described inputs & outputs in comments above.
#    Tue Apr 10, 2018: Improve help and comments; reverted to "use v5.020".
#######################################################################################################################

use v5.32;
use utf8;

use Getopt::Long qw( :config bundling permute no_ignore_case
                      no_auto_abbrev pass_through );
use Math::Trig;
use Math::Counting ':student';
use Math::Counting ':big';

use RH::Math;

sub help_msg;

# main
{
   # set e (pi is already set by Math:Trig):
   use constant e  => exp(1);

   # Settings with default values, re-settable by user options:
   my $help   =      0; # Does user want help?
   my $xmin   =    0.0; # minimum x value for graph
   my $xmax   =   6*pi; # maximum x value for graph
   my $ymin   =   -3.0; # minimum y value for graph
   my $ymax   =    3.0; # maximum y value for graph
   my $width  =   1200; # width  of bitmap image
   my $height =    600; # height of bitmap image
   my $bits   =      8; # bits per pixel
   my $comp   =      1; # Use compression?
   my $bpath  = 'graph-pict.bmp'; # path to graph bitmap file

   # Settings with fixed values (not adustable)
   my $dpath  = 'graph-data.dat'; # path to temporary data file

   GetOptions
      (
         'help|h'   => sub {help_msg; exit 777;},
         'xmin=f'   => \$xmin,
         'xmax=f'   => \$xmax,
         'ymin=f'   => \$ymin,
         'ymax=f'   => \$ymax,
         'width=i'  => \$width,
         'height=i' => \$height,
         'bits=i'   => \$bits,
         'comp=i'   => \$comp,
         'bpath=s'  => \$bpath
      )
      or die 'Error: Invalid arguments in "graph-equations.pl".';

   # If user wants help, just print help and bail:
   if ($help) {help_msg; exit 777;}

   # Get equations:
   my @Equations;
   foreach (@ARGV) {if ('$y' eq substr($_,0,2)) {push(@Equations, $_);}}

   # Bail if user didn't provide any equations:
   if ( @Equations < 1 )
   {
      say 'Error in "graph-equations.pl": You didn\'t provide any equations to graph.';
      exit 666;
   }

   # Bail if user provided more than 10 equations:
   if ( @Equations > 10 )
   {
      say 'Error in "graph-equations.pl": Max # of equations is 10.';
      exit 666;
   }

   # Calculate delta_x:
   my $span     = $xmax - $xmin;   # $span    = total x-span
   my $pixel    = $span / $width;  # $pixel   = x-span per pixel
   my $delta_x  = $pixel / 100.0;  # $delta_x = 1/100 pixel-width

   # Plot equations to an array of points:
   my @Points;
   my $x;
   my $y;
   my $c;
   for ( $x = $xmin ; $x <= $xmax ; $x += $delta_x )
   {
      my $eqnum;
      for ( $eqnum = 0 ; $eqnum <= $#Equations ; ++$eqnum )
      {
         eval($Equations[$eqnum]);    # sets $y
         if (!is_number($y))
         {
            warn("\$y is not a number");
            next;
         }
         $c = $eqnum + 5;             # color index in range 5-14
         push(@Points, [$x, $y, $c]); # stow point (x,y,c) in array
      }
   }

   # Write array to data file, one point per line, each point
   # written as the 3 numbers x y c separated by spaces:
   my $fh;
   open($fh, '>', $dpath)
      or die "Couldn't open file $dpath for output.\n$!\n";

   foreach my $Point (@Points)
   {
      printf($fh "%f %f %d\n", $Point->[0], $Point->[1], $Point->[2]);
   }
   close($fh);

   # Call plot-points:
   system
   (
      "plot-points '$xmin'  '$xmax'   '$ymin' '$ymax' ".
                  "'$width' '$height' '$bits' '$comp' ".
                  "'$dpath' '$bpath'"
   );

   # Display graph:
   chmod(0775, $bpath);
   my $command = '/cygdrive/c/Programs/Graphics/IrfanView/i_view64.exe';
   my @args = ($bpath);
   say("\$command = $command");
   say("\@args = @args");
   my $result = system($command, @args);
   say("system returned \"$result\"");
   say("\$! = \"$!\".");

   # Announce graph displayed and about to unlink data file:
   say 'Graph has been displayed; about to unlink temporary data file....';

   # Get rid of the temporary file:
   unlink($dpath);

   # We be done, so scram:
   say('Bye-bye!');
   exit 0;
} # end MAIN

sub help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "graph-equations.pl". This program graphs equations to a bmp file,
   provided that the companion program, "plot-points.exe", is installed on your
   system in a location listed in your shell's path

   Typical command line:
   graph-equations.pl --xmin=-2 --xmax=2 --ymin=-2 --ymax=2  \
   --width=1100 --height=800 --bits=8 --comp=1 --bpath=pic.bmp \
   '$y=sin($x)' '$y=cos($x)'

   Command-line arguments are segregated into 2 types:
   1. Options   (Starts with "--".  Example: --xmin=2.365)
   2. Equations (Starts with "$y". Example: $y = 3*$x**2 -7*$x +4)

   The following options are optional, but typically you'll want to specify
   most of these, else this program will use set defaults, which usually
   aren't what you want. The values shown are just examples; substitute any
   values you want. These can appear in any order.

   --help          # use this as sole argument to get this help
   --xmin=-32.8    # minimum x (left   edge) for graph; default = 0
   --xmax=86.5     # maximum x (right  edge) for graph; default = 6pi
   --ymin=-0.02    # minimum y (bottom edge) for graph; default = -3
   --ymax=3395.7   # maximum y (top    edge) for graph; default = +3
   --width=615     # width    of bitmap (10 to 6007)  ; default = 1200
   --height=205    # height   of bitmap (10 to 6007)  ; default = 600
   --bits=24       # bitcount of bitmap (1,4,8, or 24); default = 8
   --comp=0        # compression of bitmap (0 or 1)   ; default = 1
   --bpath=xyz.bmp # path for bitmap (default is ./graph-pict.bmp)

   After the options, write one to ten equations in Perl setting variable $y
   equal to various expressions in terms of variable $x. Use standard Perl
   operators ( + - * / ) for arithmetic, ** for exponents and roots,
   and sin, cos, tan, cot, sec, csc for trigonometric functions.
   Put all equations in 'single quotes', else your shell may try to interpolate
   or expand them instead of sending them to graph-equations.pl intact.

   graph-equations.pl will then calculate data points, using 100 points per
   pixel width (for continuous graph lines even in areas of high slope),
   and store a data file named "graph-data.dat" in the current directory
   containing those points as (x,y,c) triplets (where c is a color index
   unique to one particular equation). This program will then pass the paths
   of the data file and bmp file to "plot-points.exe", which will plot the
   points from the data file to the bmp file. After "plot-points.exe"
   returns, "graph-equations.pl" will then open the bmp file in
   whatever program is Windows's default program for bmp files.

   NOTE: for the bmp file path, specify a name only, because the path needs
   to be valid in both Windows and BASH, because it's going to be launched in
   a Windows program. This is especially a problem if you're using Cygwin,
   because Windows doesn't understand "/cygdrive/d/argle/abc.bmp".
   So insted, manually cd to "/cygdrive/d/argle" in cygwin's BASH, which
   will put you in Windows folder "D:\argle". Then use "--bpath=abc.bmp",
   which will write abc.bmp to folder "D:\argle".

   NOTE: You'll probably need to change the "my $command = " line to something
   more suitable for your system, depending on what graphics viewer you want to
   view graphs in.

   Happy equation graphing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help_msg
