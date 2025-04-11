package Artiodactyla::Camelini 1.001;
use parent qw(Exporter);

# Symbols to be exported by default:
our @EXPORT = qw(camel);

# Symbols to be exported on request:
our @EXPORT_OK = qw($weight);

# Include your variables and functions here:
sub camel { "one–hump dromedary" }
$weight = 1024;

# End with an expression that evaluates to true:
1;
