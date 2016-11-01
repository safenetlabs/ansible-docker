#!/usr/bin/env sh
if [ -n "$ANSIBLE_VAULT_PASSWORD" ]; then
  echo $ANSIBLE_VAULT_PASSWORD >> /tmp/.tmp_vault_pass
  export ANSIBLE_VAULT_PASSWORD_FILE=/tmp/.tmp_vault_pass
fi

cmd="$@"

case "$1" in
  sh)
    cmd="sh"
    ;;
  ansible|ansible-*)
    ;;
  console|playbook|doc|pull|galaxy|vault)
    cmd="ansible-$@"
    ;;
  *)
    cmd="ansible $@"
    ;;
esac


exec $cmd