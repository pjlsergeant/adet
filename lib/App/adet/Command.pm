package App::adet::Command;

use Moo;

has 'arguments'  => ( is => 'ro', required => 1 );
has 'options'  => ( is => 'ro', required => 1 );
has 'env'      => ( is => 'ro', required => 1 );
has 'project'  => ( is => 'ro', required => 1 );
has 'usage_cb' => ( is => 'ro', required => 1 );
has 'log_cb'   => ( is => 'ro', required => 1 );

sub accepts_arguments {0}

sub new_and_run {
    my $class = shift;
    my $self = $class->new( @_ );
    $self->run();
}

1;
