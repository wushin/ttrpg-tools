TTRPG Tools
=================

  * [About](https://github.com/wushin/ttrpg-tools#about)
  * [Prerequisites](https://github.com/wushin/ttrpg-tools#prerequisites)
  * [Initializing](https://github.com/wushin/ttrpg-tools#initializing)
  * [Env file options](https://github.com/wushin/ttrpg-tools#env-file-options)
  * [Using localhost](https://github.com/wushin/ttrpg-tools#using-localhost)
  * [Destroy env](https://github.com/wushin/ttrpg-tools#destroy-env)
  * [Working in containers](https://github.com/wushin/ttrpg-tools#working-in-containers)

## About
* A easy to install set of tools to help DM TTRPGs
  * [Dungeon Revealer](https://github.com/dungeon-revealer/dungeon-revealer) - Uses images to display dungeon maps with fog of war
  * [Improved Initiative](https://github.com/cynicaloptimist/improved-initiative) - Combat tracker for Dungeons and Dragons (D&D) 5th Edition
  * [Paragon](https://github.com/cynicaloptimist/paragon) - Configurable DM screen to use when running a tabletop RPGs
  * [Let's Encrypt](https://letsencrypt.org/) - a free ssl service

## Prerequisites:
* Docker [Mac Install](https://docs.docker.com/docker-for-mac/install/) [Linux Install](https://docs.docker.com/engine/install/#server)
* Docker Compose [Mac & Linux Install](https://docs.docker.com/compose/install/)

## Initializing
* Clone recursively
  * `git clone --recursive` (git 1+)
  * `git clone --recurse-submodules` (git 2+)
* Copy over the .env.sample and configure your settings.
  * See [Env file options](https://github.com/wushin/ttrpg-tools#env-file-options) for options
* Build and Bring the docker-compose environment up
  * `sudo docker-compose up -d --build`
* Then create or update your ssl certs
  * `sudo docker exec nginx bash /var/www/certbot.sh`

## Env file options
* `NODE_ENV` - `production` or `development` which Improved Initiative build to use
* `DOMAIN` - The domain all the hosts will bind too
* `DOMAIN_EMAIL` - The Email address Let's Encrypt will notify you when the ssl is about to expire
* `DR_HOST` - The hostname for Dungeon Revealer
* `II_HOST` - The hostname for Improved Initiative
* `PA_HOST` - The hostname for Paragon
* `SSL` - `nossl` to not use ssl and `ssl` to use ssl
* `HTACCESS` - `yes` to set-up auth with separate player and gm password and `no` to not set-up auth
* `HT_USER` - The name the players will use to login
* `DR_USER_PASS` - The password the players will use to login
* `HT_DM_USER` - The name the DM will use to login
* `DR_DM_PASS` - The password the DM will use to login
* `MONGO_INITDB_ROOT_USERNAME` - Name for root user of Mongo db
* `MONGO_INITDB_ROOT_PASSWORD` - Password for root user of Mongo db

## Using localhost
* If you want to use localhost or the machine's IP add entries into your hosts file. 
  * Example using localhost:
```
127.0.0.1	localhost dungeon-revealer.localdomain improved-initiative.localdomain paragon.localdomain
```

* Let's Encrypt SSL does not work with localhost. The default SSLs generated by nginx can work if you accept them and add them to your browser.

## Destroy env
* `bash destroy.sh`
  * This script will prompt you to:
    * Stop all containers
    * Destroy all containers
    * Destroy all Volumes

## Working in containers
* Login
  * `sudo docker exec -it [<container_hostname>] (ba)sh`
* Get logs
  * `sudo docker-compose logs -f [<container_name>]`
* Show
  * `sudo docker-compose ps`
* Build and Start
  * `sudo docker-compose build -d`
* Stop all containers
  * `sudo docker-compose kill`
* Delete inactive containers
  * `sudo docker system prune -a -f`
* Remove Volumes
  * `sudo docker volume prune -f`
