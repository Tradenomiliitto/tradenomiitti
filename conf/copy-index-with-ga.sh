#!/bin/bash

# http://www.grymoire.com/Unix/Sed.html#uh-37
sed -e "/GA HERE/{
 r conf/analytics.txt
 d }" frontend/index.html | \
  sed -e "s/UA-HERE/$(cat /srv/static/google-analytics-id | tr -d '\n')/" > /srv/static/index.html
