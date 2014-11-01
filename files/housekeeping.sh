#!/bin/bash
. /etc/profile

# in case of: "dpkg was interrupted, you must manually run 'dpkg --configure -a' to correct the problem"
/usr/bin/dpkg --configure -a

# flush logs
> /var/log/asterisk/messages
> /var/log/nginx/access.log
> /var/log/nginx/error.log

# stop and kill puppet, it happened sometimes that "a puppet run is already in progress". Fuck you, memory leaking rubycrap!
/etc/init.d/puppet stop
sleep 1
killall puppet
sleep 3
killall -9 puppet
/usr/bin/puppet agent --enable  # remove any lockfiles
rm -r /var/lib/puppet/*         # give us some memory back



if [[ "$1" != "now" ]]; then
    # random sleep between 0000s and 9999s (~3h)
    n=$(head -30 /dev/urandom | tr -dc "0123456789" 2> /dev/null | head -c4)
    echo "sleeping $n seconds"
    sleep $n
fi

# push my address
/usr/local/sbin/addressbook.py push

# dry run puppet-apply, to do apt updates
/usr/local/sbin/puppet-apply

# run puppet, but don't start agent anymore
/usr/bin/puppet agent --test



# restart gunicorn - teletext hangs sometimes
/etc/init.d/gunicorn restart

