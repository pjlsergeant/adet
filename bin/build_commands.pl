#!/usr/bin/env perl

use strict;
use warnings;
use Module::Runtime qw/require_module/;
use Data::Dumper;
use Path::Class qw/file/;

use lib 'lib';

# Add new commands here and the script will do the rest
my @commands = (
    sc('version'),
    sc('login'),
    #sc('images/build')
);

sub sc {
    my $c = shift;
    my @parts = split(q!/!, $c);
    my @mods = map { ucfirst( $_ ) } @parts;
    return [
        \@parts,
        'App::adet::Command::' . join '::', @mods
    ];
}

my $command_tree = {};
my %seen_options;
my @all_options;

for my $command ( @commands ) {
    my $cursor = $command_tree;
    my @parts = @{ $command->[0] };

    while ( @parts > 1 ) {
        my $this = shift( @parts );
        $cursor = ($cursor->{ $this } ||= {});
    }

    require_module( $command->[1] );

    my $def = $cursor->{ $parts[0] } = [ $command->[1] ];
    my @this_args;

    for ( @{ $command->[1]->options } ) {
        my ( $name, $from, $args ) = @$_;
        push( @this_args, $name );

        if ( my $classname = $seen_options{$name} ) {
            if ( $from ne $classname ) {
                die "$name defined in $from and $classname";
            }
            next;
        } else {
            push( @all_options, [ $name, $args ] );
            $seen_options{$name} = $from;
        }
    }

    push( @$def, \@this_args );
}

my $dumped = Dumper( $command_tree );
$dumped =~ s/^\$VAR1/our \$commands/;

my $options = Dumper( \@all_options );
$options =~ s/^\$VAR1/our \$options/;

my $file = file('lib/App/adet/Commands.pm');
my $content = $file->slurp;
$content =~ s/(# START\n).+(\n# END\n)/$1$dumped\n$options$2/s;
$file->spew( $content );
