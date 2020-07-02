package App::adet;
use strict;
use warnings;

use Module::Runtime qw/require_module/;
use App::adet::UI;
use App::adet::Commands;
use App::adet::ProjectFile

    our $VERSION = '0.0.1';

sub run {
    my ( $class, $ui ) = @_;

    my $command_class = $ui->command_class;
    unless ($command_class) {
        ($command_class)
            = App::adet::Commands->find_command( $ui->command,
            $ui->usage_callback );
    }

    # Load the command we're targetting
    require_module $command_class;

    # Check it accepts arguments if we have some
    if ( @{ $ui->arguments } && !$command_class->accepts_arguments ) {
        $ui->usage("This subcommand doesn't accept extra arguments");
    }

    # Load in options from project file
    my $project = App::adet::ProjectFile->load(

        # The project file we're trying to load
        $ui->options->value('projectfile'),

        # Where to add options
        $ui->options,

        # Where to add extra envs
        $ui->env
    );

    $command_class->new_and_run(
        arguments => $ui->arguments,
        options   => $ui->options,
        env       => $ui->env,
        project   => $project,
        usage_cb  => $ui->usage_callback,
        log_cb    => $ui->log_callback
    );
}

1;
