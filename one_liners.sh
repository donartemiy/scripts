# cheat sheet one_liners

# delete files which has specific size
$ sudo find . -maxdepth 1 -xdev -type f -size +1M -size -3M -delete

# save result of ping
$ ping www.google.fr | while read pong; do echo "$(date): $pong"; done

# Uninstall docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# heathcheck
$ while true; do time curl -sSf  http://172.21.1.1/-/readinessX; sleep 1; done

# remoove unused strings
grep -v '^ *#\|^ *$' /etc/squid/squid.conf

# get stat CPU for docker container
$ while true; do docker stats app-server --no-stream | grep app-server | awk -v date="$(date +%T)" '{print $3, date}' | sed 's/%//g' >> docker_stats_data.txt; done

# Удаляем все вольюмы без graylog в имени
$ docker volume ls -q | grep -v "graylog" | xargs docker volume rm

# Удаляем выключенные контейнеры, не связанные образы/volumes
$ docker system prune -a -f --volumes
