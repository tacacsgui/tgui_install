#!/bin/bash
# TacacsGUI src
# Author: Aleksey Mochalin
####  VARIABLES  ####
####  FUNCTIONS ####
function first_appearance () {
  echo $(cat /etc/network/interfaces | grep interfaces.sh | wc -l | tr -d '[:space:]');
  return;
}
function error_message() {
  echo \
"###########    Error!    ###########"$'\n'\
$1$'\n'\
"####################################"; return;
}
function root_access() {
  if [ $(id -u) -ne 0 ]; then
    echo -n 0; return;
  fi
  echo -n 1; return;
}
function check_website() {
  echo $(curl -Is $1 | head -1 | grep 200 | wc -l | tr -d '[:space:]'); return;
}
function check_command() {
  echo $(command -v $1 | wc -l | tr -d '[:space:]'); return;
}
function check_php() {
  echo $(php -v | grep -oE "(PHP 7\.3|)" | wc -l | tr -d '[:space:]'); return;
}
function check_pip() {
  echo $(pip --version > /dev/null 2>&1 && echo 1 || echo 0); return;
}
function where_is_my_little_root() {
  [[ $(sudo cat /etc/sudoers | grep -E "####tgui####|/opt/tacacsgui/tac_plus.sh|/opt/tacacsgui/main.sh" | wc -l ) == '4' ]] && echo 1 || echo 0; return;
}

function check_composer() {
  if [[ $1 == 'install' ]]; then
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    echo 1; return;
  fi
  installed=$(composer --version > /dev/null 2>&1 && echo 1 || echo 0)
  if [[ $installed == '0' ]]; then
    echo $installed; return;
  fi
  if [[ $(composer -V | grep '1.0.0' | wc -l) == '1' ]]; then
    sudo apt-get remove composer -y > /dev/null 2>&1
    echo '0'; return
  fi
  echo '1'; return
}
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
function check_packages_list() {
  packagist_list=('python3-mysqldb' 'libmysqlclient-dev' 'python3-dev' \
  'make' 'gcc' 'openssl' \
  'curl' 'zip' 'unzip' 'libnet-ldap-perl' 'ldap-utils' 'ntp' \
  'libapache2-mod-xsendfile' 'libpcre3-dev:amd64' 'lwresd' \
  'libbind-dev:amd64')
  if [[ $1 == 'install' ]]; then
    sudo apt-get update; sudo apt-get install -y "${packagist_list[@]}"
    echo "${packagist_list[@]}"; return;
    echo 1; return;
  fi
  #'libcurl4-openssl-dev' 'libssl-dev'
  local total=${#packagist_list[@]}
  local grep_regex="dpkg -l | awk '{ print "'$2'" }' | grep -E '"'(^'$( join_by '$|^' "${packagist_list[@]}" )'$)'"'"

  local installed_check=$( eval $grep_regex | wc -l )
  [[ $installed_check == $total ]] && echo 1 || echo 0; return;
  echo 0; return;
  #echo $(pip --version > /dev/null 2>&1 && echo 1 || echo 0); return;
}
function check_ubuntu() {
  echo $(lsb_release -r -s | grep -oE "(16.04)" | wc -l | tr -d '[:space:]'); return;
}
function system_test() {
  RESULT_ERRORS=0;
  RESULT_SUCCESS=0;
  RESULT_TOTAL=0;
  echo; echo "### Test the System ###"; echo;

  let "RESULT_TOTAL+=1";
  if [[ $(first_appearance) -eq 0 ]]; then
    error_message "Error! Please set network setting first! Use main menu to do that."; let "RESULT_ERRORS+=1";
    return;
  else echo "Done.  ### Network Settings Check was Completed Successfully  ###"; echo;  let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_packages_list) -eq 0 ]]; then
    error_message "Error! Some Packages Not Installed! Try to install.";
    check_packages_list 'install'
    if [[ $(check_packages_list) -eq 0 ]]; then
      error_message "Error! Some Packages Not Installed!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### All Packages Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_website "https://github.com") -eq 0 ]]; then
    error_message "Error! GitHub (https://github.com) Unavailable!"; let "RESULT_ERRORS+=1";
  else echo "Done.  ### GitHub Available  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_website "https://packagist.org") -eq 0 ]]; then
    error_message "Error! Composer (https://packagist.org) Unavailable!"; let "RESULT_ERRORS+=1";
  else echo "Done.  ### Composer Repo Available  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  if [ -z $1 ]; then
    let "RESULT_TOTAL+=1";
    if [[ $(check_website "https://tacacsgui.com") -eq 0 ]]; then
      error_message "Error! TacacsGUI (https://tacacsgui.com) Unavailable!"; let "RESULT_ERRORS+=1";
    else echo "Done.  ### TacacsGUI Available  ###"; echo; let "RESULT_SUCCESS+=1";
    fi
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_command "tac_plus") -eq 0 ]]; then
    error_message "Error! Tacacs Not Installed! Try to install";
    echo $(ls -l | grep -E "DEVEL\..*\.tar.bz2" | wc -l)
    if [[ $(ls -l | grep -E "DEVEL\..*\.tar.bz2" | wc -l) == '1' ]]; then
      sudo rm -r ./PROJECTS/ 2>&1 > /dev/null && echo 'Last dir deleted' || echo 'Last dir not found'
      tar -jxf ./DEVEL*tar.bz2 && echo 'Unpacked' || echo 'Something goes wrong...'
      #(cd ./PROJECTS/ && ./configure --with-pcre --with-lwres tac_plus && make && make install)
      cd ./PROJECTS/ && echo 'Go to PROJECTS'
      sudo ./configure --with-pcre --with-lwres tac_plus && echo '(configure) Configure done' || echo 'Something goes wrong...'
      sudo make && echo 'make done' || echo '(make) Something goes wrong...'
      sudo make install && echo 'make install done' || echo '(make install) Something goes wrong...'
      cd .. && echo 'Go back to script dir'
    fi
    if [[ $(check_command "tac_plus") -eq 0 ]]; then
      error_message "Error! Tacacs Not Installed!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### Tacacs Daemon Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_php) -eq 0 ]]; then
    error_message "Error! PHP 7.3 Not Installed! Try to install.";
    if [[ $(sudo apt-cache search php7.3 | wc -l) == 0 ]]; then
    	sudo apt-get install python-software-properties -y
    	sudo add-apt-repository ppa:ondrej/php -y
    	sudo apt-get update
    fi
    sudo apt-get install -y php7.3 php7.3-common php7.3-cli php7.3-fpm php7.3-curl php7.3-dev php7.3-gd php7.3-mbstring php7.3-zip php7.3-mysql php7.3-xml libapache2-mod-php7.3 php7.3-ldap
    sudo a2dismod php7.*; sudo a2enmod php7.3; sudo service apache2 restart
    if [[ $(check_php) -eq 0 ]]; then
      error_message "Error! PHP 7.3 Not Installed!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### PHP 7.3 Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_pip) -eq 0 ]]; then
    error_message "Error! Pip Not Installed! Try to install.";
    sudo apt-get update
    sudo apt-get install python3-pip -y
  	umask 022
  	sudo pip3 install --upgrade pip
  	sudo apt-get remove python3-pip -y
    if [[ $(check_pip) -eq 0 ]]; then
      error_message "Error! Pip Not Installed!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### Pip Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_composer) -eq 0 ]]; then
    error_message "Error! Composer Not Installed! Try to install.";
    check_composer 'install'
    if [[ $(check_composer) -eq 0 ]]; then
      error_message "Error! Composer Not Installed!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### Composer Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(where_is_my_little_root) -eq 0 ]]; then
    error_message "Root Access Not Granted. Try to add.";
    echo -e '\n####tgui####\n'\
