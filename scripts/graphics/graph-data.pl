#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# Program name: "Graph Data"
# File name:    "graph-data.pl"
# Description:  Graphs data from a CSV file to a BMP file, then opens that bmp file in the OS's default
#               bmp-file viewer.
# Input:        A CSV file with each line consisting of an independent value followed by one-or-more dependent
#               values.
# Output:       Creates temp file "graph-data.dat" in curr dir, containing coordinate and color data for all
#               points to be graphed. Then, calls "plot-points.exe" (which must actually exist in user's path)
#               which plots the points to a bmp file, the name of which is can be specified as an argument to
#               this program (else it defaults to "graph-pict.bmp"in the current directory).
# Edit history:
#   Tue Sep 01, 2026: I wrote the first draft.
##############################################################################################################

# Pragmas and modules:
use v5.36;
use utf8;
use Getopt::Long qw( :config bundling permute no_ignore_case no_auto_abbrev pass_through );
use Math::Trig;
use Math::Counting ':student';
use Math::Counting ':big';
use RH::Math;

# Variables:

$"=', ';

# set e (pi is already set by Math:Trig):
use constant e  => exp(1);

# Settings with default values, re-settable by user options:
my $xmin   =      0.0         ; # minimum x value for graph
my $xmax   =     6*pi         ; # maximum x value for graph
my $ymin   =     -3.0         ; # minimum y value for graph
my $ymax   =      3.0         ; # maximum y value for graph
my $width  =     1200         ; # width  of bitmap image
my $height =      600         ; # height of bitmap image
my $bits   =        8         ; # bits per pixel
my $comp   =        1         ; # Use compression?
my $cpath  = 'data-file.csv'  ; # path to input  CSV data  file
my $bpath  = 'graph-pict.bmp' ; # path to output BMP graph file

# Settings with fixed values (not adustable)
my $dpath  = 'graph-data.dat'; # path to temporary data file

# Subroutine predeclarations:
sub help;

# Main body of program:

{ # begin MAIN
   # Get options:
   GetOptions
      (
         'help|h'   => sub {help; exit;},
         'xmin=f'   => \$xmin,
         'xmax=f'   => \$xmax,
         'ymin=f'   => \$ymin,
         'ymax=f'   => \$ymax,
         'width=i'  => \$width,
         'height=i' => \$height,
         'bits=i'   => \$bits,
         'comp=i'   => \$comp,
         'cpath=s'  => \$cpath,
         'bpath=s'  => \$bpath
      )
      or die 'Error: Invalid arguments in "graph-data.pl".';

   # Get data from CSV file:
   my @data = ();
   my $IFH = undef;
   open($IFH, '<', $cpath)
   or die "Error: Couldn't open CSV file \"$cpath\" for input.\n$!\n";
   foreach my $line (<$IFH>) {
      chomp $line;
      my @coords = split /,/, $line;
      push @data, [@coords];
   }
   close($IFH)
   or die "Error: Couldn't close CSV file \"$cpath\".\n$!\n";

   # Die if we didn't get any data:
   scalar(@data) > 0
   or die "Error: Failed to get any data.\n$!\n";

   # Die if number of dependent values is less than 1 or more than 10:
   my $size = scalar(@{$data[0]}) - 1;
   $size >= 1 && $size <= 10
   or die "Error: Number of dependent values must be from 1 through 10.\n$!\n";

   # Die if data points do not all have same number of coordinates:
   foreach my $point (@data) {
      scalar(@{$point}) == $size + 1
      or die "Error: All data points must have same number of coordinates.\n$!\n";
   }

   # Die if any of the data is out-of-range:
   my $eflag = 0;
   foreach my $point (@data) {
      my @coords = @{$point};
      my $x = $coords[0];
      $x >= $xmin    or warn "Error: point (@coords) is out-of-bounds left."   and $eflag = 1;
      $x <= $xmax    or warn "Error: point (@coords) is out-of-bounds right."  and $eflag = 1;
      for ( my $vnum = 1 ; $vnum <= $size ; ++$vnum) {
         my $y = $coords[$vnum];
         $y >= $ymin or warn "Error: point (@coords) is out-of-bounds bottom." and $eflag = 1;
         $y <= $ymax or warn "Error: point (@coords) is out-of-bounds top."    and $eflag = 1;
      }
   }
   exit 1 if $eflag;

   # Plot data to an array of colored points:
   my @Points;
   foreach my $point (@data) {
      my @coords = @{$point};
      my $x = $coords[0];
      for ( my $vnum = 1 ; $vnum <= $size ; ++$vnum )
      {
         my $y = $coords[$vnum];
         my $c = $vnum + 4;           # color index in range 5-14
         push(@Points, [$x, $y, $c]); # stow point (x,y,c) in array
      }
   }

   # Write array to data file, one point per line, each point
   # written as the 3 numbers x y c separated by spaces:
   my $OFH;
   open($OFH, '>', $dpath)
   or die "Couldn't open file \"$dpath\" for output.\n$!\n";

   foreach my $Point (@Points) {
      printf($OFH "%f %f %d\n", $Point->[0], $Point->[1], $Point->[2]);
   }
   close($OFH)
   or die "Error: Couldn't close file \"$dpath\".\n$!\n";

   # Call plot-points:
   system
   (
      "plot-points '$xmin'  '$xmax'   '$ymin' '$ymax' ".
                  "'$width' '$height' '$bits' '$comp' ".
                  "'$dpath' '$bpath'"
   );

   # Display graph:
   my $command = 'viewnior';
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

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "graph-data.pl". This program graphs data from a CSV file to
   a BMP file, provided that the companion program, "plot-points.exe", is
   installed on your system in a location listed in your shell's path

   Typical command line:
   graph-data.pl --xmin=-2    --xmax=2     --ymin=-2 --ymax=2  \
                 --width=1100 --height=800 --bits=8  --comp=1  \
                 --cpath=data.csv --bpath=pic.bmp

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
   --cpath=xyz.csv # path for input data CSV file (default is ./data-file.csv)
   --bpath=xyz.bmp # path for output bitmap  file (default is ./graph-pict.bmp)

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
