#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

mk_swap() {
    #检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    #如果不存在将为其创建swap
    if [ $? -ne 0 ]; then
        mem_num=$(awk '($1 == "MemTotal:"){print $2/1024}' /proc/meminfo|sed "s/\..*//g"|awk '{print $1*2}')
        echo -e "${Green}swapfile未发现，正在为其创建swapfile${Font}"
        fallocate -l ${mem_num}M /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
            echo -e "${Green}swap创建成功，并查看信息：${Font}"
            cat /proc/swaps
            cat /proc/meminfo | grep Swap
    else
        echo -e "${Red}swapfile已存在，swap设置失败，请先运行脚本删除swap后重新设置！${Font}"
    fi
    
}

del_swap(){
    #检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    #如果存在就将其移除
    if [ $? -eq 0 ]; then
        echo -e "${Green}swapfile已发现，正在将其移除...${Font}"
        sed -i '/swapfile/d' /etc/fstab
        echo "3" > /proc/sys/vm/drop_caches
        swapoff -a
        rm -f /swapfile
        echo -e "${Green}swap已删除！${Font}"
    else
        echo -e "${Red}swapfile未发现，swap删除失败！${Font}"
    fi
}

#检查docker程序是否存在不存在就安装
install_docker() {
    if [ ! -f "/usr/bin/docker" ]; then
        read -p "Press enter to install docker" bcaucbau 
        yum -y install docker
        systemctl start docker
        systemctl enable docker
    fi
}

#判断防火墙
if_waf() {
    firewalld_a=$(systemctl status firewalld | grep "Active:" | awk '{print $2}')
    iptables_a=$(systemctl status firewalld | grep "Active:" | awk '{print $2}')
    if [ $firewalld_a = active ]; then
        echo "firewalld stoping"
        systemctl stop firewalld &>/dev/null
        echo "firewalld stop!"
    fi
    if [ $iptables_a = active ]; then
        echo "iptables stoping"
        systemctl stop iptables &>/dev/null
        echo "iptables stop!"
    fi
}
clear

stop_docker() {
    docker stop `docker ps -aq`
}

rm_docker() {
    docker rm `docker ps -aq`
}

start_all_docker() {
    docker start `docker ps -aq`
}

show_input() {
    #定义数据
    read -p "Your Mail:" mail_add 
    read -p "Docker Num:" docker_num 

    clear

    #数据展示
    echo "The email you entered:"$mail_add
    echo "Docker Num:":$docker_num
}

one_install() {
    clear
    mk_swap
    install_docker
    if_waf
    clear
    echo "请自行添加docker节点"
}


start_docker() {
    #循环启动docker
    for ((i=1;i<=$docker_num;i++))
    do
        docker run -d --restart=on-failure luckysdream/p2pclient $mail_add
    done
}


show_menu() {
    echo -e "
  ${green}批量p2pclient脚本

  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} 首次安装
  ${green}2.${plain} 一键启动docker
  ${green}3.${plain} 一键删docker
————————————————
  ${green}4.${plain} 添加节点并启动
  ${green}5.${plain} 防火墙检测
  ${green}6.${plain} SWAP检测
  ${green}7.${plain} 删除SWAP
 "
    echo && read -p "请输入选择 [0-7]: " num

    case "${num}" in
        0) exit 0
        ;;
        1) one_install
        ;;
        2) start_all_docker
        ;;
        3) stop_docker && rm_docker
        ;;
        4) show_input  && start_docker
        ;;
        5) if_waf
        ;;
        6) mk_swap
        ;;
        7) del_swap
        ;;
        *) echo -e "${red}请输入正确的数字 [0-7]${plain}"
        ;;
    esac
}


show_menu
