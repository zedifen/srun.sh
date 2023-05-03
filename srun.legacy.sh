#!/bin/sh

MY_NET_INTERFACE=${MY_NET_INTERFACE="eth4"}

MY_IP=$(ifconfig $MY_NET_INTERFACE | grep "inet " | cut -d: -f2 | awk '{print $1}')

if ping -q -c 1 -I $MY_NET_INTERFACE www.gstatic.com; then
    echo "INFO: Internet connection is OK."
    exit 0
else
    echo "INFO: Internet connection is down, need login."
fi

AUTH_USERNAME=${AUTH_USERNAME="username"}
AUTH_PASSWORD=${AUTH_PASSWORD="password"}

API_ENDPOINT=${API_ENDPOINT="http://192.168.2.231/srun_portal_pc.php?ac_id=1&"}
  
curl -i -L \
  -X POST \
  --interface $MY_IP \
  -d "action=login" \
  -d "ac_id=1" \
  -d "user_ip=$MY_IP" \
  -d "nas_ip=" \
  -d "user_mac=" \
  -d "url=" \
  -d "username=$AUTH_USERNAME" \
  -d "password=$AUTH_PASSWORD" \
  -A "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" \
  "$API_ENDPOINT"
