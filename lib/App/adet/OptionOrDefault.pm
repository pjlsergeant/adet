package App::adet::OptionOrDefault;

use Moo::Role;
use strictures 2;

requires 'project_config';

sub value {
    my ($self, $option) = @_;

    if ( my $value = $self->__find_in_command_chain( $option ) ) {
        return $value
    }

    my $defaults = $self->project_config->defaults({ allow_undef => 1 });
    return undef unless $defaults;

    return $defaults->$option({ allow_undef => 1 });
}

sub __find_in_command_chain {
    my ( $self, $option ) = @_;

    for my $chain ( reverse @{$self->command_chain} ) {
        if ( $chain->can( $option ) ) {
            return $chain->$option;
        }
    }

    return undef;
}

1;