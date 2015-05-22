#!/bin/bash
# This script is a wrapper to HAproxy statistics which are in a CSV format.
# Output format is compatible with Zabbix.
# It can be used for HAproxy frontends and/or backends discovery and for
# gathering statistics about particular frontend,backend or server.

case $1 in
  "-f")
    OPER='discovery'
    FESQ='grep FRONTEND'
    ;;
  "-b")
    OPER='discovery'
    FESQ='grep BACKEND'
    ;;
  "-s")
    OPER='discovery'
    FESQ='grep -v FRONTEND\|BACKEND\|^$\|^#'
    ;;
  "-v")
    OPER='value'
    IFS=$'.'
    QA=($2)
    unset IFS
    HAPX=${QA[0]}
    HASV=${QA[1]}
    ITEM=${QA[2]}
    FESQ="grep ^${HAPX},${HASV},"
    ;;
  *)
    echo "Wrong arguments supplied, exiting...

          Usage:
              $0 -f|-b|-s|-v <group>.<server>.<item>

              -f                            frontend discovery
              -b                            backend discovery
              -s                            server discovery
              -v <group>.<server>.<item>    get particular item value, for example:

              -v zabbix-agent.node-1.smax
                    will print smax item value for server node-1 in group zabbix-agent
              -v zabbix-agent.FRONTEND.smax
                    will print smax item value for FRONTEND part of zabbix-agent group
              -v zabbix-agent.BACKEND.smax
                    will print smax item value for BACKEND part of zabbix-agent group
    "
    exit 1
esac
STATHEAD=( pxname svname qcur qmax scur smax slim stot bin bout dreq
dresp ereq econ eresp wretr wredis status weight act bck chkfail
chkdown lastchg downtime qlimit pid iid sid throttle lbtot tracked
type rate rate_lim rate_max check_status check_code check_duration
hrsp_1xx hrsp_2xx hrsp_3xx hrsp_4xx hrsp_5xx hrsp_other hanafail
req_rate req_rate_max req_tot cli_abrt srv_abrt )

FES=`echo "show stat" | sudo socat /var/lib/haproxy/stats stdio | sed 's/ /_/g' |grep -v -i 'zabbix-server' | $FESQ`
if [ "$OPER" == "discovery" ]; then
  POSITION=1
  echo "{"
  echo " \"data\":["
  for FE in $FES
  do
      IFS=$','
      FEA=($FE)
      unset IFS
      HAPX=${FEA[0]}
      HASV=${FEA[1]}
      HASTAT=${HAPX}-${HASV}
      if [ $POSITION -gt 1 ]
      then
        echo ","
      fi
      echo -n " { \"{#HAPX}\": \"$HAPX\", \"{#HASTAT}\": \"$HASTAT\", \"{#HASV}\": \"$HASV\" }"
      POSITION=$[POSITION+1]
  done
  echo ""
  echo " ]"
  echo "}"
elif [ "$OPER" == "value" ]; then
  IFS=$','
  FEA=($FES)
  unset IFS
  cnt=0; for el in "${STATHEAD[@]}"; do
    [[ "$el" == "$ITEM" ]] && echo ${FEA[$cnt]} && break
    ((++cnt))
  done
fi
