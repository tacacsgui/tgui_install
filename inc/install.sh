#!/bin/bash
# TacacsGUI Install Script
# Author: Aleksey Mochalin
clear;
####  VARIABLES  ####
#ROOT_PATH="/opt/tacacsgui"
####  FUNCTIONS ####
if [[ ! -z $1 ]]; then
	MAIN_PATH=$1
else
	MAIN_PATH=$PWD
fi

source "$MAIN_PATH/inc/src/map.sh";
echo $FUN_GENERAL
# echo $MAIN_PATH
source "$FUN_GENERAL";
source "$FUN_IFACE";
source "$FUN_INSTALL";
#if [ $# -eq 0 ]; then
	SCRIPT_VER="2.0.0";
	echo $'\n'\
"###############################################################"$'\n'\
"##############   TACACSGUI Installation    #########"$'\n'\
"###############################################################"$'\n'$'\n'"ver. ${SCRIPT_VER}"$'\n'$'\n'\

	echo 'Start Installation';
	SILENT='0'
	if [[ ! -z $2 ]] && [[ $2 == 'silent' ]]; then
		echo 'Silent installation detected!'
		SILENT='1'
	fi
	###CHECK DATABASE###
	echo 'Check database...';
	###CHECK ROOT PASSWORD###
	while true; do
		REMEMBER_ROOT_PASSWD=0
		if [[ -z $MYSQL_ROOT_TRY ]]; then
			MYSQL_ROOT_TRY='0'
		fi
		if [[ $MYSQL_ROOT_TRY -eq 0 ]]; then
			echo -n "Try to get root password to MySQL...";
			if [[  $(cat /opt/tacacsgui/web/api/config.php 2>/dev/null | grep -o -P "(?<=ROOT_PASSWD=).*(?=$)" | wc -l) -gt 0 ]]; then
				echo -n "Verify...";
				MYSQL_PASSWORD=$( cat /opt/tacacsgui/web/api/config.php 2>/dev/null | grep -o -P "(?<=ROOT_PASSWD=).*(?=$)" );
				if [[ $(check_mysql_root $MYSQL_PASSWORD) -ne 0 ]]
				then
					echo "Success";
					break;
				else
					echo "Password Found, BUT INCORRECT!";
				fi
			else
				echo "Not Found";
			fi
			echo -n 'Try to get from fresh install...';
			if [[ -f ${MAIN_PATH}/tmp/.tgui_mysql ]]; then
				echo -n "Verify...";
				echo "cat ${MAIN_PATH}/tmp/.tgui_mysql"
				MYSQL_PASSWORD=$( cat ${MAIN_PATH}/tmp/.tgui_mysql );
				if [[ $(check_mysql_root $MYSQL_PASSWORD) -ne 0 ]]
				then
					REMEMBER_ROOT_PASSWD='1'
					echo "Success";
				else
					echo "Password Found, BUT INCORRECT!";
				fi
			fi
			MYSQL_ROOT_TRY=1;
		fi
		if [[ $REMEMBER_ROOT_PASSWD == '0' ]]; then
			echo -n 'Enter root password to mysql: ';
			stty -echo; read MYSQL_PASSWORD; stty echo; echo;
			if [[ $(check_mysql_root $MYSQL_PASSWORD) -eq 0 ]]
			then
				error_message 'Incorrect MYSQL root password! Exit.'
				echo; echo -n 'Try one more time? (y/n): '; read DECISION;
				if [ "$DECISION" == "${DECISION#[Yy]}" ]; then
					read -n 1 -s -r -p "Press any key to exit...";
					exit 0;
				else
					continue;
				fi
			fi
			echo 'Done. Correct password'

			echo -n 'Remember root password? (y/n): '; read DECISION;
			if [ "$DECISION" != "${DECISION#[Yy]}" ]; then
				REMEMBER_PASSWD=$MYSQL_PASSWORD;
				echo "Root Password Saved";
			fi
		else
			REMEMBER_PASSWD=$MYSQL_PASSWORD;
			echo "Root Password Saved";
		fi
		break;
	done

	###CHECK DATABASE EXISTENCE###
	echo -n 'Test existence of tgui database...'
	if [[ $(check_database_existence $MYSQL_PASSWORD tgui) -eq 0 ]]
	then
		echo "CREATE DATABASE tgui;" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
		echo 'tgui database was created'
	else
		echo 'Already created'
		if [[ $(check_mysql_tgui_logging $MYSQL_PASSWORD) -gt 0 ]]; then
			echo -n "Create copy of logging tables..."
			BACKUP_NAME=$(date '+%Y-%m-%d_%H:%M:%S');
			mysqldump -uroot -p${MYSQL_PASSWORD} tgui tac_log_accounting tac_log_authentication tac_log_authorization api_logging > ./tmp/${BACKUP_NAME}_log.sql 2>/dev/null
			echo "Done. (./tmp/${BACKUP_NAME}_log.sql)"
		fi
	fi

	echo -n 'Test existence of tgui_log database...'
	if [[ $(check_database_existence $MYSQL_PASSWORD tgui_log) -eq 0 ]]
	then
		echo "CREATE DATABASE tgui_log;" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
		echo 'tgui_log database was created'
		ls ./tmp/ -utl | grep -E "*_log.sql" | awk {'print $9'} | head -n 1
		if [[ $(ls ./tmp/ -utl | grep -E "*_log.sql" | awk {'print $9'} | wc -l) -gt 0 ]]; then
			mysqldump -uroot -p${MYSQL_PASSWORD} tgui tac_log_accounting tac_log_authentication tac_log_authorization api_logging > ./tmp/${BACKUP_NAME}_log.sql 2>/dev/null
			echo "Restore log tables from backup...$(ls ./tmp/ -utl | grep -E "*_log.sql" | awk {'print $9'} | head -n 1)";
			mysql -utgui_user -p${MYSQL_PASSWORD} tgui_log < ./tmp/$(ls ./tmp/ -utl | grep -E "*_log.sql" | awk {'print $9'} | head -n 1) 2>/dev/null;
			echo -n "Drop old log tables..."
			drop_tgui_logging ${MYSQL_PASSWORD}
			echo "...Done"
		fi
	else
		echo 'Already created'
	fi
	###CHECK DATABASE USER EXISTANCE###
