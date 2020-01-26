#!/bin/bash

cd $(git rev-parse --show-toplevel)

if [[ ! -f conf/inventory.ini ]]
then
  for env in dev qa prod
  do
    sed -e "s/@ENV@/$env/" conf/inventory-template.ini >> conf/inventory.ini
  done
fi

ansible-galaxy install nickjj.letsencrypt,v0.3.1 --force --roles-path conf/roles
