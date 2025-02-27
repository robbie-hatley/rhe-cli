#!/usr/bin/perl

use v5.32;
no strict;
no warnings;

*main::pi = \3.1415926535;

say ( "pi SCALAR = ", ${*main::pi{SCALAR}} ) if defined *main::pi{SCALAR};
say ( "pi ARRAY  = ", @{*main::pi{ARRAY} } ) if defined *main::pi{ARRAY};
say ( "pi HASH   = ", %{*main::pi{HASH}  } ) if defined *main::pi{HASH};
say ( "pi CODE   = ", &{*main::pi{CODE}  } ) if defined *main::pi{CODE};

*main::e = sub(){2.71828182845905};

say ( "e SCALAR  = ", ${*main::e{SCALAR} } ) if defined *main::e{SCALAR};
say ( "e ARRAY   = ", @{*main::e{ARRAY}  } ) if defined *main::e{ARRAY};
say ( "e HASH    = ", %{*main::e{HASH}   } ) if defined *main::e{HASH};
say ( "e CODE    = ", &{*main::e{CODE}   } ) if defined *main::e{CODE};

say ( "pi * e = ", $pi * &e );
