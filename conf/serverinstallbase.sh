#!/bin/bash

cd $(git rev-parse --show-toplevel)

ansible-playbook conf/baseinstall.yml -i conf/inventory.ini
ansible-playbook conf/letsencrypt.yml -i conf/inventory.ini
