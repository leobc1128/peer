#!/bin/bash


#检查docker程序是否存在不存在就安装
if [ ! -d "/usr/bin/docker" ]; then
  read -p "Press enter to install docker" bcaucbau 
  yum -y install docker
  systemctl start docker
  systemctl enable docker
fi
clear
read -p "Your Mail:" mail_add 
read -p "Docker Num:" num 

clear
echo "liubc1128@gmail.com:"$mail_add
echo "30:":$num
clear

for ((i=1;i<=$num;i++))
do
	docker run -d --restart=on-failure notfourflow/p2pclient $mail_add
done