#!perl

#
# Docker login commands that are aware of the AWS version.
#

package App::adet::Cmd::Login;

use Moo;
use MooX::Cmd;
use MooX::Options;

with 'App::adet::ProjectConfig::File';
with 'App::adet::OptionOrDefault';

sub execute {
    my ( $self, $args, $chain ) = @_;

    my $aws_profile = $self->value('aws_profile');
    my $aws_cli     = $self->value('aws_cli') // 'aws';

    my $raw_version = `$aws_cli --version`;
    my ($big_version) = $raw_version =~ m!^aws-cli/(\d+)\.!;
    die "Unknown version: [$raw_version]"
        unless $big_version == 1 || $big_version == 2;

    my $registry = $self->project_config->registry;
    my ($region) = $registry =~ m/\d+\.dkr\.ecr\.(.+)\.amazonaws\.com/;
    die "Unknown region from registry [$registry]" unless $region;

    my $login_command;
    my $print_command;

    # AWS v1 has 'get-login', which returns a full docker CLI to run
    if ( $big_version == 1 ) {
        my $interim
            = "$aws_cli ecr get-login"
            . " --region $region"
            . " --profile $aws_profile"
            . " --no-include-email";
        $login_command = `$interim`;
        chomp($login_command);

        $print_command = $login_command;
        $print_command =~ s/ -p [^ ]+/ -p 🔑/;
    }

    # AWS v2 generates a password, that you need to then pipe into docker
    elsif ( $big_version == 2 ) {
        $login_command
            = "$aws_cli ecr get-login-password"
            . "   --region $region"
            . "   --profile $aws_profile "
            . "| docker login --username AWS --password-stdin "
            . "   https://$registry";
        $print_command = $login_command;
        $print_command =~ s/ +/ /g;
    }
    else {
        die "Unknown version";
    }

    print "$print_command\n";
    exec $login_command;

}

1;
