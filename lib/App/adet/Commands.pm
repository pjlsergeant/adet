package App::adet::Commands;

use strict;
use warnings;

our %commands = (
    login  => 'App::adet::Command::Login',
    images => { build => 'App::adet::Command::Images::Build' }
);

sub find_command {
    my ( $class, $command_args, $usage ) = @_;
    my @command_args = @$command_args;
    return $usage->("No command specified") unless @command_args;

    my $command = [];
    my $command_tree = \%commands;

    while ( my $subcommand = shift(@command_args) ) {
        my $result = $command_tree->{$subcommand};
        push( @$command, $subcommand );

        return $usage->("Can't find subcommand $subcommand")
            unless defined $result;
        return ( $result, $command, \@command_args ) unless ref $result;

        $command_tree = $result;
        next;
    }
}

1;
