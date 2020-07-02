package App::adet::Env;

use strict;
use warnings;

use base 'App::adet::OptionHash';

sub new_from_hash {
    my ( $class, $source, $hash ) = @_;
    my $self = $class->new();
    $self->{"_$_"}->{$source} = $hash->{$_} for keys %$hash;
    return $self;
}

1;
