#!/bin/sh
# 当前目录
CURRENT_DIR=$(
 cd "$(dirname "$0")"
 pwd
)
 
#Install docker 
if which docker >/dev/null; then
 echo "检测到 Docker 已安装，跳过安装步骤"
 docker -v
 echo "启动 Docker "
 service docker start 2>&1 | tee -a ${CURRENT_DIR}/install.log
else
 if [[ -d "$CURRENT_DIR/docker" ]]; then
  echo "... 离线安装 docker"
     cp $CURRENT_DIR/docker/centos-local.tgz /root/
     cd /root && tar -xvzf centos-local.tgz 
  cd /root/docker-ce-local &&rpm -ivh createrepo-0.9.9-28.el7.noarch.rpm
  mkdir -p /etc/yum.repos.d/repobak && mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/repobak
  cp $CURRENT_DIR/docker/docker-ce-local.repo /etc/yum.repos.d/docker-ce-local.repo
  cd /root/docker-ce-local &&createrepo /root/docker-ce-local && yum makecache
     cd $CURRENT_DIR/docker/ &&yum install -y container-selinux-2.9-4.el7.noarch.rpm &&yum install -y docker-ce
     echo "... 启动 docker"
     sudo systemctl start docker 2>&1 | tee -a ${CURRENT_DIR}/install.log
     echo '{"registry-mirrors":["https://registry.docker-cn.com"]}'>/etc/docker/daemon.json
     cat /etc/docker/daemon.json
     service docker restart
 else
  echo "... 在线安装 docker"
  curl -fsSL https://get.docker.com -o get-docker.sh 2>&1 | tee -a ${CURRENT_DIR}/install.log
  sudo sh get-docker.sh 2>&1 | tee -a ${CURRENT_DIR}/install.log
  echo "... 启动 docker"
  service docker start 2>&1 | tee -a ${CURRENT_DIR}/install.log
 fi
fi
 
##Install Latest Stable Docker Compose Release
if which docker-compose >/dev/null; then
 echo "检测到 Docker Compose 已安装，跳过安装步骤"
 docker-compose -v
else
 if [[ -d "$CURRENT_DIR/docker-compose" ]]; then
  echo "... 离线安装 docker-compose"
     cd $CURRENT_DIR/docker-compose/ && cp docker-compose /usr/local/bin/
     chmod +x /usr/local/bin/docker-compose
     docker-compose -version
     echo "... 离线安装 docker-compose 成功"
 else
  echo "... 在线安装 docker-compose"
  curl -L "https://github.com/docker/compose/releases/download/1.14.0-rc2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>&1 | tee -a ${CURRENT_DIR}/install.log
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
     docker-compose -version
     echo "... 在线安装 docker-compose 成功"
 fi
fi
