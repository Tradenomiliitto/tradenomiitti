#!/bin/bash

if [[ ! -f conf/inventory.ini ]]
then
  for env in dev
  do
    sed -e "s/@ENV@/$env/" conf/inventory-template.ini >> conf/inventory.ini
  done
fi

ansible-galaxy install weareinteractive.pm2 --roles-path conf/roles
