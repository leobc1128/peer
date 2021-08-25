#!/bin/bash

if [ -n "$1" ]; then
	 num=$1
 else 
	  num=50
  fi
  for ((i=1;i<=$num;i++))
  do
	   docker run -d --restart=on-failure notfourflow/p2pclient:alpine liubc1128@gmail.com
   done
