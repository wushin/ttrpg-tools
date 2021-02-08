#!/bin/bash
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common build-essential make libc6-dev groff less unzip
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure set region $3
echo -e "[default]" > ~/.aws/credentials
echo -e "aws_access_key_id = $4" >> ~/.aws/credentials
echo -e "aws_secret_access_key = $5" >> ~/.aws/credentials
ssh-keyscan github.com >> ~/.ssh/known_hosts
echo -e "Host github.com" > ~/.ssh/config
echo -e "  HostName github.com" >> ~/.ssh/config
echo -e "  User git" >> ~/.ssh/config
echo -e "  IdentityFile /home/admin/.ssh/$1" >> ~/.ssh/config
git clone --recursive git@github.com:wushin/ttrpg-tools.git
mv ~/.env ~/ttrpg-tools/
cd ./ttrpg-tools
bash ~/update_dns.sh $2
aws s3 sync s3://ttrpg-terraform-bucket/letsencrypt/ ./nginx/ssl/
aws s3 sync s3://ttrpg-terraform-bucket/mongo_data/ ./mongo/data/
aws s3 sync s3://ttrpg-terraform-bucket/dr_data/ ./dungeon-revealer/data/
#make build
