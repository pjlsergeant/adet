
# adet - App::Docker::ECS::Tools

Control local containers and ECS deployments from a central YAML file

## compose

Writes a `docker-compose` file from the YAML input and then runs it

## deploy_service

Runs `register-task-definition` and `update_service`

## images

`push`, `build`, and `pull` docker images


## login

Login to ECS Docker repo

# LICENSE AND COPYRIGHT

This repository contains code originally written for Broadbean Technology
by Peter Sergeant. That code was approved for release and [merged on 16 Jun
2020](https://github.com/pjlsergeant/adet/pull/1).

This code is released under [the same terms](https://dev.perl.org/licenses/)
as Perl itself.
