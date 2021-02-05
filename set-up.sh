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
  sudo docker exec nginx bash /var/www/certbot.sh && touch .certbot.lock
  sudo docker-compose restart nginx
fi

echo ""
echo -e "[ \e[35mAll ready to use\e[0m ]"
echo "Improved Initiative : "$II_HOST"."$DOMAIN;
echo "Dungeon Revealer    : "$DR_HOST"."$DOMAIN;
echo "Paragon             : "$PA_HOST"."$DOMAIN;
echo ""
