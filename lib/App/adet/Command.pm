package App::adet::Command;

use strict;
use warnings;

our @options = (
    [ projectfile   => 'projectfile|f=s' ],
    [ verbose       => 'verbose|v' ],
    [ quiet         => 'quiet|q' ],
    [ version       => 'version|V' ],
);

sub is_command { 0 } # 1 if it's a command, 0 if it's a basefile
sub skip_project_file { 0 } # needs the project file?

# This is pretty nasty, but also note that it should only ever be run as part
# of generating App::adet::Commands, rather than by any real users
sub options {
    my $self = shift;

    my @collected;
    my %seen;

    my $from = $self;
    while ( $from ) {
        my @items = eval '@' . $from . '::options';
        for my $item (reverse @items) {
            my ( $name, $args ) = @$item;
            if ( $seen{ $name } ) {
                die "[$name] defined in both [$from] and [" . $seen{ $name } . "]";
            } else {
                $seen{ $name } = $from;
            }
            unshift( @collected, [ $name, $from, $args ] );
        }
        if ( my @parents = eval '@' . $from . '::ISA' ) {
            die "Didn't expect multiple inheritance from $from"
                if @parents > 1;
            last unless @parents;
            $from = $parents[0];
        } else {
            last;
        }
    }

    return \@collected;
}



1;