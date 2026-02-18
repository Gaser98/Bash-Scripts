#!/bin/bash 
sudo yum install -y iptables iptables-services
sudo iptables -I INPUT -p tcp --dport <Port> -s <IP> -j ACCEPT #order matters
sudo iptables -A INPUT -p tcp --dport <Port> -j DROP
sudo service iptables save  #makes the rules persistent even after reboot
sudo iptables -L INPUT -v -n --line-numbers
