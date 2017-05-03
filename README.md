# Tradenomiitti

Tradenomiitti is a social web service for members of the trade union Tradenomiliitto. It is up and running at https://tradenomiitti.fi and you can read more about it in [the press release](https://www.sttinfo.fi/tiedote/tradenomien-uusi-palvelu-tarjoaa-rekrytointiapua-ja-mentorointia?publisherId=59695169&releaseId=59695181) (in Finnish) and more about why it's open source [the blog post](http://futurice.com/blog/open-sourcing-a-client-project)

## Deployment

### Server installation

Server installation for Tradenomiitti uses [Ansible](https://docs.ansible.com/).
The included install configuration assumes Ubuntu with passwordless sudo access
over SSH with the user `ubuntu` and Python 2 installed on the server and
symlinked to `python`. The server needs to have a public IP and a public domain
pointing at it, or else Let's encrypt will fail.

You can install servers by running (replace ENV with dev, qa, or prod)

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
git push ENV master
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
export ENABLE_EMAIL_SENDING=false

npm run seed-db

npm start
```

You can go with your browser to `http://localhost:3000/kirjaudu/1` or `http://localhost:3000/kirjaudu/2` to automatically log in as either of the seeded test users: no SSO or members registry API required. After you receive `Ok`, you can navigate to `http://localhost:3000/` and have a valid session in cookies.

Run tests:

```
npm test
npm testFrontend
```

## License

Copyright (C) 2017  Tradenomiliitto

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
