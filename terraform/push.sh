#!/bin/sh
aws --profile ttrpg ecr get-login-password --region us-east-2 | sudo docker login --username AWS --password-stdin $1

for x in $2_nginx $2_dungeon-revealer $2_improved-initiative $_paragon mongo
do 
image=`echo $x | sed s/$2_//g`
echo "upload docker image: $x" 
echo "sudo docker tag ${x}:$1/${image}:latest"
sudo docker tag ${x}:latest $1/${image}:latest
echo "sudo docker push $1/${image}:latest "
sudo docker push $1/${image}:latest
done

