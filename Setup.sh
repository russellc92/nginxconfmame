#!/bin/bash

echo Please set a new root password
sudo passwd

sudo touch /etc/yum.repos.d/mongodb-org.repo
sudo sh -c "echo -e '[mongodb-org-3.4]\r\nname=MongoDB Repository\r\nbaseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.4/x86_64/\r\ngpgcheck=1\r\nenabled=1\r\ngpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc' >> /etc/yum.repos.d/mongodb-org.repo"
yum repolist

sudo yum install mongodb-org -y
sudo systemctl start mongod
sudo systemctl enable mongod

yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
sudo yum install nodejs -y

sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl start nginx

npm install
npm run mongo-import-centos
npm run build

sudo cp -Rf spa/build/ /usr/share/nginx/
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo cp spa/nginx.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
sudo cp nginx.conf /etc/nginx/nginx.conf

sudo cp ~/MBROOMS.crt /etc/nginx
sudo cp ~/rui.key /etc/nginx
sudo setsebool -P httpd_can_network_connect 1

service nginx restart
systemctl enable nginx



sudo sed -i "7i ExecStart=/usr/bin/node $(pwd)/backend/admin-server/server.js" dbtAdmin.service
sudo sed -i "8i WorkingDirectory= $(pwd)/backend/admin-server" dbtAdmin.service

sudo sed -i "7i ExecStart=/usr/bin/node $(pwd)/backend/desk-server/server.js" dbtDesks.service
sudo sed -i "8i WorkingDirectory= $(pwd)/backend/desk-server" dbtDesks.service

sudo cp ./dbtAdmin.service /etc/systemd/system/dbtAdmin.service
sudo cp ./dbtDesks.service /etc/systemd/system/dbtDesks.service

sudo chmod 664 /etc/systemd/system/dbtAdmin.service
sudo chmod 664 /etc/systemd/system/dbtDesks.service

sudo systemctl daemon-reload
sudo systemctl start dbtAdmin.service
sudo systemctl start dbtDesks.service

sudo systemctl enable dbtAdmin.service
sudo systemctl enable dbtDesks.service

sudo systemctl daemon-reload
