package App::adet::Cmd::Images;

#
# Build, pull, and push images
#


use Moo;
use MooX::Cmd;
use MooX::Options;

sub execute {
    my ( $self, $args ) = @_;
    my $arg = $args->[0];
    my $pre_message
        = $arg
        ? "Unknown images subcommand [$arg]"
        : "Please specify an images subcommand";
    $self->options_usage( 1, $pre_message );
}

1;

__DATA__

# use strict;
# use warnings;
# use utf8;
# use Getopt::Mini;
# use Path::Class;
# use YAML qw/LoadFile/;
# use Config::INI::Reader;
# use Cwd::Guard qw/cwd_guard/;

my $config = LoadFile('docker/peter.yaml');
my $profile = $ARGV{'profile'} || 'prod';

# Get the command and images
my ( $cmd, @images ) = to_array( $ARGV{''} );
die "Need to provide a cmd" unless $cmd;
if (@images) {
    for my $image (@images) {
        unless ( $config->{'images'}->{$image} ) {
            die "Unknown image: $image";
        }
    }
}
else {
    @images = keys %{ $config->{'images'} };
}

# Get a consolidated list of runtime arguments from the cmd line and ENV
my %MORE_ENV = ( %ENV, map { split( /=/, $_, 2 ) } to_array( $ARGV{'env'} ) );
$MORE_ENV{'target'} ||= 'prod';

# Do we want to read AWS creds?
my $config_hash = Config::INI::Reader->read_file(
    $ENV{'HOME'} . '/.aws/credentials' );
my $aws = $config_hash->{ $profile }
    || die "Can't find AWS profile [$profile]";
$MORE_ENV{ uc($_) } = $aws->{$_} for keys %$aws;


if ( $cmd eq 'push' ) {
    if ( @images != 1 ) {
        die "Please specify a single image name for the `push` cmd";
    }

    print <<DOC;
The process for pushing images is:

  * Make sure you've already built the image you want, and it's called or
    tagged its repository name (eg: peter-piper). Both the `build` and
    `pull` cmds achieve this

  * Add an additional tag to this image tagging it with the remote repository
    name. The command labelled "tag" below achieves this

  * Run `docker push` to upload it to the repository itself. The command
    labelled "push" below achieves this.

  * You may well want to then deploy this using the `./docker/deploy_service`
    exe

DOC

    # Tag each of our newly-built repos
    my $registry = $config->{'registry'};
    my @to_push;

    for my $image ( sort @images ) {
        my $repository = $config->{'images'}->{$image}->{'repository'};
        print "Tag:\n";

        my @docker_cmd = ( qw/docker tag/, "$repository:latest" );

        for ( [ 'latest build', 'latest' ], ) {
            my ( $description, $tag_part ) = @$_;
            my $remote_tag = "$registry/$repository:$tag_part";
            print "\t" . ( join ' ', ( @docker_cmd, $remote_tag ) ) . "\n";
            push( @to_push, $remote_tag );
        }
    }

    for (@to_push) {
        print "Push:\n";
        print "\t" . ( join ' ', ( 'docker', 'push', $_ ) ) . "\n";
    }
}
elsif ( $cmd eq 'build' ) {
    cmd_build();
}
elsif ( $cmd eq 'pull' ) {
    my $cmd = "./docker/login --profile $profile";
    system( split(/ /, $cmd) ) && die "Failed cmd:\n$cmd\n";

    for my $image (@images) {
        my $repo = sprintf( '%s/%s:%s',
            $config->{'registry'},
            $config->{'images'}->{$image}->{'repository'}, 'latest' );
        my @pull_cmd = ( qw/docker pull/, $repo );
        print "Running pull:\n" . ( join ' ', @pull_cmd ) . "\n";
        system(@pull_cmd) && die "Build failed";

        my @tag_cmd = (
            qw/docker tag/, $repo,
            $config->{'images'}->{$image}->{'repository'} . ':latest'
        );
        print "Running tag:\n" . ( join ' ', @tag_cmd ) . "\n";
        system(@tag_cmd) && die "Build failed";
    }

}
else {
    die "Don't know cmd: $cmd";
}

sub cmd_build {

    # Check we have all the arguments we need
    my %build_args;
    for my $image (@images) {
        my $requires = $config->{'images'}->{$image}->{'build_requires'};
        for my $e ( to_array($requires) ) {
            $build_args{$e} = find_env_or_die( $e, 'image:' . $image );
        }
    }

    # Docker build_image
    my $target        = $MORE_ENV{'target'};
    my $target_config = $config->{'targets'}->{$target}
        || die "Don't know about target $target";
    my ( $build_target, $tag_target )
        = @{$target_config}{qw/build_target tag_as/};

    # Now run Docker build for each
    for my $image (@images) {
        my $image_config = $config->{'images'}->{$image};
        print "Building [$image:$tag_target#$build_target] in "
            . $image_config->{'context'} . "\n";

        # Work out where the dockerfile is
        my $context        = dir( $image_config->{'context'} );
        my $dockerfile_abs = file( $image_config->{'dockerfile'} );
        my $dockerfile_rel = $dockerfile_abs->relative($context);

        # Actually change directory
        my $guard = cwd_guard( $image_config->{'context'} )
            or die "failed chdir: $Cwd::Guard::Error";

        # Start building up a runnable docker command
        my @docker_cmd = qw/docker build/;
        push( @docker_cmd, '-f',       $dockerfile_rel );
        push( @docker_cmd, '--target', $build_target );
        push( @docker_cmd,
            '-t', $image_config->{'repository'} . ":$tag_target" );

        for my $e ( to_array( $image_config->{'build_requires'} ) ) {
            push( @docker_cmd, '--build-arg', "$e=$build_args{$e}" );
        }
        push( @docker_cmd, '.' );

        print "Running:\n" . ( join ' ', @docker_cmd ) . "\n";
        system(@docker_cmd) && die "Build failed";
    }

}

sub find_env_or_die {
    my ( $name, $why ) = @_;
    my $value = $MORE_ENV{$name};
    unless ($value) {
        my $msg = sprintf( '%s needs to be set via --env or in \$ENV for %s',
            $name, $why );
        if ( $name =~ m/AWS_/ ) {
            $msg .= sprintf("\nYou can specify --profile [pname] to read these from .aws/credentials");
        }
        die $msg . "\n";
    }
}

sub to_array {
    my $item = shift;
    return @$item  if ( ref $item ) eq 'ARRAY';
    return ($item) if defined $item;
    return ();
}