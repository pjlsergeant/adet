
# adet - Drive docker, docker-compose, and aws ecs from one config

`adet` attempts to provide maximum DWIM for projects using docker, Docker
Compose and AWS ECS from YAML configuration files. It supports the three
projects I'm working on nicely, each one of which has several component
Docker images organized into tasks and services, and deployed on ECS.

## Synopsis

### Login

Config:

    version: 0.01
    registry: 012345678901.dkr.ecr.eu-west-1.amazonaws.com
    defaults:
      aws_profile: osc

Allows:

    $ adet login https://012345678901.dkr.ecr.eu-west-1.amazonaws.com
    Logging into 012345678901.dkr.ecr.eu-west-1 as osc
    Login Succeeded

### Images

Config:

    images:
        myImage:
            repository    : myImageB
            context       : ./
            dockerfile    : ./Dockerfile
            build_requires:
                - MYENVVAR
Allows:

    $ adet images build myImageB

Or:

    $ adet images pull myImageB

And:

    $ adet images push myImageB

### Tasks

Config:

    tasks:
        myImageT:
            image: myImageB
            environment:
                - name: foobar
                  value: baz1
            dev_mount:
                - ./:/opt/mycode
                - /some/path:/opt/path
        ports:
            - 3000:5000

Allows:

    $ adet compose [any command docker-compose accepts]

With the addition of:

    $ adet compose shell myImageT

### Services

Config:

    services:
        myService:
            task: myImageT
            desired: 2

Allows:

    $ adet deploy_service myService

# LICENSE AND COPYRIGHT

This repository contains code originally written for Broadbean Technology
by Peter Sergeant. That code was approved for release and [merged on 16 Jun
2020](https://github.com/pjlsergeant/adet/pull/1).

This code is released under [the same terms](https://dev.perl.org/licenses/)
as Perl itself.
