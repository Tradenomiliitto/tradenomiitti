#!/bin/sh

[[ -f conf/inventory.ini ]] && exit 0

for env in dev
do
  sed -e "s/@ENV@/$env/" conf/inventory-template.ini >> conf/inventory.ini
done
