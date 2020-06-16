package DockerConfig;

use strict;
use warnings;
use YAML qw/LoadFile/;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw($config);

our $config = LoadFile('docker/peter.yaml');

1;