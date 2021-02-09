#!/bin/bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
echo -e "Host github.com" > ~/.ssh/config
echo -e "  HostName github.com" >> ~/.ssh/config
echo -e "  User git" >> ~/.ssh/config
echo -e "  IdentityFile /home/admin/.ssh/$1" >> ~/.ssh/config
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure set region $2
echo -e "[default]" > ~/.aws/credentials
echo -e "aws_access_key_id = $3" >> ~/.aws/credentials
echo -e "aws_secret_access_key = $4" >> ~/.aws/credentials
# Add in git user var later
git clone --recursive git@github.com:$5/ttrpg-tools.git
mv ~/.env ~/ttrpg-tools/
cd ./ttrpg-tools
aws s3 sync s3://ttrpg-terraform-bucket/letsencrypt/ ./nginx/ssl/
aws s3 sync s3://ttrpg-terraform-bucket/mongo_data/ ./mongo/data/
aws s3 sync s3://ttrpg-terraform-bucket/dr_data/ ./dungeon-revealer/data/
