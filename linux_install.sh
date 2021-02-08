#!/bin/bash
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common  build-essential make
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
ssh-keyscan github.com >> ~/.ssh/known_hosts
echo -e "Host github.com" > ~/.ssh/config
echo -e "  HostName github.com" >> ~/.ssh/config
echo -e "  User git" >> ~/.ssh/config
echo -e "  IdentityFile /home/admin/.ssh/$1" >> ~/.ssh/config
git clone --recursive git@github.com:wushin/ttrpg-tools.git
mv ~/.env ~/ttrpg-tools/
cd ./ttrpg-tools
#make build
