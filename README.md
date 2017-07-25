# MiBit [![Build Status](https://travis-ci.org/futurice/mibit.svg?branch=master)](https://travis-ci.org/futurice/mibit)

MiBit is a social web service for the members of [Mothers in Business MiB ry](http://www.mothersinbusiness.fi). MiBit is a fork of [Tradenomiitti](https://github.com/Tradenomiliitto/tradenomiitti), a free open source project made for Tradenomiliitto.

*Note: Since both this fork and the upstream project is still under active development, some of the configuration related things (database names, deployment repository name etc.) have not been changed to make merges from upstream easier. This might change later.*

## Deployment

### Server installation

Server installation for MiBit uses [Ansible](https://docs.ansible.com/).
The included install configuration assumes Ubuntu with passwordless sudo access
over SSH with the user `ubuntu` and Python 2 installed on the server and
symlinked to `python`. The server needs to have a public IP and a public domain
pointing at it, or else Let's Encrypt will fail.

You can install servers by running (replace ENV with dev, qa, or prod - defaults to dev if ENV_TO_DEPLOY is not specified):

```sh
npm install
cp /path/to/sideloaded/assets/* conf/assets/ # we don't want fonts/images/etc in repo
npm run preansible
$EDITOR conf/inventory.ini # edit with your favorite editor
ENV_TO_DEPLOY=ENV npm run serverinstallbase
git remote add ENV ubuntu@SERVER:/srv/tradenomiitti.git
git push ENV master # for each ENV
ENV_TO_DEPLOY=ENV npm run serverinstallpm2
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

You can click "Kirjaudu" to login as *Aino* test user. You can also open `http://localhost:3000/kirjaudu/1` or `http://localhost:3000/kirjaudu/2` to use either of the two test user accounts: no SSO or members registry API required.

Run tests:

```
npm test
npm run testFrontend
```

Run the linter:

```
npm run lint
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
