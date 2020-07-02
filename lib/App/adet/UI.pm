package App::adet::UI;

use Moo;
use App::adet::Options;

has 'options'   => ( is => 'ro', required => 1 );
has 'env'       => ( is => 'ro', required => 1 );
has 'command'   => ( is => 'ro', required => 1 );
has 'arguments' => ( is => 'ro', required => 1 );

# Possible we'll also have found this out, but not guaranteed
has 'command_class' => ( is => 'ro' );

sub log       { my ( $level, $message ) = @_; }
sub terminate { my ( $code,  $why )     = @_; }

sub usage_callback {
    my $class = shift;
    return sub { $class->usage(@_) };
}

sub log_callback {
    my $class = shift;
    return sub { $class->log(@_) };
}

sub parse_env_and_defaults {
    my ( $class, $options, $env ) = @_;

    while ( my ( $name, $data ) = each %App::adet::Options::all_options ) {
        if ( exists $data->{'from_env'} ) {
            my $key = $data->{'from_env'};
            if ( exists $env->{$key} ) {
                $options->add_value( $name, 'env', $env->{$key} );
            }
        }
        if ( exists $data->{'default'} ) {
            $options->add_value( $name, 'default', $data->{'default'} );
        }
    }

    return undef;
}

1;
