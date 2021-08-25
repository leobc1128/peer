#!/bin/bash

# maintainer: https://github.com/Chasing66/beautiful_docker/tree/main/peer2profit

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --email)
                email="$2"
                shift
                shift
                ;;
            --number)
                replicas="$2"
                shift
                shift
                ;;
            --debug-output)
                set -x
                shift
                ;;
            *)
                error "Unknown argument: $1"
                exit 1
        esac
    done
}

function check_whether_root_user()
{
    if [ "$(id -u)" != "0" ]; then
        echo "Error: You must be root to run this script, please use root to install"
        exit 1
    fi
}

function install_mandantory_packages()
{
    linux_distribution=$(grep "^NAME=" /etc/os-release | cut -d= -f2)
    linux_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d= -f2)
    if [ $(echo $linux_distribution | grep "CentOS" &>/dev/null; echo $?) -eq 0  ]; then
        yum install wget sudo curl bc -y &>/dev/null
        sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine &>/dev/null 
        if [[ $(echo "$linux_version < 7" | bc) == 1 ]]; then
            echo "This script is designed for CentOS 7 or later."
            exit 1
        fi
    elif [ $(echo $linux_distribution | grep "Debian" &>/dev/null; echo $?) -eq 0  ] || [ $(echo $linux_distribution | grep "Ubuntu" &>/dev/null; echo $?) -eq 0 ]; then
        apt update &>/dev/null && apt install wget sudo curl bc -y &>/dev/null
        sudo apt-get remove docker docker-engine docker.io containerd runc &>/dev/null
        if [[ $(echo "$linux_version < 10" | bc) == 1 ]]; then
            echo "This script is designed for Debian 10+ or Ubuntu16+."
            exit 1
        fi
    else
        echo "Unsupported linux system"
        exit 1
    fi
}

function install_docker_dockercompose() {
    if which docker >/dev/null; then
        echo "Docker has been installed, skipped"
    else
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        check_docker_version=$(docker version &>/dev/null; echo $?)
        if [[ $check_docker_version -eq 0 ]]; then
            echo "Docker installed successfully."
        else
            echo "Docker install failed."
            exit 1
        fi
        systemctl enable docker
    fi
    if which docker-compose >/dev/null; then
        echo "docker-compose has been installed, skipped"
    else
        echo "Installing docker-compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        check_docker_compose_version=$(docker-compose version &>/dev/null; echo $?)
        if [[ $check_docker_compose_version -eq 0 ]]; then
            echo "docker-compose installed successfully."
        else
            echo "docker-compose install failed."
            exit 1
        fi
    fi
}

function download_compose_file()
{
    wget https://raw.githubusercontent.com/leobc1128/peer/main/docker-compose.yml -O docker-compose.yml
}

function set_peer2profit_email()
{
    if [ -z "$email" ]; then
        read -rp "Input your email: " email
    fi
    if [ -n "$email" ]; then
        echo "You email is: $email"
        export email
        sed -i "s/email=.*/email=$email/g" docker-compose.yml
    else
        echo "Please input your email."
        exit 1
    fi
}

function set_contaienr_replicas_numbers()
{
    if [ -z "$replicas" ]; then
        read -rp "Input the container numbers you want to run: " replicas
    fi
    if [ -n "$replicas" ]; then
        echo "You container numbers is: $replicas"
        export replicas
        sed -i "s/replicas:.*/replicas: $replicas/g" docker-compose.yml
    else
        echo "Please input the container numbers you want to run."
        exit 1
    fi
}

function start_containers()
{
    docker-compose up -d
    docker-compose ps -a
}

function main()
{   
    parse_args "$@"
    check_whether_root_user
    install_mandantory_packages
    install_docker_dockercompose
    download_compose_file
    set_peer2profit_email
    set_contaienr_replicas_numbers
    start_containers
}

main "$@"
