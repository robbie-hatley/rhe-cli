#!/usr/bin/perl

##########################################################
# file-test.pl
# Test of file- and directory- related Perl techniques.
##########################################################

use v5.32;
use common::sense;
use Sys::Binmode;

use Cwd;

use RH::Util;
use RH::Dir;


# Main body of program:
{ # begin main
   # Get and open current working directory:
   my $CurDir = cwd_utf8;
   say ("Current directory is ", $CurDir);

   my @CurDirFiles;
   my $fh = undef;
   opendir($fh, e $CurDir) or die "Can\'t open directory \"$CurDir\"!\n$!\n";
   my @names = map {d($_)} readdir $fh;

   GETINFO: foreach my $name (@names)
   {
      # Skip "." and "..":
      next if ($name eq '.' || $name eq '..');

      # Skip items which do not exist:
      next if ! -e e $name;

      # Is current file a "regular" file?
      my $regular = (-f e $name) ? 1 : 0 ;

      # Get info:
      my ($inode, $mode, $nlinks, $size, $mtime) = (lstat(e($name)))[1,2,3,7,9];

      # Push file info record for this file onto array:
      push @CurDirFiles,
         {
            "Name"    => $name,
            "Inode"   => $inode,
            "Mode"    => $mode,
            "Regular" => $regular,
            "NLinks"  => $nlinks,
            "Size"    => $size,
            "Time"    => $mtime
         };

   };
   closedir($fh);

   my $count= scalar @CurDirFiles;
   say "There are $count files in this directory:";
   PRINTINFO: foreach my $fileinfo (@CurDirFiles)
   {
      printf
      (
        "%-40s %18s %10s %1s %2d %10d %10d\n",
        $fileinfo->{Name},
        $fileinfo->{Inode},
        $fileinfo->{Mode},
        $fileinfo->{Regular},
        $fileinfo->{NLinks},
        $fileinfo->{Size},
        $fileinfo->{Time},
      );
   }

   for (my $i = 0 ; $i < ($count - 1) ; ++$i)
   {
      my $name1  = $CurDirFiles[$i]->{Name};
      my $inode1 = $CurDirFiles[$i]->{Inode};

      for (my $j = $i + 1 ; $j < $count ; ++$j)
      {
         my $name2  = $CurDirFiles[$j]->{Name};
         my $inode2 = $CurDirFiles[$j]->{Inode};

         # If these files have same inode, notify user:
         if ($inode1 == $inode2)
         {
            print("\nThese two files share inode $inode1:\n$name1\n$name2\n");
         }

      }
   }

   foreach my $fileinfo (@CurDirFiles)
   {
      my $name   = $fileinfo->{Name};   # won't compile without ->
      my $nlinks = $fileinfo->{NLinks}; # won't compile without ->

      # If current file has more than 1 nlink, alert user:
      if ($nlinks >1)
      {
         print("\nThis file has $nlinks nlinks:\n$name\n");
      }
   }

   exit 0;
} # end main
