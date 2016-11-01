#!/usr/bin/env bash
set -e

# Runs ansible in a docker container.  This mounts the current folder into the container, and runs
# the command from that folder.
# This script will do its best to forward the ssh agent environment from the host into the container.
# Example:
#
#     ./dockerized-ansible.sh ansible-playbook -i hosts/stg site.yml -v --check
#
# Additional docker arguments can be specified with XTRA_DOCKER_ARGS.

SSH_SOCK=docker.machine.ssh.socket.$$

DOCKER_ARGS="--rm -v `pwd`:`pwd` -w `pwd` -e ANSIBLE_VAULT_PASSWORD"

function onexit {
  exitcode=$?
  # Stop the ssh connection.  Only used with docker-machine
  if [ -a "$SSH_SOCK" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME -S $SSH_SOCK -O exit
  fi
  exit $exitcode
}
trap onexit EXIT

# if you're running ssh agent AND docker machine, we need to forward your agent
# into the docker machine
if [ -n "$DOCKER_MACHINE_NAME" ] && [ -n "$SSH_AUTH_SOCK" ]; then
  # ssh into the docker machine in the background, forwarding the local SSH agent
  docker-machine ssh $DOCKER_MACHINE_NAME -A -S $SSH_SOCK -f -n -M tail -f /dev/null
  # ssh into the docker machine again, over the same socket, to capture the file name of the
  # ssh agent socket inside the machine.
  DOCKER_MACHINE_AUTH_SOCK=$(docker-machine ssh $DOCKER_MACHINE_NAME -S $SSH_SOCK echo \$SSH_AUTH_SOCK)
  # the ansible command will mount the docker-machine's agent socket file into the container
  DOCKER_ARGS="$DOCKER_ARGS -e SSH_AUTH_SOCK=/ssh-agent -v $DOCKER_MACHINE_AUTH_SOCK:/ssh-agent"
elif [ -n "$SSH_AUTH_SOCK" ]; then
  # mount your ssh agent socket file into the container
  DOCKER_ARGS="$DOCKER_ARGS -e SSH_AUTH_SOCK=/ssh-agent -v $SSH_AUTH_SOCK:/ssh-agent"
else
  # no ssh agent.  Mount the default key into the container
  # This is only going to succeed if the key is passwordless.
  DOCKER_ARGS="$DOCKER_ARGS -v `echo ~`/.ssh/id_rsa:/root/.ssh/id_rsa"
fi

# if there's a tty, add the interactive options
if [[ -t 1 ]]; then
  DOCKER_ARGS="$DOCKER_ARGS -it"
fi

docker run $DOCKER_ARGS $XTRA_DOCKER_ARGS safenetlabs/ansible:latest $@