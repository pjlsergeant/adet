package App::adet;
use Moo;
use MooX::Cmd;
use MooX::Options;

option 'projectfile' => (
    short   => 'f',
    is      => 'ro',
    format  => 's',
    doc     => 'Location of the project file',
    default => undef,
);

option 'aws_profile' => (
    short  => 'a',
    is     => 'ro',
    format => 's',
    doc    => 'AWS Profile',
);

sub execute {
    my ( $self, $args ) = @_;
    my $arg = $args->[0];
    my $pre_message = $arg ? "Unknown subcommand [$arg]" : "Please specify a subcommand";
    $self->options_usage(1, $pre_message);
}

1;
