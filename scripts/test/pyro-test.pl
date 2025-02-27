#!/usr/bin/perl

=head1 Synopsis:

This program tests POD.

Synopsises can have multiple paragraphs.

=head2 Description:

This program uses a lot of differnet POD directives,
mixed in with some perl code.

Descriptions can have multiple paragraphs.

=cut


=for html
<p style="font-size: 40pt"> This program tests POD. </p>

=cut

use v5.32;
use strict;
use warnings;

=for html
<p style="font-size: 24pt"> The snazzle() function will behave in the most
spectacular form that you can possibly imagine, not even excepting
cybernetic pyrotechnics. </p>

=cut

sub snazzle
{
   my $arg = shift;
   printf("%lld\n", $arg);
}

=for html
<p style="font-size: 24pt">The razzle() function enables autodidactic
epistemology generation.</p>

=cut

sub razzle
{
   print("Epistemology generation unimplemented on this platform.\n");
}

snazzle 9221585858585858585;
razzle;



