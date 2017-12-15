#!/bin/bash

cd $(git rev-parse --show-toplevel)

if [[ ! -f conf/inventory.ini ]]
then
  for env in dev qa prod
  do
    sed -e "s/@ENV@/$env/" conf/inventory-template.ini >> conf/inventory.ini
  done
fi

ansible-galaxy install weareinteractive.pm2,2.4.0 --force --roles-path conf/roles
ansible-galaxy install nickjj.letsencrypt,v0.2.2 --force --roles-path conf/roles
