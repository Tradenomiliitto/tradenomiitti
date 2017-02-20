# tradenomiitti

## Deployment

### Server installation

Server installation for Tradenomiitti uses [Ansible](https://docs.ansible.com/).
The included install configuration assumes Ubuntu with passwordless sudo access
over SSH with the user `ubuntu` and Python 2 installed on the server and
symlinked to `python`.

You can install servers by running

```sh
npm install
cp /path/to/MundoSansStd.otf conf/assets/ # we don't want fonts in repo
npm run preansible
$EDITOR conf/inventory.ini
npm run serverinstallbase
git remote add ENV ubuntu@SERVER/srv/tradenomiitti.git # for each ENV
git push ENV master # for each ENV
npm run serverinstallpm2
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

### Local development with SQLite

Compile elm & scss
```
npm run compilelocal
```
Run the server:
```
npm start
```
To seed the database:
```
knex seed:run --env local
```
