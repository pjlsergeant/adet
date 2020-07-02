package App::adet::Options;

use strict;
use warnings;
use base 'App::adet::OptionHash';

# All the options for all commands
our %all_options = (
    projectfile => {
        description => "Location of the projectfile",
        default     => './adet.yaml',
        from_env    => 'ADET_PROJECTFILE',
    },
    aws_cli => {
        description => "Location of the aws",
        default     => 'aws',
    },
    aws_profile => {
        description => "AWS profile to read from AWS creds file",
        default     => 'default',
    },
    # env => {
    #     description => "Pass-through env values",
    #     multiple    => 1,
    # },
);

1;
