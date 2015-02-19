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
$ mkdir -p /tmp/mariadb
$ docker run -d -name="mariadb" \
             -p 127.0.0.1:3306:3306 \
             -v /tmp/mariadb:/data \
             -e USER="root" \
             -e PASS="a" \
             fvigotti/mariadb
```

## todo

loadable mysql database initialization/restart dumps from shared volume