sub wrap ($)
{
   my $reversed_line = shift;
   my @words = split /\s+/, $reversed_line;
   my @linelets = ('');
   my $index = 0;
   for my $word (reverse @words)
   {
      # If current substring is empty, just dump $word in substring:
      if (length($linelets[$index]) == 0)
      {
         $linelets[$index] = $word;
      }

      # Else if tacking word on left end of current substring would result
      # in a substring of length 58 or less, do it:
      elsif (length($word) + length(' ') + length($linelets[$index]) <= 78)
      {
         $linelets[$index] = $word . ' ' . $linelets[$index];
      }

      # Else dump word into new substring:
      else
      {
         ++$index;
         $linelets[$index] = $word;
      }
   }

   # Left-pad each max-78 linelet to right-justify in 80 field:
   for (@linelets) {$_ = (' ' x (80 - length($_))) . $_;}

   # Return reference to array of linelets (closure):
   return \@linelets;
} # end sub wrap ()

