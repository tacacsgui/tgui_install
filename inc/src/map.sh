#!/bin/bash
# TacacsGUI Path map
# Author: Aleksey Mochalin
# echo "${BASH_SOURCE%/*}";
# LOG FILE #
LOG_FILE="$PWD/log/tacacsgui.log";
# FUNCTIONS #
FUN_GENERAL="$PWD/inc/src/func_general.sh";
FUN_IFACE="$PWD/inc/src/func_if.sh";
FUN_INSTALL="$PWD/inc/src/func_install.sh";
# SCRIPTS #
NETWORK="$PWD/inc/interfaces.sh";
NET_SCRIPT_PATH="inc/interfaces.sh";
INSTALL_SCRIPT_PATH="inc/install.sh";
# APACH FILES #
APACHE_FILES_DIR="$PWD/inc/apache2";
TACACS_CONF_TEST="$PWD/inc/tac_plus_test.cfg";
