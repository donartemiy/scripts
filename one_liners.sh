# cheat sheet one_liners

# delete files which has specific size
$ sudo find . -maxdepth 1 -xdev -type f -size +1M -size -3M -delete

# save result of ping
$ ping www.google.fr | while read pong; do echo "$(date): $pong"; done

# Uninstall docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
