#!/bin/bash

export environment="{{ db_environment }}"
export db_user="{{ db_user }}"
export db_password="{{ db_password }}"
export COMMUNICATIONS_KEY="{{ avoine_communications_key }}"
export NON_LOCAL="true"
export TEST_LOGIN="{{ test_login }}"
export COOKIE_SECRET="{{ cookie_secret }}"
export DISABLE_SEBACON="{{ disable_sebacon }}"
export SEBACON_CUSTOMER="{{ sebacon_customer }}"
export SEBACON_USER="{{ sebacon_user }}"
export SEBACON_PASSWORD="{{ sebacon_password }}"
export SEBACON_AUTH="{{ sebacon_auth }}"
export ADMIN_GROUP="{{ admin_group }}"
export SMTP_HOST="{{ smtp_host }}"
export SMTP_USER="{{ smtp_user }}"
export SMTP_PASSWORD="{{ smtp_password }}"
export SMTP_TLS="{{ smtp_tls }}"
export MAIL_FROM="{{ mail_from }}"
export SERVICE_DOMAIN="{{ server_name }}"
export ENABLE_EMAIL_SENDING="{{ enable_emails }}"
export RESTRICT_TO_GROUP="{{ restrict_to_group }}"

cd /srv/checkout/tradenomiitti

node server/index.js
