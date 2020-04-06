# shell-snmp-trap
shell snmp trap to json

## install mandatory packages
(Debian)

`# apt-get install snmp snmpd snmptrapd`

(Centos)

`# yum install net-snmp`

It requires at least IETF and IANA mibs
Should be ok with net-snmp but for debian, edit /etc/apt/sources.list and add "non-free" tag to deb then

`# apt-get update && apt-get install snmp-mibs-downloader`

## basic conf for /etc/snmp/snmptrapd.conf
`authCommunity log,execute,net public`

`traphandle default /root/shell/snmptrap/snmptrap.sh`

then

`# systemctl restart snmptrapd`

test

`# snmptrap -v 2c -c public localhost "" .1.3.6.1.4.1.999999 .1.3.6.1.4.1.999999.1 s "Hello World !"`

`# tail -10 /root/shell/snmptrap/snmptrap.log`
