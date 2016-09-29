#!/bin/bash

#Installing GO  
apt-get update
apt-get -y upgrade
apt-get install -y curl wget git
cd /opt/
curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
tar -xvf go1.6.linux-amd64.tar.gz
mv go /usr/local
export PATH=$PATH:/usr/local/go/bin
mkdir -p /home/ubuntu/work
export GOPATH=/home/ubuntu/work
 
# Installing WebHook
go get github.com/adnanh/webhook
sleep 60

# Installing required files
mkdir -p /home/ubuntu/temp_builds
mkdir -p /home/ubuntu/goscripts && cd /home/ubuntu/goscripts
wget https://raw.githubusercontent.com/devopsbasservice/myscripts/master/build.sh
wget https://raw.githubusercontent.com/devopsbasservice/myscripts/master/hooks.json
wget https://raw.githubusercontent.com/devopsbasservice/myscripts/master/marathon.json
chmod +x /home/ubuntu/goscripts/build.sh

# Initializing
chmod +x /etc/profile.d/*.sh
/etc/profile.d/scalr_globals.sh
echo $SCALR_EXTERNAL_IP

# Install Docker
sudo apt-get install -y linux-image-generic-lts-trusty
wget -qO- https://get.docker.com/ | sh

# docekr login
docker login -u devopsbasservice -p cognizant2016
