package App::adet::Test::UI;

use strict;
use warnings;

sub new     { bless { verbose => 1, calls => [] }, $_[0] }
sub verbose { $_[0]->{'verbose'} = $_[1] if defined $_[1]; $_[0]->{'verbose'} }
sub calls   { $_[0]->{'calls'} }

for my $method (
    qw/usage_text note info diag
    exit_error_runtime exit_error_options exit_good_shutdown/
  )
{
    no strict 'refs';
    *{ __PACKAGE__ . "::$method" } = sub {
        my $self = shift;
        push( @{ $self->{'calls'} }, [ $method, @_ ] );
        return 1;
    };
}

1;
