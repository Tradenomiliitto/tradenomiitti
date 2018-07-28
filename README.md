# Tradenomiitti [![Build Status](https://travis-ci.org/Tradenomiliitto/tradenomiitti.svg?branch=master)](https://travis-ci.org/Tradenomiliitto/tradenomiitti)

Tradenomiitti is a social web service for members of the trade union Tradenomiliitto. It is up and running at https://tradenomiitti.fi and you can read more about it in [the press release](https://www.sttinfo.fi/tiedote/tradenomien-uusi-palvelu-tarjoaa-rekrytointiapua-ja-mentorointia?publisherId=59695169&releaseId=59695181) (in Finnish) and more about why it's open source [the blog post](http://futurice.com/blog/open-sourcing-a-client-project)

A [fork](https://github.com/futurice/mibit) for a different community, the members of organization [Mothers in Business](http://mothersinbusiness.fi/), is running at https://mibit.mib.fi/ and you can read more about that in [the info page](http://mothersinbusiness.fi/mibit/).

## Deployment

### Server installation

Server installation for Tradenomiitti uses [Ansible](https://docs.ansible.com/).
You need to have a recent enough version of Ansible locally, at least 2.0.0.2
which is included in Ubuntu 16.04 does not work. The included install
configuration assumes Ubuntu with passwordless sudo access over SSH with the
user `ubuntu` and Python 2 installed on the server and symlinked to `python`.
The server needs to have a public IP and a public domain pointing at it, or else
Let's encrypt will fail.

You can install servers by running (replace ENV with dev, qa, or prod - defaults to dev if ENV_TO_DEPLOY is not specified):

```sh
npm install
cp /path/to/sideloaded/assets/* conf/assets/ # we don't want fonts/images/etc in repo
npm run preansible
$EDITOR conf/inventory.ini # edit with your favorite editor
ENV_TO_DEPLOY=ENV npm run serverinstallbase
git remote add ENV ubuntu@SERVER:/srv/tradenomiitti.git
git push ENV master # for each ENV
```

### Actual deployment

Deployment of a new version is done using git.

Once:

```sh
git remote add ENV ubuntu@SERVER/srv/tradenomiitti.git
```

To deploy:

```sh
ENV_TO_DEPLOY=ENV npm run deploy
```

To upload static assets and deploy:

```sh
ENV_TO_DEPLOY=ENV npm run uploadanddeploy
```

### Local development

* Install and set up PostgreSQL.
   * Set up databases `tradenomiitti` and `tradenomiitti-test`
* Install graphicsmagick
   * It's under that name in most package managers (Ubuntu, Arch, brew for macOS)
* If you didn't already do it above, run `npm install` and copy assets to `conf/assets/`

Compile elm & scss

```
npm run compilelocal
```

Run the server with full integrations:

```
export SEBACON_CUSTOMER=
export SEBACON_USER=
export SEBACON_PASSWORD=
export SEBACON_AUTH=
export db_user= 
export db_password= 
export environment=development
export COMMUNICATIONS_KEY=
export SMTP_HOST=
export SMTP_USER=
export SMTP_PASSWORD=
export SMTP_TLS=
export MAIL_FROM=
export ENABLE_EMAIL_SENDING=true

npm start
```

Run with minimal integrations and seeded mock data.

```
export DISABLE_SEBACON=true
export db_user=
export db_password=
export environment=development
export TEST_LOGIN=true

npm run seed-db

npm start
```

You can click "Kirjaudu" to login as *Tradenomi1* test user. You can also open `http://localhost:3000/kirjaudu/1` or `http://localhost:3000/kirjaudu/2` to use either of the two test user accounts: no SSO or members registry API required. 

Run tests:

```
npm test
npm run testFrontend
```

## Removal of profile

Replace REMOTE_ID with the remote ID you want to remove.

### Make user anonymous, but keep ads and replies

```
\set remote_id '\'' REMOTE_ID '\''
update users set data = '{ "name": "[poistettu]" }', settings='{}' where remote_id = :remote_id;
delete from skills where user_id = (select id from users where remote_id = :remote_id);
delete from user_educations where user_id = (select id from users where remote_id = :remote_id);
delete from user_special_skills where user_id = (select id from users where remote_id = :remote_id);
delete from sessions where user_id = (select id from users where remote_id = :remote_id);
update users set remote_id = -1 where remote_id = :remote_id;
```

### Completely remove user and all their content, including others' replies to their ads

```
delete from users where remote_id = 'REMOTE_ID';
```

## License

Copyright (C) 2017  Tradenomiliitto and others, see AUTHORS

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
