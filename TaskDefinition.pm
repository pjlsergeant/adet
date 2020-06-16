package TaskDefinition;

# Produces a JSON file describing a task definition in a temporary file
# for passing to aws cli

use Moose;
use File::Temp qw/tempfile/;
use JSON::XS qw/encode_json/;

has registry       => ( is => 'ro', required => 1 );
has image          => ( is => 'ro', required => 1 );
has container_name => ( is => 'ro', required => 1 );
has family         => ( is => 'ro', required => 1 );
has cpu            => ( is => 'ro', required => 1 );
has memory         => ( is => 'ro', required => 1 );
has ports => ( is => 'ro', isa => 'ArrayRef[Int]', required => 1 );
has environment => ( is => 'ro', isa => 'ArrayRef[HashRef]', required => 1 );
has auth => ( is => 'ro', isa => 'HashRef', default => sub { {} } );

sub write_to_file {
    my $self = shift;

    my $base = {

        # This will be launched on a Fargate instance
        requiresCompatibilities => ['FARGATE'],
        networkMode             => 'awsvpc',
        executionRoleArn =>
            "arn:aws:iam::123456:role/ecsTaskExecutionRole",
        taskRoleArn => "arn:aws:iam::123456:role/ecsTaskExecutionRole",

        # Instance-specific
        family => $self->family,

        # Literally no idea why this is text, but int below
        cpu    => ( '' . $self->cpu ),
        memory => ( '' . $self->memory ),

        containerDefinitions => [
            {   name             => $self->container_name,
                image            => $self->registry . '/' . $self->image,
                logConfiguration => {
                    logDriver => "awslogs",
                    options   => {
                        'awslogs-group'         => "/ecs/" . $self->family,
                        'awslogs-region'        => "eu-west-1",
                        'awslogs-stream-prefix' => "ecs"
                    }
                },
                portMappings => [
                    map {
                        +{  hostPort      => ( 0 + $_ ),
                            containerPort => ( 0 + $_ ),
                            protocol      => 'tcp'
                            }
                    } @{ $self->ports }
                ],

                cpu               => ( 0 + $self->cpu ),
                memory            => ( 0 + $self->memory ),
                memoryReservation => ( 0 + $self->memory ),
                environment       => [
                    @{ $self->environment },
                    map { { name => 'PETER_AUTH_' . uc($_), value => $self->auth->{$_} } }
                        keys %{ $self->auth }
                ],
            },
            ]

    };

    my ( $fh, $filename ) = tempfile();
    print $fh encode_json($base);

    return $filename;
}

1;
