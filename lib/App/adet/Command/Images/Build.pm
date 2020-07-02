package App::adet::Command::Images::Build;

use Moo;
extends 'App::adet::Command::Images';

use Path::Class qw/dir file/;
use Cwd::Guard qw/cwd_guard/;

sub accepts_arguments {1}

# aws configure get aws_access_key_id --profile osc

sub run {
    my $self   = shift;
    my $images = $self->process_image_list();

    # Check we have all the build_requires env pieces we need
    my %build_env;
    for (@$images) {
        my ( $name, $config ) = @$_;
        my $requires = $config->build_requires( { default => [] } );
        for my $e (@$requires) {
            my $value = $self->env->value($e);
            unless ( defined $value ) {
                $self->usage_cb->(
                    sprintf(
                        "Building image %s requires env %s to be set; "
                            . "you can set this using --env, in the actual ENV, "
                            . "or in the buildenv section of the projectfile",
                        $name, $e
                    )
                );

            }
            $build_env{$e} = $value;
        }
    }

    # Docker build_image
    my ( $build_target, $tag_target );
    my $target = $self->options->value('target');
    if ( defined $target ) {
        my $target_config = $self->project->targets->$target;
        ( $build_target, $tag_target )
            = @{$target_config}{qw/build_target tag_as/};
    }
    else {
        $tag_target = 'latest';
    }

    # Now run Docker build for each
    for (@$images) {
        my ( $name, $image_config ) = @$_;

        my $repository = $image_config->repository( { default => $name } );
        my $full_tag   = "$repository:$tag_target";

        my $description = "[$full_tag]";
        if ( $repository ne $name ) {
            $description = "$name $description";
        }
        if ( defined $build_target ) {
            $description = "$description ($build_target)";
        }

        my $context = dir( $image_config->context( { default => './' } ) );

        print "Building $description in $context\n";

        # Work out where the dockerfile is
        my $dockerfile_abs = file( $image_config->{'dockerfile'} );
        my $dockerfile_rel = $dockerfile_abs->relative($context);

        # Actually change directory
        my $guard = cwd_guard($context)
            or die "failed chdir: $Cwd::Guard::Error";

        # Start building up a runnable docker command
        my @docker_cmd = qw/docker build/;
        push( @docker_cmd, '-f',       $dockerfile_rel );
        push( @docker_cmd, '--target', $build_target )
            if defined $build_target;
        push( @docker_cmd, '-t', $full_tag );

        for my $e ( sort keys %build_env ) {
            push( @docker_cmd, '--build-arg', "$e=$build_env{$e}" );
        }
        push( @docker_cmd, '.' );

        print "Running:\n" . ( join ' ', @docker_cmd ) . "\n";
        system(@docker_cmd) && die "Build failed";
    }

}

1;

__DATA__
# with 'App::adet::Cmd::Images::Resolve';
# with 'App::adet::ProjectConfig::File';

# option 'env'    => ( is => 'rw', format => 's%', default  => sub { [] } );
# option 'target' => ( is => 'rw', format => 's',  required => 1 );
# option 'profile' => ( is => 'rw', format => 's' );

# with 'App::adet::ReadAWSCreds';

# has 'expanded_env' => ( is => 'lazy' );

sub _build_expanded_env {
    my $self = shift;

    my %from_command_line = %{ $self->env };

    my %from_config = %{
        $self->project_config->defaults->env(
            { allow_undef => 1, raw => 1 }
            )
            || {}
    };

    my $all
        = { %from_config, %ENV, %{ $self->cred_hash }, %from_command_line };

    return $all;

    # use Data::Printer; p %from_command_line; die;
}

# Look for required ENVs in:
#   - cmd-line options
#   - actual ENV
#   - config file
#   - via AWS config
sub find_env {
    my ( $self, $name, $why ) = @_;

    my $value = $self->expanded_env->{$name};
    unless ($value) {
        my $msg = sprintf( '%s needs to be set via --env or in \$ENV for %s',
            $name, $why );
        if ( $name =~ m/AWS_/ ) {
            $msg
                .= sprintf(
                "\nYou can specify --profile [pname] to read these from .aws/credentials"
                );
        }
        die $msg . "\n";
    }
}

sub execute {
    my ( $self, @args ) = @_;

    $self->expanded_env;
    my $images = $self->images();

    use Data::Printer; p @args;

    # Check we have all the arguments we need
    my %build_args;
    for (@$images) {
        my ( $name, $config ) = @$_;
        my $requires = $config->build_requires;
        for my $e ( to_array($requires) ) {
            $build_args{$e} = $self->find_env( $e, 'image:' . $name );
        }
    }

    # Docker build_image
    my $target        = $self->target;
    my $target_config = $self->project_config->targets->$target;
    my ( $build_target, $tag_target )
        = @{$target_config}{qw/build_target tag_as/};

    # Now run Docker build for each
    for (@$images) {
        my ( $name, $image_config ) = @$_;
        print "Building [$name:$tag_target#$build_target] in "
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

sub to_array {
    my $item = shift;
    return @$item  if ( ref $item ) eq 'ARRAY';
    return ($item) if defined $item;
    return ();
}

1;
