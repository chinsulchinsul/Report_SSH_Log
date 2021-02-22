#!/bin/bash
 
# This script installs packages automatically.

echo #START INSTALLING GIT….
sudo apt-get update –y
sudo apt-get install git -y
cd /opt
sudo git clone https://github.com/chinsulchinsul/Report_SSH_Log.git
sudo git checkout .
sudo chmod 777 Report_SSH_Log #for_learning_purpose

sudo apt-get install openssh -y
sudo sed -i -e 's/#PermitRootLogin\swithout-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo service ssh restart
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y 

echo ""
echo "Please Input IP Server : ";
read ipserver;
ssh-copy-id -i ~/.ssh/id_rsa.pub root@$ipserver 

echo ""
echo "Please Input IP Client : ";
read ipclient;
ssh-copy-id -i ~/.ssh/id_rsa.pub root@$ipclient 

echo #START INSTALLING ANSIBLE….
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install ansible -y
sudo ansible --version
cat <<EOF > /etc/ansible/hosts
[server]
$ipserver
[client]
$ipclient
EOF
sudo ansible -m ping all #testing until showing pong

echo #START INSTALLING MYSQL….
sudo apt install python-mysqldb mysql-server python-dev libmysqlclient-dev  python-pip –y
sudo sed -i -e 's/#bind-address/bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service

cd Report_SSH_Log/
#Edit
sed -i –e "s/x.x.x.x/$ipserver/g" Reporter.py
sed -i –e "s/x.x.x.x/$ipserver/g" Client.py
cd ansible/
sudo ansible-playbook ssh-reporting.yml 

