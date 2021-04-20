package App::adet::Runtime::CmdAndArgs;

use strict;
use warnings;

use Module::Runtime qw/require_module/;
use App::adet::Commands;

sub cmd     { $_[0]->{'cmd'} }
sub cmdname { $_[0]->{'cmdname'} }
sub args    { $_[0]->{'args'} }

sub new {
    my ( $class, %options ) = @_;
    my $allargs = $options{'allargs'} || die "need allargs";
    my $ui      = $options{'ui'}      || die "need ui";

    my $self = bless {
        cmd     => undef,
        cmdname => 'adet',
        args    => [],
    }, $class;

    my @command_args = @{ $options{'allargs'} };
    return $ui->exit_error_options("No command specified")
      unless @command_args;

    my $command      = [];
    my $command_tree = $App::adet::Commands::commands;

    while ( my $subcommand = shift(@command_args) ) {
        $self->{'cmdname'} .= " $subcommand";
        my $result = $command_tree->{$subcommand};
        if ( ref $result eq 'ARRAY' ) {
            $self->{'cmd'} = $result->[0];
            require_module $self->{'cmd'};
            $self->{'args'} = \@command_args;
            return $self;

        }
        elsif ( ref $result eq 'HASH' ) {
            next;

        }
        else {
            return $ui->exit_error_options(
                "Can't find command: [" . $self->{'cmdname'} . "]" );
        }
    }

    return $ui->exit_error_options(
        "[" . $self->{'cmdname'} . "] needs a subcommand" );
}

1;
