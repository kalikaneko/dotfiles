#!/bin/bash
#Initial wifi interface configuration
ifconfig $1 up 192.168.0.1 netmask 255.255.255.0
 
###########Start DHCP, comment out / add relevant section##########
#udhcpd wlan0 &
#/etc/init.d/udhcpd start
 
###########
#Enable NAT
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $2 -j MASQUERADE
iptables --append FORWARD --in-interface $1 -j ACCEPT
sysctl -w net.ipv4.ip_forward=1

#start hostapd
hostapd /etc/hostapd/hostapd.conf
#1>/dev/null

