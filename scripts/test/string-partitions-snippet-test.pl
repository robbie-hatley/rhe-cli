



sub string_partitions ($string)
{
   my @partitions;
   my $size = length($string);
   if ( 1 == $size )
   {
      @partitions = ([$string]);
   }
   else
   {
      for ( my $part = 1 ; $part <= $size ; ++$part )
      {
         my $first  = substr($string, 0,     $part        );
         my $second = substr($string, $part, $size - $part);
         @partitions = string_partitions($second);
         for (@partitions) {unshift @$_, $first;}
      }
   }
   return @partitions;
}



