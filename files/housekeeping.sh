#!/bin/bash
. /etc/profile

# in case of: "dpkg was interrupted, you must manually run 'dpkg --configure -a' to correct the problem"
/usr/bin/dpkg --configure -a

# update apt
/usr/bin/apt-get update

# flush logs
> /var/log/asterisk/messages
> /var/log/nginx/access.log
> /var/log/nginx/error.log

# restart puppet, it happened sometimes that "a puppet run is already in progress". Fuck you, memory leaking rubycrap!
/etc/init.d/puppet stop
sleep 1
killall puppet
sleep 3
killall -9 puppet
/usr/bin/puppet agent --enable  # remove any lockfiles
rm -r /var/lib/puppet/*     # give us some memory back

# run puppet, but don't start agent anymore
rand=$(($RANDOM % 600))
sleep "$rand"
/usr/bin/puppet agent --test

