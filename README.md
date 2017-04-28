# tradenomiitti

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

Run the server:

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

npm start
```

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
