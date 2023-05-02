#!/bin/sh

# DEFINE WHICH NETWORK INTERFACE TO USE
MY_NET_INTERFACE=${MY_NET_INTERFACE="eth4"}

# GET IP ADDRESS
MY_IP=$(ifconfig $MY_NET_INTERFACE | grep "inet " | cut -d: -f2 | awk '{print $1}')

# TEST CONNECTIVITY
if ping -q -c 1 -I $MY_NET_INTERFACE www.gstatic.com; then
    echo "INFO: Internet connection is OK."
    exit 0
else
    echo "INFO: Internet connection is down, need login."
fi

# SCRIPT INPUTS
SRUN_AUTH_HOST=${SRUN_AUTH_HOST="10.210.2.100"}
AUTH_USERNAME=${AUTH_USERNAME="username"}
AUTH_PASSWORD=${AUTH_PASSWORD="password"}

MY_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"


CHALLENGE_API_ENDPOINT="http://$SRUN_AUTH_HOST/cgi-bin/get_challenge"
SRUNPORTAL_API_ENDPOINT="http://$SRUN_AUTH_HOST/cgi-bin/srun_portal"

TIME_STR_MILLISECONDS=$(date +%s%N | cut -b1-13)

MAX_RANDOM=9999999999999999
MIN_RANDOM=1000000000000000
RANDOM_U64=$(od -N7 -tu8 -An /dev/urandom)
JSONP_CALLBACK_RANDOM_NUMBER=$(( RANDOM_U64 % (MAX_RANDOM + 1 - MIN_RANDOM) + MIN_RANDOM ))

TOKEN=$(
curl -X GET -i -G -L \
  "$CHALLENGE_API_ENDPOINT" \
  --interface "$MY_IP" \
  -d "callback=jQueryjQuery11240$JSONP_CALLBACK_RANDOM_NUMBER""_""$TIME_STR_MILLISECONDS" \
  --data-urlencode "username=$AUTH_USERNAME" \
  -d "ip=$MY_IP" \
  -d "_=$TIME_STR_MILLISECONDS" \
  -A "$MY_USER_AGENT" \
  | grep -o '"challenge": *"[^"]*' | grep -o '[^"]*$'
)

echo "The token is: $TOKEN";

ord() {
  printf '%d ' "'$1"
}

sencode() {
  str="$1"
  slen=${#str}
  for ((i=0;i<slen;i+=4)); do
      c1=$(ord "${str:i:1}")
      c2=$(ord "${str:i+1:1}")
      c3=$(ord "${str:i+2:1}")
      c4=$(ord "${str:i+3:1}")
      echo $(( $c1 | $c2 << 8 | $c3 << 16 | $c4 << 24 ))
  done
  if [ "$2" = "true" ];
  then
    echo "$slen"
  fi;
}

INFO='{"username":"'$AUTH_USERNAME'","password":"'$AUTH_PASSWORD'","ip":"'$MY_IP'","acid":"4","enc_ver":"srun_bx1"}'

echo "The INFO is: $INFO";

xencode() {
  v=($(sencode "$1" true))
  k=($(sencode "$2" false))
  n=${#v[@]}
  z=${v[n - 1]}
  c=0x9E3779B9
  q=$((6 + 52 / (n + 1)))
  d=0
  while [[ $q -gt 0 ]]; do
    d=$((d + c))
    e=$((d >> 2 & 3))
    for ((p=0;p<n;p+=1)) do
      vi=$(((p + 1) % n))
      ki=$(((p & 3) ^ e))
      y=${v[$vi]}
      m=$((z >> 5 ^ y << 2))
      m=$(( m + ((y >> 3 ^ z << 4) ^ (d ^ y)) ))
      m=$(( m + (${k[$ki]} ^ z) ))
      v[$p]=$((v[$p] + m & 0xFFFFFFFF))
      z=${v[$p]}
    done
    q=$((q - 1))
  done
  for i in "${v[@]}"; do
    printf '\\x%02x\\x%02x\\x%02x\\x%02x' $((i & 0xff)) $((i >> 8 & 0xff)) $((i >> 16 & 0xff)) $((i >> 24 & 0xff))
  done
}

STANDARD_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
MAGICIAN_ALPHABET="LVoJPiCN2R8G90yg+hmFHuacZ1OWMnrsSTXkYpUq/3dlbfKwv6xztjI7DeBE45QA"

SRBX1="{SRBX1}"$(echo -e -n "$(xencode "$INFO" "$TOKEN")" | base64 -w 0 | tr $STANDARD_ALPHABET $MAGICIAN_ALPHABET)

echo "The SRBX1 is: $SRBX1";

HMD5=$(printf "%s" "$AUTH_PASSWORD" | openssl dgst -md5 -hmac "$TOKEN" | cut -d ' ' -f 2)

CHKSTR=\
$TOKEN$AUTH_USERNAME\
$TOKEN$HMD5\
$TOKEN"4"\
$TOKEN$MY_IP\
$TOKEN"200"\
$TOKEN"1"\
$TOKEN$SRBX1

CHKSUM=$(printf "%s" "$CHKSTR" | openssl dgst -sha1 | cut -d ' ' -f 2)

STATUS_TEXT=$(
curl -X GET -i -G -L \
  "$SRUNPORTAL_API_ENDPOINT" \
  --interface "$MY_IP" \
  -d "callback=jQuery11240$JSONP_CALLBACK_RANDOM_NUMBER""_""$TIME_STR_MILLISECONDS" \
  -d "action=login" \
  --data-urlencode "username=$AUTH_USERNAME" \
  --data-urlencode "password={MD5}$HMD5" \
  -d "os=Windows+10" \
  -d "name=Windows" \
  -d "double_stack=0" \
  -d "chksum=$CHKSUM" \
  --data-urlencode "info=$SRBX1" \
  -d "ac_id=4" \
  -d "ip=$MY_IP" \
  -d "n=200" \
  -d "type=1" \
  -d "_=$TIME_STR_MILLISECONDS" \
  -A "$MY_USER_AGENT" \
  | grep -o '"error": *"[^"]*' | grep -o '[^"]*$'
)

if [ $STATUS_TEXT != "ok" ]; then
  echo "ERROR: Failed to login.";
else
  echo "INFO: Login successfully.";
fi
