package App::adet::ProjectConfig::File;

use Moo::Role;
use strictures 2;
use App::adet::ProjectConfig;

has 'project_config' => ( is => 'lazy' );

sub _build_project_config {
    my $self = shift;

    return App::adet::ProjectConfig->_new_from_file(
        $self->__find_project_file
    );
}

sub __find_project_file {
    my $self = shift;

    my $file = $self->command_chain->[0]->projectfile || # Via cmd-line option
        $ENV{'ADET_PROJECTFILE'} ||                      # Via ENV
        $self->__traverse;                               # Traverse directory

    return $file
        || die "You didn't specify a projectfile, and we can't find one\n";
}

sub __traverse {
    # JUST NO.
    return './adet.yaml' if -f './adet.yaml';
}

1;
