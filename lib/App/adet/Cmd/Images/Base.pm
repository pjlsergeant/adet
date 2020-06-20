package App::adet::Cmd::Images::Base;

use Moo;
use MooX::Cmd;
use MooX::Options;

with 'App::adet::ProjectConfig::File';
with 'App::adet::OptionOrDefault';

sub resolve_images {
    my ( $self, $names ) = @_;
    $self->options_usage( 1, "You need to specify at least one image name" )
        unless @$names;

    my $config = $self->project_config;

    if ( grep { $_ eq ':all' } @$names ) {
        $self->options_usage( 1,
            "`:all` must be the only image listed if used" )
            if @$names != 1;
        $names = [ sort keys %{ $config->images( { raw => 1 } ) } ];
    }

    my @result;

    for my $name (@$names) {
        push( @result, [ $name, $config->images->$name ] );
    }

    return \@result;
}

1;
