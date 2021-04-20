package Test::App::adet;

use strict;
use warnings;


use base qw(Test::Class);
use Test::MockObject;

use App::adet;
use App::adet::Test::UI;

sub test_ui {
    App::adet::Test::UI->new();
}

1;