'www-data ALL=(ALL) NOPASSWD: /opt/tacacsgui/tac_plus.sh*\n'\
'www-data ALL=(ALL) NOPASSWD: /opt/tacacsgui/main.sh*\n'\
'####tgui####\n' | sudo EDITOR='tee -a' visudo
    if [[ $(where_is_my_little_root) -eq 0 ]]; then
      error_message "Error! Root Access Not Granted!"; let "RESULT_ERRORS+=1";
      return;
    fi
  else echo "Done.  ### Root Access Granted  ###"; echo; let "RESULT_SUCCESS+=1";
  fi

  let "RESULT_TOTAL+=1";
  if [[ $(check_ubuntu) -eq 0 ]]; then
    error_message "Error! Incorrect Ubuntu Installed!"; let "RESULT_ERRORS+=1";
  else echo "Done.  ### Correct version of Ubuntu Installed  ###"; echo; let "RESULT_SUCCESS+=1";
  fi
  if [ -z $1 ]; then
    echo "Result: Total ${RESULT_TOTAL}, Errors ${RESULT_ERRORS}, Success ${RESULT_SUCCESS}" 2>&1 | tee -a $LOG_FILE
  fi
}

#set -x

# global vars
OUTPUTS_REDIRECTED="false"
LOGFILE=/dev/stdout
# "private" function used by redirect_outputs_to_logfile()
function save_standard_outputs {
    if [ "$OUTPUTS_REDIRECTED" == "true" ]; then
        echo "[ERROR]: ${FUNCNAME[0]}: Cannot save standard outputs because they have been redirected before"
        exit 1;
    fi
    exec 3>&1
    exec 4>&2

    trap restore_standard_outputs EXIT
}

# Params: $1 => logfile to write to
function redirect_outputs_to_logfile {
    if [ "$OUTPUTS_REDIRECTED" == "true" ]; then
        echo "[ERROR]: ${FUNCNAME[0]}: Cannot redirect standard outputs because they have been redirected before"
        exit 1;
    fi
    LOGFILE=$1
    if [ -z "$LOGFILE" ]; then
        echo "[ERROR]: ${FUNCNAME[0]}: logfile empty [$LOGFILE]"

    fi
    if [ ! -f $LOGFILE ]; then
        touch $LOGFILE
    fi
    if [ ! -f $LOGFILE ]; then
        echo "[ERROR]: ${FUNCNAME[0]}: creating logfile [$LOGFILE]"
        exit 1
    fi

    save_standard_outputs

    exec > >(tee -i $LOGFILE)
    exec 2>&1
    OUTPUTS_REDIRECTED="true"
    echo "Write all output to file activated"
    return;
}

# "private" function used by save_standard_outputs()
function restore_standard_outputs {
    if [ "$OUTPUTS_REDIRECTED" == "false" ]; then
        echo "[ERROR]: ${FUNCNAME[0]}: Cannot restore standard outputs because they have NOT been redirected"
        exit 1;
    fi
    exec 1>&-   #closes FD 1 (logfile)
    exec 2>&-   #closes FD 2 (logfile)
    exec 2>&4   #restore stderr
    exec 1>&3   #restore stdout

    OUTPUTS_REDIRECTED="false"
}
