package App::adet::Runtime;

use Moo;

use App::adet::Commands;
use App::adet::Runtime::OptionsAndAllargs;
use App::adet::Runtime::CmdAndArgs;
use App::adet::Runtime::ProjectFile;

has 'ui'   => ( is => 'ro', handles => [qw/verbose/] );
has 'argv' => ( is => 'ro', required => 1 );
has 'env'  => ( is => 'ro', required => 1 );

has 'options_and_allargs' => ( is => 'lazy', handles => [qw/options allargs/] );

sub _build_options_and_allargs {
    my $self = shift;

    my $obj = App::adet::Runtime::OptionsAndAllargs->new(
        ui   => $self->ui,
        argv => $self->argv,
    );
    $self->verbose( $obj->options->{'verbose'} );
    return $obj;
}

has 'cmd_and_args' => ( is => 'lazy', handles => [qw/cmd cmdname args/] );

sub _build_cmd_and_args {
    my $self = shift;

    App::adet::Runtime::CmdAndArgs->new(
        ui      => $self->ui,
        allargs => $self->allargs,
    );
}

has 'maybe_project_file' => ( is => 'lazy' );

sub _build_maybe_project_file {
    my $self = shift;
    return {} if $self->cmd->skip_project_file;

    my $project_file_name = $self->env->{'ADET_PROJECT_FILE'}
      || $self->options->{'projectfile'};
    unless ($project_file_name) {
        $self->exit_error_options(
"Please specify a project_file in ENV['ADET_PROJECT_FILE'] or with -f"
        );
    }

    App::adet::Runtime::ProjectFile->new(
        ui                => $self->ui,
        project_file_name => $project_file_name,
    );
}

sub run {
    my $self = shift;
    $self->check_options;
    $self->cmd->run( $self );
}

sub check_options {
    my $self = shift;
    my @z = $App::adet::Commands::options_by_class->{ $self->cmd };
    my %allowed = map { $_ => 1 } @{$App::adet::Commands::options_by_class->{ $self->cmd }};
    for my $key ( sort keys %{ $self->options } ) {
        unless ( $allowed{$key} ) {
            $self->ui->exit_error_options(
                "Option [$key] not allowed for [" . $self->cmdname . "]"
            );
        }
    }
}


1;
