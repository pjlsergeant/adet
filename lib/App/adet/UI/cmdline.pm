package App::adet::UI::cmdline;

use Moo;

has 'verbose' => ( is => 'rw', default => 1 );

sub usage_text { return "blah blah blah" }

# Debugging info, STDOUT, shown by -v
sub note {
    my ( $self, $msg ) = @_;
    print "$msg\n" if $self->verbose > 0;
}

# General info, STDOUT, hidden by -q
sub info {
    my ( $self, $msg ) = @_;
    print "$msg\n" if $self->verbose > -1;
}

# STDERR, not hidden
sub diag {
    my ( $self, $msg ) = @_;
    print STDERR "$msg\n";
}

# The application encountered an error
sub exit_error_runtime {
    my ( $self, $extra ) = @_;
    $self->diag( $extra ) if defined $extra;
    exit(2);
}

# The application was run incorrectly
sub exit_error_options {
    my ( $self, $extra ) = @_;
    $self->diag( $extra ) if defined $extra;
    $self->diag( $self->usage_text );
    exit(1);
}

# All is good
sub exit_good_shutdown {
    my ( $self, $extra ) = @_;
    $self->info( $extra ) if defined $extra;
    exit(0);
}

1;