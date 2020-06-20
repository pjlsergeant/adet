package App::adet::ProjectConfig;

use strict;
use warnings;

use base 'Class::ConfigHash';
use YAML qw/LoadFile/;

sub _new_from_file {
    my ( $class, $filename ) = @_;

    # We could use -f but who knows how well that'll work. Try and actually
    # open it for reading. Slightly wasteful, but it gives us a little more
    # control over the error message coming out
    {
        open( my $fh, '<', $filename ) ||
            die "Couldn't open projectfile [$filename] for reading: $!\n";
        close $fh;
    }

    # Now let's try and parse it
    my $data = eval { LoadFile($filename) };
    unless ( $data ) {
        my $error = $@;
        $error =~ s/^ at .+ line \d+\.$//m;
        die "Failed to parse projectfile [$filename]: $error";
    }

    my $self = $class->_new($data);
    die "Only know how to parse 0.01" unless $self->version eq '0.01';
    return $self;
}

1;
