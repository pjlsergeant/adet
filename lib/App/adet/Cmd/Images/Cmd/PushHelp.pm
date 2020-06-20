package App::adet::Cmd::Images::Cmd::PushHelp;

use Moo;
extends 'App::adet::Cmd::Images::Base';

sub execute {
    my ( $self, $args ) = @_;

    my $images = $self->resolve_images($args);
    my $registry = $self->project_config->registry;

    # Print the main doc and point out we won't do anything
    print (join '', <DATA>);

    my @to_push;
    print "Tag:\n";
    for (@$images) {
        my ( $name, $config ) = @$_;

        my $repository = $config->repository;
        my @docker_cmd = ( qw/docker tag/, "$repository:latest" );

        for ( [ 'latest build', 'latest' ], ) {
            my ( $description, $tag_part ) = @$_;
            my $remote_tag = "$registry/$repository:$tag_part";
            print "\t" . ( join ' ', ( @docker_cmd, $remote_tag ) ) . "\n";
            push( @to_push, $remote_tag );
        }
    }

    print "Push:\n";
    for (@to_push) {
        print "\t" . ( join ' ', ( 'docker', 'push', $_ ) ) . "\n";
    }

}

1;

__DATA__
#
# THIS COMMAND ONLY PRINTS COMMANDS FOR YOU TO RUN, AND DOESN'T DO ANYTHING
# BY ITSELF!!
#

The process for pushing images is:

  * Make sure you've already built the image you want, and it's called or
    tagged its repository name (eg: peter-piper). Both the `build` and
    `pull` cmds achieve this

  * Add an additional tag to this image tagging it with the remote repository
    name. The command labelled "tag" below achieves this

  * Run `docker push` to upload it to the repository itself. The command
    labelled "push" below achieves this.

  * You may well want to then deploy this using `adet deploy`

