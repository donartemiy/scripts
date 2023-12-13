# cheat sheet one_liners

# delete files which has specific size
$ sudo find . -maxdepth 1 -xdev -type f -size +1M -size -3M -delete

# save result of ping
$ ping www.google.fr | while read pong; do echo "$(date): $pong"; done
