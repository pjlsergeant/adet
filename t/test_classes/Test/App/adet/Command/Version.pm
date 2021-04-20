package Test::App::adet::Command::Version;

use base qw(Test::App::adet);

use Test::MockObject;
use Test::Most;

use App::adet::Runtime;

sub test_simple : Test {
    my $t  = shift;
    my $ui = $t->test_ui;

    my $rt =
      App::adet::Runtime->new( ui => $ui, argv => ['version'], env => {} )->run;
    eq_or_diff(
        $ui->calls,
        [
            [
                exit_good_shutdown => $App::adet::VERSION
            ]
        ],
        "Version run"
    );
}

1;
