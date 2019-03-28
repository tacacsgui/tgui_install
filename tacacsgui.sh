#!/bin/bash
# TacacsGUI Installation Script
# Author: Aleksey Mochalin
clear;
####  VARIABLES  ####
####
####  FUNCTIONS ####
#MAIN_PATH="`dirname \"$0\"`"
MAIN_PATH=$( dirname $(realpath "$0") )
source "$MAIN_PATH/inc/src/map.sh";
source "$FUN_GENERAL";

####  FUNCTIONS ####  END
#redirect_outputs_to_logfile $LOG_FILE;

#Silent Installation###
if [[ ! -z $1 ]] && [[ $1 == 'silent' ]]; then
  echo 'Silent installation'
  system_test "installation";
  if [[ $RESULT_ERRORS != '0' ]]; then
    error_message "Error was Found. Installation Stop!";
    exit 0
  fi
  echo 'No errors found'
  $INSTALL_SCRIPT_PATH $MAIN_PATH "silent";
  exit 0
fi

SCRIPT_VER="2.0.0";
echo $'\n'\
"###############################################################"$'\n'\
"##############   TACACSGUI Installation Script    ##############"$'\n'\
"###############################################################"$'\n'$'\n'"ver. ${SCRIPT_VER}"$'\n'$'\n'\
"##############     List of available options    ##############"$'\n'\

PS3=$'\n'"Please enter your choice (5 to clear output): "
options=("Install TacacsGUI" "Re-install TacacsGUI" "Network Settings" "Test the System" "Clear and Refresh Menu" "Write to Log file" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install TacacsGUI")
            echo; echo "### $opt ###"; echo;
            system_test "installation";
            if [[ $RESULT_ERRORS -ne 0 ]]; then
              error_message "Error was Found. Installation Stop!";
              continue;
            fi
            $INSTALL_SCRIPT_PATH $MAIN_PATH;
            THIS_SCRIPT=$(readlink -f "$0");
            exec $THIS_SCRIPT;
            ;;
        "Re-install TacacsGUI")
            echo; echo "### $opt ###"; echo;
            system_test "installation";
            if [[ $RESULT_ERRORS -ne 0 ]]; then
              error_message "Error was Found. Installation Stop!";
              continue;
            fi
            $INSTALL_SCRIPT_PATH $MAIN_PATH;
            THIS_SCRIPT=$(readlink -f "$0");
            exec $THIS_SCRIPT;
            ;;
        "Network Settings")
            echo $NET_SCRIPT_PATH;
            $NET_SCRIPT_PATH $MAIN_PATH;
            THIS_SCRIPT=$(readlink -f "$0");
            exec $THIS_SCRIPT;
            ;;
        "Test the System")
            system_test;
            echo; echo "End of $opt";
            ;;
        "Clear and Refresh Menu")
            THIS_SCRIPT=$(readlink -f "$0");
            exec $THIS_SCRIPT;
            ;;
        "Write to Log file")
            exec > >(tee -i $LOG_FILE);
            exec 2>&1;
            echo "Write all output to file activated"
            ;;
        # "Clear log file")
        #     echo -n > $LOG_FILE;
        #     echo "Log file was cleared"
        #     ;;
        "Quit")
            # exec 1>&-   #closes FD 1 (logfile)
            # exec 2>&-   #closes FD 2 (logfile)
            # exec 2>&4   #restore stderr
            # exec 1>&3   #restore stdout
            exit 0;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
