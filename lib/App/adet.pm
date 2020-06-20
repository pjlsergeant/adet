package App::adet;
use Moo;
use MooX::Cmd;
use MooX::Options;

option 'projectfile' => (
    short   => 'p',
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
    die "Please specify a subcommand";
}

1;
