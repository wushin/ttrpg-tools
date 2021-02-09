#!/bin/bash
source .env
localip=`curl ifconfig.me`
if [ $1 == "google" ]
then
  URL="https://$DR_USER:$DR_PASS@domains.google.com/nic/update?hostname=$DR_HOST.$DOMAIN&myip=$localip"
  curl -s $URL
  URL="https://$II_USER:$II_PASS@domains.google.com/nic/update?hostname=$II_HOST.$DOMAIN&myip=$localip"
  curl -s $URL
  URL="https://$PA_USER:$PA_PASS@domains.google.com/nic/update?hostname=$PA_HOST.$DOMAIN&myip=$localip"
  curl -s $URL
fi
