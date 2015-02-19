#!/bin/bash

ZABBIX_PIDFILE="/var/log/zabbix/zabbix_server.pid"

# default USER=root
USER=${USER:-root}

PWGENERATED_PASSWORD=""

# generate password password
[[ "${PASS}" == "pwgen" ]] && {
    PASS=$(pwgen -s -1 16)
    PWGENERATED_PASSWORD="1"
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
mysqladmin -u"${USER}" -p"${PASS}" shutdown &
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
wait_for_mysql_to_stop
echo "wait ended"

