#!/bin/bash

# get hostname. Snmp agent will try to convert ip to host (basicaly from /etc/hosts content)
read hostname
# get ipaddress
read ipaddress

timestamp=`date '+%Y-%m-%d %H:%M:%S.%3N'`
ipaddress=`sed 's/UDP: \[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\].*/\1/' <<< $ipaddress`

# init json
line="{\"timestamp\":\"$timestamp\",\"host\":\"$ipaddress\",\"message\":\"null\","

# $i & $v will store a cleaned and structured info/value pair for json
i=""
v=""

# snmp receives a info/value pair per line. A line can also only contain a single value which is part of the previous info/value pair line

while read oid value; do

  # try translate full oid to text, ex : .1.3.6.1.4.1.999999.1 to SNMPv2-SMI::enterprises.999999.1
  translate="`snmptranslate -m +ALL $oid`"
  if [ ! -z $translate ]; then oid=$translate; fi

  if [[ $oid =~ ^.*::.*$ ]]; then

    # check if $i is not empty
    if [ ! -z $i ]; then

      i=$i
      # remove first and last double quotes if present
      v=`sed -e 's/^"//' -e 's/"$//' <<< $v`
      # escape double quotes into value
      v=${v//\"/\\\"}
      # add key/value pair to line
      line="$line\"$i\":\"$v\","

      # new key/value pair added to json so clear vars
      i=""
      v=""

    fi

    # replace colons to underscores
    i=`sed -e 's/:/_/g' <<< $oid`

  else

    # if $oid is not an oid, it's a value
    [ -z $v ] && v="$oid" || v="$v\n$oid"

  fi

  # add value to $v
  [ -z $v ] && v="$value" || v="$v\n$value"

done

i=$i
# remove first and last double quotes if present
v=`sed -e 's/^"//' -e 's/"$//' <<< $v`
# escape double quotes into value
v=${v//\"/\\\"}
# add last info/value pair to json
line="$line\"$i\":\"$v\","

# remove last comma and close the line
line="`sed -e 's/,$//' <<< $line`}"

# send json formated anywhere you want

# to graylog server
#curl -XPOST http://10.0.0.10:12202/gelf --data-binary "$line"
# to file
echo $line >> /root/shell/snmp-trap/snmptrap.log
