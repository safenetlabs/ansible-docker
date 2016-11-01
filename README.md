# ansible-docker

Creates a containerized ansible, based on alpine.

Other images are designed to be used as a base image, and built upon.
This image probably could be used that way, but is designed to be usable
as is, by mounting your playbooks into it.

# Usage

Generally, you need to map the current folder into the container, containing
your playbooks and config files.  A typical execution looks like:

    docker run --rm -it -v `pwd`:/work -w /work safenetlabs:ansible <args>
    
This repo contains an example wrapper script you can use, named
`dockerized-ansible.sh`.

By default, the container will execute the `ansible` command, passing
the rest of the args to `ansible`.

If the first argument is `ansible-*` (e.g. `ansible-vault` or 
`ansible-playbook`), that command will be executed:

    docker run --rm -it -v `pwd`:/work -w /work safenetlabs:ansible ansible-vault ...

The first argument can omit the `ansible-` prefix as well:

    docker run --rm -it -v `pwd`:/work -w /work safenetlabs:ansible vault ...
    
Finally, you can open to a shell:

    docker run --rm -it -v `pwd`:/work -w /work safenetlabs:ansible sh
    
# Environment Variables

ANSIBLE_VAULT_PASSWORD: Will be passed to all commands by writing the value
                        to a temp file and setting the 
                        ANSIBLE_VAULT_PASSWORD_FILE environment variable 