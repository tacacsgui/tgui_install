#!/bin/bash
# TacacsGUI src
# Author: Aleksey Mochalin
####  VARIABLES  ####
####  FUNCTIONS ####
function interface_list () {
  ip link | grep -Po '(?<=[0-9]: )[a-z0-9]+(?=:)' | sed "s/^/${TABSPACE}/";
}

function interface_existance () {
  if [ -z "$1" ]; then
    echo 0;
    return;
  fi
  echo $(ip addr | grep -oh "$1:" | grep -E "^[a-z]+[0-9]+:$|^lo:$" | wc -l | tr -d '[:space:]');
  return;
}

function if_settings () {
  if [ -z "$1" ]; then
    error_message "Interface name can not be empty";
    return;
  fi
  if [ ! -f /etc/network/interfaces.d/$1.cfg ]; then
    error_message "Settings for that interface not found";
    return;
  fi
  local output=$(cat /etc/network/interfaces.d/$1.cfg | tr '\n' "\n")
  cat /etc/network/interfaces.d/$1.cfg;
  return;
}

function make_backup () {
  sudo cp /etc/network/interfaces /etc/network/interfaces_old;
  echo 1;
  return;
}

function main_file_prepare () {
  sudo echo -e "# file was automatically created by interfaces.sh #\n source /etc/network/interfaces.d/*" > /etc/network/interfaces
  if [ ! -f /etc/network/interfaces.d/lo.cfg ]
  then
    sudo echo -e "auto lo\niface lo inet loopback" > /etc/network/interfaces.d/lo.cfg
  fi
  echo 1;
  return;
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then stat=0;
        fi
    fi
    echo $stat;
}
