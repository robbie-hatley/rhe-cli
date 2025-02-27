   sub ones
   {
      return 'no input in ones'        if @_ < 1;
      return 'excess input in ones'    if @_ > 1;
      my $digit = shift;
      return 'non-digit input in ones' if $digit !~ m/^\d$/;
      return $ones[$digit];
   }

   sub tens
   {
      return 'no input in tens'        if @_ < 1;
      return 'excess input in tens'    if @_ > 1;
      my $digit = shift;
      return 'non-digit input in tens' if $digit !~ m/^\d$/;
      return $tens[$digit];
   }

   sub hundreds
   {
      return 'no input in hundreds'     if @_ < 1;
      return 'excess input in hundreds' if @_ > 1;
      my $digit = shift;
      return 'input error in hundreds'  if $digit !~ m/^\d$/;
      return $hundreds[$digit];
   }
