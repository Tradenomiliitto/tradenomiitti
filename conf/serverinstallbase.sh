#!/bin/bash

cd $(git rev-parse --show-toplevel)

./conf/preinstall.sh

ansible-playbook conf/baseinstall.yml -i conf/inventory.ini
