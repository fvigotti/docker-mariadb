#!/bin/bash

ZABBIX_PIDFILE="/var/log/zabbix/zabbix_server.pid"

# default USER=root
USER=${USER:-root}

PWGENERATED_PASSWORD=""

# generate password password
[[ "${PASS}" == "pwgen" || -z "${PASS}" ]] && {
    PASS=$(pwgen -s -1 16)
    PWGENERATED_PASSWORD="1"
}

# test connection params, passwordless or with password
# return the "-u$username -p$password" required on mysql connections commands
mysql_get_user_and_pass_params(){
mysql -u$USER  -e  "" 1>/dev/null 2>&1 ; [[ $? -eq 0 ]] && {
    echo "-u $USER"
    } || {
        mysql -u$USER -p${PASS}  -e  "" 1>/dev/null 2>&1 ; [[ $? -eq 0 ]] && {
            echo "-u$USER -p$PASS "
        } || {
            echo "INVALID USERNAME OR PASSWORD PARAMS : -u$USER -p$PASS " >&2
            exit 1
        }
    }
}


mysql_pre_start_action() {
:
}
mysql_start_action() {
 mysqld_safe &
 return $$
}
mysql_post_start_action() {
:
}
final_actions() {
:
}

wait_for_mysql_to_start() {
  echo 'wait_for_mysql_to_start'

  # Wait for mysql to finish starting up first.
  while [[ ! -e /run/mysqld/mysqld.sock ]] ; do
      inotifywait -q -e create /run/mysqld/ >> /dev/null
  done
  echo "mysql started"
  return 0
}

stop_mysql() {
echo 'stop mysql command start '`date`' -u '"${USER}"'  -p '"${PASS}"
USER_AND_PASS=$(mysql_get_user_and_pass_params)
mysqladmin $USER_AND_PASS shutdown &
echo 'stop mysql command done '`date`

}

wait_for_mysql_to_stop() {
  echo 'wait_for_mysql_to_stop... '

  # Wait for mysql to finish starting up first.
  while [[ -e /run/mysqld/mysqld.sock ]] ; do
      inotifywait -q -e delete /run/mysqld/ >> /dev/null
  done
  echo "mysql stopped"
  return 0

}

# local action allows TRAP to catch signaling
wait_for_mysql_to_stop_local_action() {
  echo 'wait_for_mysql_to_stop... '

  # Wait for mysql to finish starting up first.
  while [[ -e /run/mysqld/mysqld.sock ]] ; do
      echo 'start detached inotify'
      inotifywait -q -e delete /run/mysqld/ >> /dev/null &
      COMMAND_PID=$!
      echo 'inotify pid = '$COMMAND_PID
      wait $COMMAND_PID || {
       echo 'inotify wait failed!'$?
       return 1
      }
  done
  echo "mysql stopped"
  return 0

}


if [[ -e /firstrun ]]; then
  echo " FIRST RUN"
  source /scripts/first_run.sh
else
  echo " NORMAL RUN"
  source /scripts/normal_run.sh
fi



clean_up() {
# Perform program exit housekeeping
echo '[TRAPPED] '$1' closing mysql';
stop_mysql
wait_for_mysql_to_stop
exit 0
}

# capture signals
trap "clean_up SIGHUP" SIGHUP
trap "clean_up SIGINT" SIGINT
trap "clean_up SIGTERM" SIGTERM
trap "clean_up SIGKILL" SIGKILL


mysql_pre_start_action
mysql_start_action && MYSQL_PID=$?
echo 'mysqld started , pid = '$MYSQL_PID
wait_for_mysql_to_start
mysql_post_start_action
final_actions







echo "wait start"
wait_for_mysql_to_stop_local_action
echo "wait ended"

