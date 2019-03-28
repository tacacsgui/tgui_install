#!/bin/bash
# TacacsGUI Network Settings Script
# Author: Aleksey Mochalin
clear;
####  VARIABLES  ####

#echo -n > $LOG_FILE;
####  FUNCTIONS ####
if [[ ! -z $1 ]]; then
	MAIN_PATH=$1
else
	MAIN_PATH=$PWD
fi
source "$MAIN_PATH/inc/src/map.sh";
source "$FUN_GENERAL";
source "$FUN_IFACE";

  SCRIPT_VER="1.0.0";
  echo $'\n'\
"###############################################################"$'\n'\
"##############   TACACSGUI Network Settings Script    #########"$'\n'\
"###############################################################"$'\n'$'\n'"ver. ${SCRIPT_VER}"$'\n'$'\n'\
"##############     List of available options    ##############"$'\n'\

  PS3=$'\n'"Please enter your choice (4 to clear output): "
  options=("Show Interface List" "Show Interface Settings" "Configure interface" "Clear and Refresh Menu" "Back to Main Menu")
  select opt in "${options[@]}"
  do
      case $opt in
          "Show Interface List")
              echo; echo "### $opt ###"; echo;
              eval "$NETWORK_PY -l"
              ;;
          "Show Interface Settings")
              echo; echo "### $opt ###"; echo;
              echo -n 'Type the name of interface: '; read -e IFNAME;
              IFNAME="$(echo -e "${IFNAME}" | sed -e 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]' )"

              eval "$NETWORK_PY -i ${IFNAME}"
              ;;
          "Configure interface")
              if [[ $(root_access $IFNAME) -eq '0' ]];
              then
                error_message "Root Access is requered! Run script with sudo.";
                continue;
              fi
              echo; echo; echo -n 'Type the name of interface: '; read -e IFNAME;
              IFNAME="$(echo -e "${IFNAME}" | sed -e 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]' )"

              eval "$NETWORK_PY -s ${IFNAME} --interactive"

              echo 'Done'
              ;;
          "Clear and Refresh Menu")
              THIS_SCRIPT=$(readlink -f "$0");
              exec $THIS_SCRIPT;
              ;;
          "Back to Main Menu")
              exit 0;
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
