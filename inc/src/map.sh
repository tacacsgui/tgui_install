#!/bin/bash
# TacacsGUI Path map
# Author: Aleksey Mochalin
# echo "${BASH_SOURCE%/*}";
# LOG FILE #
MAP_PATH=$MAIN_PATH
LOG_FILE="$MAP_PATH/log/tacacsgui.log";
# FUNCTIONS #
FUN_GENERAL="$MAP_PATH/inc/src/func_general.sh";
FUN_IFACE="$MAP_PATH/inc/src/func_if.sh";
FUN_INSTALL="$MAP_PATH/inc/src/func_install.sh";
# SCRIPTS #
NETWORK="$MAP_PATH/inc/interfaces.sh";
NETWORK_PY="$MAP_PATH/inc/interfaces.py";
NET_SCRIPT_PATH="$MAP_PATH/inc/interfaces.sh";
INSTALL_SCRIPT_PATH="$MAP_PATH/inc/install.sh";
# APACH FILES #
APACHE_FILES_DIR="$MAP_PATH/inc/apache2";
TACACS_CONF_TEST="$MAP_PATH/inc/tac_plus_test.cfg";