echo "
###############################################
  Caution! Attention!
  The passwords of DB Users
  will be stored in clear text inside
  /opt/tacacsgui/web/api/config.php
###############################################
";
	echo "Check existence of tgui_user. "
	if [ $(check_mysql_user_existence $MYSQL_PASSWORD tgui_user) -eq 0 ]; then
		# echo -n 'Enter password to tgui_user (if empty, root passwd will be used): ';
		# stty -echo; read MYSQL_USER_PASSWORD; stty echo; echo;
		# if [ -z "$MYSQL_USER_PASSWORD" ]; then
		# 	echo 'Root password is used'
		# 	MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
		# fi
			MYSQL_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9_-~' | fold -w 32 | head -n 1)
			#SHOW GRANTS FOR 'tgui_user'@'localhost';
			echo "GRANT ALL ON tgui.* TO 'tgui_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
			echo "GRANT ALL ON tgui_log.* TO 'tgui_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
			echo 'MYSQL user tgui_user was created'
	else
		echo 'Already created'
		if [[ SILENT == '0' ]]; then
			echo -n "It seems like you already have installed version. Do you want to continue? [y/n]: "; read DECISION;
			if [ "$DECISION" == "${DECISION#[Yy]}" ]; then
				read -n 1 -s -r -p "Press any key to exit...";
				exit 0;
			fi
		fi
		if [ -f /opt/tacacsgui/web/api/config.php ]; then
			cp /opt/tacacsgui/web/api/config.php /tmp/config.php
			MYSQL_USER_PASSWORD=$(php -r 'include "/opt/tacacsgui/web/api/config.php"; echo DB_PASSWORD;')
			echo "Old configuration saved (/tmp/config.php)";
			# if [ -z "$MYSQL_USER_PASSWORD" ]; then
			# 	MYSQL_USER_PASSWORD=$( cat /opt/tacacsgui/web/api/config.php 2>/dev/null | grep -o -P "(?<=DB_PASSWORD',\s').*(?='\);)" );
			# 	if [ -z "$MYSQL_USER_PASSWORD" ]; then
			# 		MYSQL_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9_-~' | fold -w 32 | head -n 1)
			# 		# echo; echo -n 'Enter password to tgui_user (if empty, root passwd will be used): ';
			# 		# stty -echo; read MYSQL_USER_PASSWORD; stty echo; echo;
			# 		# if [ -z "$MYSQL_USER_PASSWORD" ]; then
			# 		# 	echo 'Root password is used... '
			# 		# 	MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
			# 		# fi
			# 	fi
			# fi
			echo 'Database user password was saved'
		fi
	fi
	echo -n "Check User Grants...";

	if [ $(check_mysql_user_grants $MYSQL_PASSWORD tgui_user tgui) -eq 0 ]; then
		# if [ -z "$MYSQL_USER_PASSWORD" ]; then
		# 	MYSQL_USER_PASSWORD=$( cat /opt/tacacsgui/web/api/config.php 2>/dev/null | grep -o -P "(?<=DB_PASSWORD',\s').*(?='\);)" );
		# 	if [ -z "$MYSQL_USER_PASSWORD" ]; then
		# 		MYSQL_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9_-~' | fold -w 32 | head -n 1)
		# 		# echo; echo -n 'Enter password to tgui_user (if empty, root passwd will be used): ';
		# 		# stty -echo; read MYSQL_USER_PASSWORD; stty echo; echo;
		# 		# if [ -z "$MYSQL_USER_PASSWORD" ]; then
		# 		# 	echo 'Root password is used... '
		# 		# 	MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
		# 		# fi
		# 	fi
		# fi
		echo "GRANT ALL ON tgui.* TO 'tgui_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null;
		echo -n "Added for DB tgui..."
	fi
	if [ $(check_mysql_user_grants $MYSQL_PASSWORD tgui_user tgui_log) -eq 0 ]; then
		if [ -z "$MYSQL_USER_PASSWORD" ]; then
			MYSQL_USER_PASSWORD=$( cat /opt/tacacsgui/web/api/config.php 2>/dev/null | grep -o -P "(?<=DB_PASSWORD',\s').*(?='\);)" );
			if [ -z "$MYSQL_USER_PASSWORD" ]; then
				MYSQL_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9_-~' | fold -w 32 | head -n 1)
				# echo; echo -n 'Enter password to tgui_user (if empty, root passwd will be used): ';
				# stty -echo; read MYSQL_USER_PASSWORD; stty echo; echo;
				# if [ -z "$MYSQL_USER_PASSWORD" ]; then
				# 	echo 'Root password is used... '
				# 	MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
				# fi
			fi
		fi
		echo "GRANT ALL ON tgui_log.* TO 'tgui_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null;
		echo -n "Added for DB tgui_log..."
	fi
	echo "Done"
	# echo "Check existence of tgui_replication. "
	# if [ $(check_mysql_user_existence $MYSQL_PASSWORD tgui_replication) -eq 0 ]; then
	# 	if [ -z "$MYSQL_USER_PASSWORD" ]; then
	# 		echo 'Root password is used'
	# 		MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
	# 	fi
	# 		echo "GRANT REPLICATION SLAVE ON tgui.* TO 'tgui_replication'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"  | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
	# 		echo "GRANT ALL ON tgui_log.* TO 'tgui_replication'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" | mysql -uroot -p${MYSQL_PASSWORD} 2>/dev/null
	# 		echo 'MYSQL user tgui_replication was created'
	# else
	# 	echo 'Already created'
	# fi
	###Creating main directory###
	echo -n "Check main directory /opt/tacacsgui ";

	if [ ! -d /opt/tacacsgui/ ]; then
		echo "... Creating directory";
		mkdir /opt/tacacsgui
	else
		echo "... Already Created";
	fi
	chown www-data:www-data -R /opt/tacacsgui
	if [ $(ls -la /opt/tacacsgui/ | wc -l) -gt 3 ]; then
		if [[ SILENT == '0' ]]; then
			echo -n "Directory /opt/tacacsgui doesn't empty. Delete all files? (if no, script exit) [y/n]: "; read DECISION;
			if [ "$DECISION" == "${DECISION#[Yy]}" ]; then
				read -n 1 -s -r -p "Press any key to exit...";
				exit 0;
			fi
		fi
		if [ -f '/opt/tacacsgui/tac_plus.cfg' ]; then
			cp /opt/tacacsgui/tac_plus.cfg /tmp/tac_plus.cfg
			echo "Old configuration saved! (tac_plus.cfg)";
		fi
		rm -R /opt/tacacsgui/* --force
		rm -Rf /opt/tacacsgui/.* 2> /dev/null
	fi
	echo "Download latest version..."
	sudo -u  www-data git -C /opt/tacacsgui clone https://github.com/tacacsgui/tacacsgui /opt/tacacsgui
	chmod 774 /opt/tacacsgui/main.sh /opt/tacacsgui/backup.sh /opt/tacacsgui/tac_plus.sh
	chmod 777 /opt/tacacsgui/parser/tacacs_parser.sh
	sudo -u  www-data touch /opt/tacacsgui/tacTestOutput.txt
	sudo -u  www-data touch /opt/tacacsgui/tac_plus.cfg
	sudo -u  www-data touch /opt/tacacsgui/tac_plus.cfg_test
	sudo -u  www-data chmod 666 /opt/tacacsgui/tac_plus.cfg*
	sudo -u  www-data chmod 666 /opt/tacacsgui/tacTestOutput.txt
	sudo -u  www-data composer update -d /opt/tacacsgui/web/api
	sudo -u  www-data composer install -d /opt/tacacsgui/web/api
	echo "Download python libraries..."
	umask 022
	sudo pip install sqlalchemy alembic mysqlclient pexpect pyyaml argparse pyotp gitpython
	echo "Update python libraries..."
	python3 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | while read line; do \
			if [[ $line == 'pycurl' ]] || [[ $line == 'pygobject' ]]; then
				continue
			fi
			sudo pip install --upgrade "${line}"; \
		done
	echo "Time to create certificate for https support...";
	if [ ! -d "/opt/tgui_data/ssl" ]; then
		mkdir -p /opt/tgui_data/ssl
	fi
	if [ ! -f '/opt/tgui_data/ssl/tacacsgui.local.cer' ] || [ ! -f '/opt/tgui_data/ssl/tacacsgui.local.key' ]; then
		sudo openssl req -subj '/CN=domain.com/O=My./C=US' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /opt/tgui_data/ssl/tacacsgui.local.key -out /opt/tgui_data/ssl/tacacsgui.local.cer
		echo -n "Done."
	else
		echo -n "Already created."
	fi
	###GENERATE CONFIGURATION FILE###
	echo 'Generate config.php';
	if [ -f /tmp/config.php ]; then
		cp /tmp/config.php /opt/tacacsgui/web/api/config.php
		echo 'Restoring old config.php'
		if [[ $(cat /opt/tacacsgui/web/api/config.php | grep DB_NAME_LOG | wc -l) -eq 0 ]]; then
			echo "define('DB_NAME_LOG', 'tgui_log');" >> /opt/tacacsgui/web/api/config.php;
		fi
	else
		if [ -z "$MYSQL_USER_PASSWORD" ]; then
			echo -n 'Enter password to tgui_user (if empty, root passwd will be used): ';
			stty -echo; read MYSQL_USER_PASSWORD; stty echo; echo;
			if [ -z "$MYSQL_USER_PASSWORD" ]; then
				MYSQL_USER_PASSWORD=$MYSQL_PASSWORD
			fi
		fi
		cp /opt/tacacsgui/web/api/config_example.php /opt/tacacsgui/web/api/config.php
		MYSQL_USER_PASSWORD=$(echo ${MYSQL_USER_PASSWORD} | sed -e 's/[\/&]/\\&/g');
		sed -i "s/<datatabase_passwd_here>/$MYSQL_USER_PASSWORD/g" /opt/tacacsgui/web/api/config.php
	fi

	if [[ ! -z $REMEMBER_PASSWD ]]; then
		sed -i '/ROOT_PASSWD=/d' /opt/tacacsgui/web/api/config.php;
		echo "//ROOT_PASSWD=$REMEMBER_PASSWD" >> /opt/tacacsgui/web/api/config.php;
	fi
	###PREPARING APACHE2###
	echo "Preparing apache configuration";

	if [ ! -d /var/log/tacacsgui/apache2/ ]; then
		mkdir -p /var/log/tacacsgui/apache2
	fi
	service apache2 start
	cp $APACHE_FILES_DIR/tacacsgui.local* /etc/apache2/sites-available/
	sudo a2enmod rewrite
	service apache2 reload
	sudo a2enmod ssl
	sudo service apache2 reload
	sudo a2enmod xsendfile
	sudo service apache2 reload
	a2ensite tacacsgui.local.conf
	service apache2 reload
	a2ensite tacacsgui.local-ssl.conf
	service apache2 reload
###TAC_PLUS DAEMON SETUP###
	echo "Tacacs Daemon setup..."
	if [[ ! -f /etc/init/tac_plus.conf ]]; then
		touch /etc/init/tac_plus.conf
		echo '#tac_plus daemon
		description "tac_plus daemon"
		author "Marc Huber"
		start on runlevel [2345]
		stop on runlevel [!2345]
		respawn
		# Specify working directory
		chdir /opt/tacacsgui
		exec tac_plus.sh' > /etc/init/tac_plus.conf;
		cp /opt/tacacsgui/tac_plus.sh /etc/init.d/tac_plus
		sudo systemctl enable tac_plus
		echo "Daemon apploaded";
	fi
	echo -n "Test Daemon work...";
	if [ -f '/tmp/tac_plus.cfg' ]; then
		cp /tmp/tac_plus.cfg /opt/tacacsgui/tac_plus.cfg;
		echo "Old configuration repaired";
	elif [[ $(service tac_plus status 2>/dev/null | grep "active (running)" | wc -l) -eq 0 ]]; then
		cat $TACACS_CONF_TEST > /opt/tacacsgui/tac_plus.cfg
		service tac_plus start
		sleep 2
		if [[ $(service tac_plus status | grep "Active: active (running)" | wc -l) -eq 0 ]]; then
			echo;
			error_message "Tacacs Daemon Service Error!!!";
			read -n 1 -s -r -p "Press any key to exit...";
			exit 0;
		fi
		service tac_plus stop
		#echo -n > /opt/tacacsgui/tac_plus.cfg;
	else
		echo -n "Already running..."
	fi
	echo "Done";
###tgui_data###
	if [ ! -d "/opt/tgui_data/backups" ]; then
		mkdir -p /opt/tgui_data/backups
	fi
	if [ ! -d "/opt/tgui_data/ha" ]; then
		mkdir -p /opt/tgui_data/ha
	fi
	if [ ! -f /opt/tgui_data/ha/ha.yaml ]; then
		touch /opt/tgui_data/ha/ha.yaml
		echo -n '[]' > /opt/tgui_data/ha/ha.yaml
	fi
	if [ ! -d "/opt/tgui_data/confManager/configs" ]; then
		mkdir -p /opt/tgui_data/confManager/configs
	fi
	if [ ! -f /opt/tgui_data/confManager/config.yaml ]; then
		touch /opt/tgui_data/confManager/config.yaml
		echo -n '[]' > /opt/tgui_data/confManager/config.yaml
	fi
	if [ ! -f /opt/tgui_data/confManager/cron.yaml ]; then
		touch /opt/tgui_data/confManager/cron.yaml
		echo -n '[]' > /opt/tgui_data/confManager/cron.yaml
	fi
	chown www-data:www-data -R /opt/tgui_data
###FINAL CHECK###
	echo -n 'Final Check...';
	echo -n 'Check main libraries...'

	if [ ! -d /opt/tacacsgui/web/api/vendor/slim/ ]; then
		echo;
		error_message "Slim Framework not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ ! -d /opt/tacacsgui/web/api/vendor/slim/ ]; then
		echo;
		error_message "Slim Framework not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ ! -d /opt/tacacsgui/web/api/vendor/illuminate/ ]; then
		echo;
		error_message "Illuminate Database not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ ! -d /opt/tacacsgui/web/api/vendor/respect/ ]; then
		echo;
		error_message "Respect Validation not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ ! -d /opt/tacacsgui/web/api/vendor/respect/ ]; then
		echo;
		error_message "Respect Validation not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	python_libs="$(pip list --format=freeze 2>/dev/null | grep -v '^\-e' | cut -d = -f 1)"

	#echo "${python_libs}"

	if [ $(echo "${python_libs}" | grep 'pexpect' | wc -l) == 0 ]; then
		echo;
		error_message "Pexpect not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ $(echo "${python_libs}" | grep 'SQLAlchemy' | wc -l) == 0 ]; then
		echo;
		error_message "SQLAlchemy not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [ $(echo "${python_libs}" | grep 'PyYAML' | wc -l) == 0 ]; then
		echo;
		error_message "PyYAML not installed!!!";
		read -n 1 -s -r -p "Press any key to exit...";
		exit 0;
	fi

	if [[ -f ${MAIN_PATH}/tmp/.tgui_mysql ]]; then
		rm ${MAIN_PATH}/tmp/.tgui_mysql
	fi

	echo "Done. Congratulation!"

	read -n 1 -s -r -p "Press any key to exit...";
	exit 0;
#fi
