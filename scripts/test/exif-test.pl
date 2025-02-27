#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# exif-test.pl
# A test of the Image::EXIF module.
# Edit history:
#    Thu Jun 25, 2015: Wrote it.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
no warnings 'uninitialized';
use utf8;

use Image::EXIF;
use Data::Dumper;

say "\$ARGV[0] = $ARGV[0]";

my $exif = Image::EXIF->new;
$exif->file_name($ARGV[0]);

my $image_info = $exif->get_image_info(); # hash reference
#my $camera_info = $exif->get_camera_info(); # hash reference
my $other_info = $exif->get_other_info(); # hash reference
#my $point_shoot_info = $exif->get_point_shoot_info(); # hash reference
#my $unknown_info = $exif->get_unknown_info(); # hash reference
my $all_info = $exif->get_all_info(); # hash reference
#print Dumper($all_info);

my $Width;

if (defined $all_info)
{
   $Width = $all_info->{'image'}->{'Image Width'};
   say "Image Width from all_info->image = $Width";
   $Width = $all_info->{'other'}->{'Image Width'};
   say "Image Width from all_info->other = $Width";
}

if (defined $image_info)
{
   $Width = $image_info->{'Image Width'};
   say "Image Width from image_info = $Width";
}

if (defined $other_info)
{
   $Width = $other_info->{'Image Width'};
   say "Image Width from other_info = $Width";
}


