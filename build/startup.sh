#!/bin/bash

set -e

################################## VARIABLES ###################################

readonly mainuser_name=${MAINUSER_NAME:-mainuser}
readonly mainuser_nopassword=${MAINUSER_NOPASSWORD:-false}

################### INCLUDE SCRIPTS FROM /opt/startup-early ####################

for i in /opt/startup-early/*.sh; do
    [ -f "$i" ] || continue
    # shellcheck source=/dev/null
    . "$i"
done

################################## MAIN USER ###################################

if [ "$mainuser_name" = root ]; then
    echo 'The main user is root'
    mainuser_home=/root
else
    mainuser_home=/home/$mainuser_name

    # If the user already exists
    if id "$mainuser_name" >/dev/null 2>&1; then
        echo "User $mainuser_name already exists"

        if [ ! -d "$mainuser_home" ]; then
            echo "Creating home directory $mainuser_home"
            install -d -o"$mainuser_name" -g"$mainuser_name" "$mainuser_home"
        fi
    else
        echo "Creating user $mainuser_name"
        useradd -UGsudo -ms/bin/bash "$mainuser_name"
    fi

    if [ "$mainuser_nopassword" = true ]; then
        echo "Enabling sudo without password for user $mainuser_name"
        install -Tm440 <(echo "$mainuser_name ALL=(ALL) NOPASSWD: ALL") \
            "/etc/sudoers.d/$mainuser_name-nopassword"
    fi
fi

################################## X11 STUFF ###################################

install -Tm644 /opt/xfwd/{host,container}.xauth

install -dm777 /tmp/.X11-unix

#################### INCLUDE SCRIPTS FROM /opt/startup-late ####################

for i in /opt/startup-late/*.sh; do
    [ -f "$i" ] || continue
    # shellcheck source=/dev/null
    . "$i"
done

################################# START SOCAT ##################################

echo 'Starting socat'
exec socat UNIX-LISTEN:/tmp/.X11-unix/X0,mode=666,fork,unlink-early \
    UNIX-CONNECT:/opt/xfwd/host.sock
