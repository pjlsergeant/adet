package App::adet::Runtime::OptionsAndAllargs;

use strict;
use warnings;

use App::adet::Commands;

use Getopt::Long qw(GetOptionsFromArray);

our @getopt_configuration = @{ $App::adet::Commands::options };

sub options    { $_[0]->{'options'} }
sub allargs     { $_[0]->{'allargs'} }

sub new {
    my ( $class, %options ) = @_;
    my $argv = $options{'argv'} || die "need argv";
    my $ui   = $options{'ui'}   || die "need ui";

    my $self = bless {
        options   => {},
        allargs    => [@$argv],
    }, $class;

    # Build up what we want to pass to GetOpt::Long
    my @getopt_options;
    for ( @getopt_configuration ) {
        my ( $name, $data ) = @$_;
        push( @getopt_options, $data );
    }

    # Capture errors from GetOpt::Long
    my @errors;
    local $SIG{__WARN__} = sub { push( @errors, @_ ) };

    # Do the parsing itself
    Getopt::Long::Configure(qw/no_auto_abbrev no_ignore_case/);
    unless ( GetOptionsFromArray( $self->{'allargs'}, $self->{'options'}, @getopt_options ) ) {
        chomp(@errors);
        $ui->exit_error_options( join '; ', @errors );
    }

    # Some options are really allargs
    unshift( @{$self->{'allargs'}}, 'version' ) if delete $self->{'options'}->{'version'};
    unshift( @{$self->{'allargs'}}, 'help' ) if delete $self->{'options'}->{'help'};

    # Collapse verbose
    $self->{'options'}->{'verbose'} ||= 0;
    $self->{'options'}->{'verbose'} = -1 if delete $self->{'options'}->{'quiet'};

    return $self;
}

1;
