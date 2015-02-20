# mariadb docker image
run mariadb mysql-server using mysqld_safe command and forwarding 
container shutdown signals through mysqladmin

during the first run phase /var/lib/mysql data is copied to 
$DATA_DIR directory (default: /data ) if that is empty

also the authentication credentials and user permission on $DATA_DIR are refreshed
 
                                                                                                                                                                                  
## Docker hub [fvigotti/mariadb]

[fvigotti/mariadb]: https://registry.hub.docker.com/u/fvigotti/mariadb/
```
$ docker pull fvigotti/mariadb 
```
                                                                                                                                                                    
## Docker build

```
$ docker build -t="fvigotti/mariadb" ./src/ 
```
                                                                                                                                         
## Docker run


``` shell
mkdir -p /tmp/mariadb  
docker run -d --name="mariadb" -p 127.0.0.1:3306:3306  -v /tmp/mariadb:/data -e USER="root" -e PASS="a" fvigotti/mariadb  
```

## Docker run with bootstrap databases example :

<pre>

BOOTSTRAP_DUMP_DIR=/tmp/mariadb_bootstrap
DB_DIR=/tmp/mariadb
rm -Rf $DB_DIR
mkdir -p $DB_DIR  
mkdir -p $BOOTSTRAP_DUMP_DIR  

cat > ${BOOTSTRAP_DUMP_DIR}/001_start.sql &lt&ltEOL
    CREATE DATABASE test_db1 CHARACTER SET utf8;
EOL

cat > ${BOOTSTRAP_DUMP_DIR}/002_mid.sql &lt&ltEOL
    use test_db1;
    CREATE TABLE \`tab_1\` (
    \`maintenanceid\`          bigint unsigned                           NOT NULL,
    \`name\`                   varchar(128)    DEFAULT ''                NOT NULL,
    PRIMARY KEY (maintenanceid)
    ) ENGINE=InnoDB ;
EOL

cat > ${BOOTSTRAP_DUMP_DIR}/003_end.sql &lt&ltEOL
    use test_db1;
    CREATE UNIQUE INDEX \`name_index_2\` ON \`tab_1\` (\`name\`)  ;
EOL


docker run --rm -ti -e "USER=b" -e "PASS=a" -v "${DB_DIR}:/data"  -v "${BOOTSTRAP_DUMP_DIR}:/first_run_dumps" fvigotti/mariadb  
</pre>


## mysql initializations dumps
files contained on directory /first_run_dumps will be loaded during the first_run execution (when database files does not exists in data directory)

```shell
-v /tmp/dumps:/first_run_dumps
```

additional param to load dumps can be set with

```shell
-e "FIRST_RUN_DUMP_LOAD_PARAMS=-D test_database" 
```


## todo

- loadable mysql database initialization/restart dumps from shared volume
- run supervisor as entrypoint and grab command as options in order to reset database password / load dump/ ... or perform other actions as needed 