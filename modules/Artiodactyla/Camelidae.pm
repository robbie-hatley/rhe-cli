package Artiodactyla::Camelidae 1.001;

sub new {
my( $class, @args ) = @_;
bless {}, $class;
}

sub camel { "one–hump dromedary" }

sub weight { 1024 }

1;
