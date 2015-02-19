#!/bin/sh

configure_login(){
  # Echo out info to later obtain by running `docker logs container_name`
  echo "MARIADB_USER=$USER"
  echo "MARIADB_PASS=$PASS"
  echo "MARIADB_DATA_DIR=$DATA_DIR"

  # test if DATA_DIR has content
  if [[ ! "$(ls -A $DATA_DIR)" ]]; then
      echo "Initializing MariaDB at $DATA_DIR"
      # Copy the data that we generated within the container to the empty DATA_DIR.
      cp -Rp /var/lib/mysql/* $DATA_DIR
  fi
  echo "chowning $DATA_DIR"
  # Ensure mysql owns the DATA_DIR which may come from another filesystem
  chown -R mysql $DATA_DIR
  chown root $DATA_DIR/debian*.flag
  echo "login configuration , done"
}



set_authentication() {
  echo "set authentication, start"
  # The password for 'debian-sys-maint'@'localhost' is auto generated.
  # The database inside of DATA_DIR may not have been generated with this password.
  # So, we need to set this for our database to be portable.
  DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')
  echo 'DB_MAINT_PASS = '$DB_MAINT_PASS
  USER_AND_PASS=$(mysql_get_user_and_pass_params)
  mysql $USER_AND_PASS -e \
      "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS';"

  # Create the superuser.
  mysql $USER_AND_PASS <<-EOF
      DELETE FROM mysql.user WHERE user = '$USER';
      FLUSH PRIVILEGES;
      CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
      GRANT ALL PRIVILEGES ON *.* TO '$USER'@'localhost' WITH GRANT OPTION;
      CREATE USER '$USER'@'%' IDENTIFIED BY '$PASS';
      GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION;
EOF

  echo "set authentication, done"
}



mysql_pre_start_action(){
    configure_login
}

mysql_post_start_action(){
    set_authentication
    rm /firstrun
}
