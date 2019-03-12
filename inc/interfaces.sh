#!/bin/bash
# TacacsGUI Network Settings Script
# Author: Aleksey Mochalin
clear;
####  VARIABLES  ####

#echo -n > $LOG_FILE;
####  FUNCTIONS ####
source "$PWD/inc/src/map.sh";
source "$FUN_GENERAL";
source "$FUN_IFACE";

if [ $# -eq 0 ]
then
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
              interface_list;
              ;;
          "Show Interface Settings")
              echo; echo "### $opt ###"; echo;
              echo -n 'Type the name of interface: '; read -e IFNAME;
              IFNAME="$(echo -e "${IFNAME}" | sed -e 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]' )"

              if [[ $(interface_existance $IFNAME) -eq '0' ]];
              then
                error_message "Unrecognized Interface";
                continue;
              fi
              if_settings $IFNAME;
              ;;
          "Configure interface")
              if [[ $(root_access $IFNAME) -eq '0' ]];
              then
                error_message "Root Access is requered! Run script with sudo.";
                continue;
              fi
              echo; echo; echo -n 'Type the name of interface: '; read -e IFNAME;
              IFNAME="$(echo -e "${IFNAME}" | sed -e 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]' )"

              if [[ $(interface_existance $IFNAME) -eq '0' ]];
              then
                error_message "Unrecognized Interface $IFNAME";
                continue;
              fi

              FULLINTRFACECONF='';
              while true; do
                while true; do
                  echo; echo -n 'Type IP Address (Required!): '; read -e IP_ADDRESS;
                  IP_ADDRESS="$(echo -e "${IP_ADDRESS}" | sed -e 's/^[[:space:]]*//')"
                  CH=$(valid_ip $IP_ADDRESS);
                  if [[ $CH -ne 0 ]]; then
                    error_message "This is $IP_ADDRESS incorrect ip address! Try one more time."; continue;
                  else
                    break;
                  fi
                done
                FULLINTRFACECONF="address ${IP_ADDRESS}";
                while true; do
                  echo; echo -n 'Type Network Mask (Required!): '; read -e IP_MASK;
                  IP_MASK="$(echo -e "${IP_MASK}" | sed -e 's/^[[:space:]]*//')"
                  CH=$(valid_ip $IP_MASK);
                  if [[ $CH -ne 0 ]]; then
                    error_message "This is $IP_MASK incorrect mask! Try one more time."; continue;
                  else
                    break;
                  fi
                done
                FULLINTRFACECONF="${FULLINTRFACECONF}\nnetmask ${IP_MASK}";
                while true; do
                  echo; echo -n 'Type Network Gateway (OR leave it empty): '; read -e IP_GATEWAY;
                  IP_GATEWAY="$(echo -e "${IP_GATEWAY}" | sed -e 's/^[[:space:]]*//')";
                  if [[ ! -z $IP_GATEWAY ]]; then
                    CH=$(valid_ip $IP_GATEWAY);
                    if [[ $CH -ne 0 ]]; then
                      error_message  "This is $IP_GATEWAY incorrect ip address! Try one more time."; continue;
                    else
                      FULLINTRFACECONF="${FULLINTRFACECONF}\ngateway ${IP_GATEWAY}"; break;
                    fi
                  fi
                  break;
                done
                while true; do
                  echo; echo -n 'Type Primary DNS Server (OR leave it empty): '; read -e IP_PRIMARYDNS;
                  IP_PRIMARYDNS="$(echo -e "${IP_PRIMARYDNS}" | sed -e 's/^[[:space:]]*//')"
                  IP_SECONDARYDNS='';
                  if [[ ! -z $IP_PRIMARYDNS ]]; then
                    CH=$(valid_ip $IP_PRIMARYDNS);
                    if [[ $CH -ne 0 ]]; then
                      error_message "This is $IP_PRIMARYDNS incorrect ip address! Try one more time."; continue;
                    else
                      FULLINTRFACECONF="${FULLINTRFACECONF}\ndns-nameservers ${IP_PRIMARYDNS}"; #break;
                    fi
                    echo; echo -n 'Type Secondary DNS Server (OR leave it empty): '; read -e IP_SECONDARYDNS;
                    IP_SECONDARYDNS="$(echo -e "${IP_SECONDARYDNS}" | sed -e 's/^[[:space:]]*//')"
                    if [[ ! -z $IP_SECONDARYDNS ]]; then
                      CH=$(valid_ip $IP_SECONDARYDNS);
                      if [[ $CH -ne 0 ]]; then
                        error_message  "This is $IP_SECONDARYDNS incorrect ip address! Try one more time."; continue;
                      else
                        FULLINTRFACECONF="${FULLINTRFACECONF} ${IP_SECONDARYDNS}"; break;
                      fi
                    fi
                    break;
                  fi
                  break;
                done
                echo; echo "Configuration for interface ${IFNAME}:";
                echo -e $FULLINTRFACECONF;
                echo "
                ###########################################
                ###         Caution! Attention!         ###
                ### Check these settings twice          ###
                ### If you manage that server remotely  ###
                ###    YOU CAN LOST THE CONNECTION      ###
                ###########################################
                "
                echo; echo -n 'Is it correct settings? (y/n): '; read DECISION;
                if [ "$DECISION" != "${DECISION#[Yy]}" ]; then
                  break;
                else
                  error_message "Ok. Try one more time. Configuration of ${IFNAME}:";
                  continue;
                fi
              done #full interface configuration
              if [[ $(first_appearance) -eq 0 ]]
              then
                echo; echo -n 'It is the first time you run the script. Rewrite the interface file? (y/n): '; read DECISION;
                if [ "$DECISION" == "${DECISION#[Yy]}" ]; then
                  error_message "Ok. Maybe later.";
                  continue;
                fi
                echo -n 'Backup Status: '; echo -n $(make_backup);   echo 'Create main file Status: '; echo -n $(main_file_prepare);
                echo; echo "New File was created.";
              fi
              echo -e "auto ${IFNAME}\niface ${IFNAME} inet static\n${FULLINTRFACECONF}" > /etc/network/interfaces.d/$IFNAME.cfg;
              echo "New Interface File was created (/etc/network/interfaces.d/${IFNAME}.cfg).";

              echo "Network Interface restart...";

              sudo ip addr flush dev ${IFNAME}; sudo ifdown ${IFNAME}; sudo ifup ${IFNAME};

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
fi
