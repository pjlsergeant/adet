package App::adet::Commands;

use strict;
use warnings;

## PARTS OF THIS NEED TO BECOME AUTO_GENERATED



# A list of all commands and what arguments they take. The arguments they take
# matching what's in here is kept consistent via tests. This gets loaded every
# time so it should be kept very quick

# hashref is sub-command, arrayref is command details

# START
our $commands = {
          'login' => [
                       'App::adet::Command::Login',
                       [
                         'projectfile',
                         'verbose',
                         'quiet',
                         'version'
                       ]
                     ],
          'version' => [
                         'App::adet::Command::Version',
                         []
                       ]
        };

our $options = [
          [
            'projectfile',
            'projectfile|f=s'
          ],
          [
            'verbose',
            'verbose|v'
          ],
          [
            'quiet',
            'quiet|q'
          ],
          [
            'version',
            'version|V'
          ]
        ];

# END

our $options_by_class = { map { @$_ } values %$commands};

1;
