#!/bin/bash

read -p "Are you sure you want to stop all your containers? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo docker-compose kill
    echo "ALL containers stoppped!"
fi

read -p "Do you want to destroy all your inactive containers? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo docker system prune -a -f
fi

read -p "Do you want to destroy all your volumes? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo docker volume prune -f
fi
