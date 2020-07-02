package App::adet::OptionHash;

use strict;
use warnings;

# Generalized way of combining hash values with a precendence from many places
# Precedence: cmdline, env, projectfile, profile, default

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub add_value {
    my ( $self, $name, $source, $value ) = @_;
    $self->{"_$name"} ||= {};
    die "Unknown option source: $source"
        unless ( $source eq 'cmdline'
        || $source eq 'env'
        || $source eq 'projectfile'
        || $source eq 'profile'
        || $source eq 'default' );
    die "Already have a value from $source"
        if defined $self->{$source};
    $self->{"_$name"}->{$source} = $value;
    return undef;
}

sub value {
    my ( $self, $name ) = @_;
    my $value = $self->{"_$name"} // return undef;
    return $value->{'cmdline'} // $value->{'env'} // $value->{'projectfile'}
        // $value->{'profile'} // $value->{'default'};
}

sub source {
    my ( $self, $name ) = @_;
    my $value = $self->{"_$name"} // return undef;
    return 'cmdline'     if defined $value->{'cmdline'};
    return 'env'         if defined $value->{'env'};
    return 'projectfile' if defined $value->{'projectfile'};
    return 'profile'     if defined $value->{'profile'};
    return 'default'     if defined $value->{'default'};
    return undef;
}

sub source_value {
    my ( $self, $name, $source ) = @_;
    return undef unless $self->{"_$name"};
    return $self->{"_$name"}->{$source};
}

1;
