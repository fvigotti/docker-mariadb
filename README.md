# mariadb docker image
run mariadb mysql-server using mysqld_safe command and forwarding 
container shutdown signals through mysqladmin

during the first run phase /var/lib/mysql data is copied to 
$DATA_DIR directory (default: /data ) if that is empty

also the authentication credentials and user permission on $DATA_DIR are refreshed
 

