package App::adet::Command::Login;

use strict;
use warnings;

use base 'App::adet::Command';
use App::adet;

sub run {
    my ( $self, $runtime ) = @_;
    $runtime->ui->exit_good_shutdown("IM LOGGING IN");
}

1;