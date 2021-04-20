package App::adet::Command::Version;

use strict;
use warnings;

use base 'App::adet::Command';
use App::adet;

sub skip_project_file { 1 }
sub options {[]}

sub run {
    my ( $self, $runtime ) = @_;
    $runtime->ui->exit_good_shutdown($App::adet::VERSION);
}

1;