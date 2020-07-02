package App::adet::UI::cmdline;

use Moo;
extends 'App::adet::UI';

use App::adet::Commands;
use App::adet::Options;
use App::adet::Env;

use Getopt::Long qw(GetOptionsFromArray);

# Each of these need to be in App::adet::Options
our @getopt_configuration = ( [ projectfile => 'projectfile|p=s' ], );

# These are local options we'll deal with locally...
our @getopt_local = ( [ help => 'help|h' ], [ version => 'version|V' ], );

sub create {
    my ( $class, $argv, $env ) = @_;

    my $options     = App::adet::Options->new();
    my $env_options = App::adet::Env->new_from_hash( env => $env );

    # Parses options into $options, but also returns extras as the command
    my $command_raw = $class->parse_cmdline( $options, $argv );

    # Add any ENV values or defaults
    $class->parse_env_and_defaults( $options, $env );

    my ( $command_class, $command_name, $command_args )
        = App::adet::Commands->find_command( $command_raw,
        $class->usage_callback );

    return $class->new(
        options       => $options,
        env           => $env_options,
        command       => $command_name,
        arguments     => $command_args,
        command_class => $command_class,
    );
}

sub parse_cmdline {
    my ( $class, $options, $argv ) = @_;

    # Take a shallow copy as we'll mutate this
    $argv = [@$argv];

    # Build up what we want to pass to GetOpt::Long
    my @getopt_options;
    for ( @getopt_configuration, @getopt_local ) {
        my ( $name, $data ) = @$_;
        push( @getopt_options, $data );
    }

    # Capture errors from GetOpt::Long
    my @errors;
    local $SIG{__WARN__} = sub { push( @errors, @_ ) };

    # Do the parsing itself
    my %found;
    Getopt::Long::Configure(qw/no_auto_abbrev no_ignore_case/);
    unless ( GetOptionsFromArray( $argv, \%found, @getopt_options ) ) {
        chomp(@errors);
        $class->usage(@errors);
    }

    # Short-circuit usage and version
    $class->usage   if $found{'help'};
    $class->version if $found{'version'};

    # Add what we found to $options
    while ( my ( $k, $v ) = each %found ) {
        $options->add_value( $k, 'cmdline', $v );
    }

    # Unprocessed command-line arguments that are the command itself
    return $argv;
}

sub version {
    my $class = shift;
    print $App::adet::VERSION . "\n";
    $class->my_exit(0);
}

sub log {
    my ($class, $level, $message) = @_;
    print "$level: $message\n";
}

sub usage {
    my ( $class, @errors ) = @_;
    if (@errors) {
        select(STDERR);
        print "$_\n" for @errors;
    }

    print "USAGE INFO\n";

    $class->my_exit( !!@errors );
}

sub my_exit { exit( $_[1] ) }

1;
