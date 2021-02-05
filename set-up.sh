#!/bin/bash

if [ ! $1 ] || [ $1 == "help" ]
then
  echo "help    - This menu"
  echo "build   - Build TTRPG Tools"
  echo "restart - Restart all containers"
  echo "ssl     - Runs certbot script"
  exit 1
fi

unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     machine=Linux;;
  Darwin*)    machine=Mac;;
  *)          machine="UNKNOWN:${unameOut}"
esac

if [ $machine == "Linux" ]
then
    sudo sysctl vm.max_map_count=262144 > /dev/null 2>&1
fi

source .env
if [ $1 == "build" ]
then
  echo -e "[ \e[33mBuilding Docker\e[0m ]"
  sudo docker-compose up -d --build --remove-orphans || exit 1
  echo -e "[ \e[32mDocker Built\e[0m ]"
fi

if [ $1 == "restart" ]
then
  sudo docker-compose restart
fi

if [ $SSL == "ssl" ] && [ ! -f .certbot.lock ] || [ $1 == "ssl" ]
then
  echo -e "[ \e[33mGenerating Certs\e[0m ]"
  network_name=`sudo docker network ls --format "{{.Name}}" | grep web-network`
  echo -en "[ \e[33mWaiting for nginx to come up\e[0m ]"
  while [ "`sudo docker inspect -f {{.State.Running}} nginx 2> /dev/null`" != "true" ]
  do
    echo -en "."
    sleep 3
  done
  echo -e "[ \e[32mNginx Up\e[0m ]"
  nginx_ip=`sudo docker inspect -f '{{ $network := index .NetworkSettings.Networks "'$network_name'" }}{{ $network.IPAddress}}' nginx 2> /dev/null`
  echo -en "[ \e[33mWaiting for nginx to have an IP\e[0m ]"
  while [ -z "$nginx_ip" ]
  do
    echo -en "."
    sleep 3
    nginx_ip=`sudo docker inspect -f '{{ $network := index .NetworkSettings.Networks "'$network_name'" }}{{ $network.IPAddress}}' nginx 2> /dev/null`
  done
  echo -e "[ \e[32mNginx IP Found\e[0m ]"
  sudo docker exec nginx bash /var/www/certbot.sh && touch .certbot.lock
  sudo docker-compose restart nginx
  echo -e "[ \e[32mGenerated Certs\e[0m ]"
fi

echo ""
echo -e "[ \e[35mAll ready to use\e[0m ]"
echo "Improved Initiative : "$II_HOST"."$DOMAIN;
echo "Dungeon Revealer    : "$DR_HOST"."$DOMAIN;
echo "Paragon             : "$PA_HOST"."$DOMAIN;
echo ""
