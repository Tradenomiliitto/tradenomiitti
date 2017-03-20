#!/bin/bash

cd $(git rev-parse --show-toplevel)

set -e # exit on error

ansible-playbook conf/bootstrap.yml -i conf/inventory.ini --limit ${ENV_TO_DEPLOY:-dev}
ansible-playbook conf/letsencrypt.yml -i conf/inventory.ini --limit ${ENV_TO_DEPLOY:-dev}
ansible-playbook conf/baseinstall.yml -i conf/inventory.ini --limit ${ENV_TO_DEPLOY:-dev}
