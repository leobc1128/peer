#!/bin/bash

if [ -n "$1" ]; then
 num=$1
else 
 num=1
fi
for ((i=1;i<=$num;i++))
do
 docker run -d --restart=on-failure notfourflow/p2pclient:alpine 2570478@qq.com
done
