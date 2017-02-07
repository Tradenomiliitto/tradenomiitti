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
$EDITOR conf/inventory.ini
npm run serverinstall
```
