package App::adet::Cmd::Images::Cmd::Pull;

use Moo;
extends 'App::adet::Cmd::Images::Base';

sub execute {
    my ( $self, $args ) = @_;

    my $images = $self->resolve_images($args);

    for (@$images) {
        my ( $name, $config ) = @$_;

        my $repo = sprintf( '%s/%s:%s',
            $self->project_config->registry,
            $config->repository, 'latest' );

        my @pull_cmd = ( qw/docker pull/, $repo );
        print "[$name] Running pull:\n" . ( join ' ', @pull_cmd ) . "\n";
        system(@pull_cmd) && die "Build failed\n";

        my @tag_cmd
            = ( qw/docker tag/, $repo, $config->repository . ':latest' );
        print "[$name] Running tag:\n" . ( join ' ', @tag_cmd ) . "\n";
        system(@tag_cmd) && die "Build failed\n";
    }

}

1;