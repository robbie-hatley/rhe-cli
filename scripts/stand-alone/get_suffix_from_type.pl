sub get_suffix_from_type ($type) {
   !defined $type and return '.unk'; # $type is undefined
   $type = lc $type;
   $type =~ s%/x(-|.)%/%;
   for ($type) {
      /^video\/msvideo$/                                   and return '.avi'  ;
      /^image\/bmp$/                                       and return '.bmp'  ;
      /^application\/freearc$/                             and return '.arc'  ;
      /^text\/css$/                                        and return '.css'  ;
      /^text\/csv$/                                        and return '.csv'  ;
      /^application\/msword$/                              and return '.doc'  ;
      /^application\/epub+zip$/                            and return '.epub' ;
      /^image\/gif$/                                       and return '.gif'  ;
      /^text\/html$/                                       and return '.html' ;
      /^image\/vnd.microsoft.icon$/                        and return '.ico'  ;
      /^application\/java-archive$/                        and return '.jar'  ;
      /^image\/jpeg$/                                      and return '.jpg'  ;
      /^text\/javascript$/                                 and return '.js'   ;
      /^application\/json$/                                and return '.json' ;
      /^audio\/midi$/                                      and return '.mid'  ;
      /^audio\/mpeg$/                                      and return '.mp3'  ;
      /^video\/mpeg$/                                      and return '.mpg'  ;
      /^video\/mp4$/                                       and return '.mp4'  ;
      /^application\/vnd.oasis.opendocument.presentation$/ and return '.odp'  ;
      /^application\/vnd.oasis.opendocument.spreadsheet$/  and return '.ods'  ;
      /^application\/vnd.oasis.opendocument.text$/         and return '.odt'  ;
      /^audio\/ogg$/                                       and return '.ogg'  ;
      /^font\/otf$/                                        and return '.otf'  ;
      /^image\/png$/                                       and return '.png'  ;
      /^application\/pdf$/                                 and return '.pdf'  ;
      /^application\/httpd-php$/                           and return '.php'  ;
      /^application\/vnd.ms-powerpoint$/                   and return '.ppt'  ;
      /^application\/vnd.rar$/                             and return '.rar'  ;
      /^application\/rtf$/                                 and return '.rtf'  ;
      /^application\/sh$/                                  and return '.sh'   ;
      /^image\/svg+xml$/                                   and return '.svg'  ;
      /^application\/tar$/                                 and return '.tar'  ;
      /^image\/tiff$/                                      and return '.tiff' ;
      /^font\/ttf$/                                        and return '.ttf'  ;
      /^text\/plain$/                                      and return '.txt'  ;
      /^audio\/wav$/                                       and return '.wav'  ;
      /^audio\/webm$/                                      and return '.weba' ;
      /^video\/webm$/                                      and return '.webm' ;
      /^image\/webp$/                                      and return '.webp' ;
      /^application\/vnd.ms-excel$/                        and return '.xls'  ;
      /^text\/xml$/                                        and return '.xml'  ;
      /^application\/vnd.mozilla.xul+xml$/                 and return '.xul'  ;
      /^application\/zip$/                                 and return '.zip'  ;
      /^application\/7z-compressed$/                       and return '.7z'   ;
   }
   return '.unk'; # $type is unknown
} # end sub get_suffix_from_type ($)
