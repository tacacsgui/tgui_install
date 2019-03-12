#!/bin/bash
# TacacsGUI src
# Author: Aleksey Mochalin
####  VARIABLES  ####
####  FUNCTIONS ####
function check_mysql_root () {
  echo $( echo "SHOW DATABASES;" | mysql -uroot -p$1 2>/dev/null | grep base | wc -l );
  return;
}
function check_database_existence () {
  echo $( echo "SHOW DATABASES;" | mysql -uroot -p$1 2>/dev/null | grep $2 | wc -l );
  return;
}
function check_mysql_user_existence () {
  echo $( echo "select user from mysql.user where user='$2';" | mysql -uroot -p$1 2>/dev/null | grep $2 | wc -l );
  return;
}
function check_mysql_user_grants () {
  echo $( echo "show grants for '$2'@'localhost';" | mysql -uroot -p$1 2>/dev/null | grep -Ei "^grant.+on.+\`$3\`.+'$2'@'localhost'" | wc -l );
  return;
}
function check_mysql_tgui_logging () {
  echo $( echo "describe tgui.api_logging;" | mysql -uroot -p$1 2>/dev/null | wc -l );
  return;
}
function drop_tgui_logging () {
    echo "use tgui; DROP TABLE IF EXISTS tac_log_accounting, tac_log_authentication, tac_log_authorization, api_logging;" | mysql -uroot -p$1 2>/dev/null;
  return;
}
