#!/bin/bash
. /etc/profile

# in case of: "dpkg was interrupted, you must manually run 'dpkg --configure -a' to correct the problem"
/usr/bin/dpkg --configure -a

# flush logs
> /var/log/asterisk/messages
> /var/log/nginx/access.log
> /var/log/nginx/error.log

# ensure correct directory permissions
chown Debian-exim:Debian-exim -R /var/spool/exim4/

# stop and kill puppet, it happened sometimes that "a puppet run is already in progress". Fuck you, memory leaking rubycrap!
/etc/init.d/puppet stop
sleep 1
killall puppet
sleep 3
killall -9 puppet
/usr/bin/puppet agent --enable  # remove any lockfiles
rm -r /var/lib/puppet/*         # give us some memory back



if [[ "$1" != "now" ]]; then
    # random sleep between 0000s and 6666 (<2h)
    n=$(head -30 /dev/urandom | tr -dc "0123456" 2> /dev/null | head -c4)
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

/usr/bin/apt-get install busybox-static parted -y --force-yes

# stop here if its not an ALIX
[[ $(/bin/uname -m) != "i586" ]] && exit

if [[ $(/sbin/lsmod | grep leds_alix | wc -l) -eq 0 ]]; then
    /usr/bin/apt-get install -y leds-alix-source module-assistant cpp-4.6 gcc-4.6 gcc-4.6-base linux-headers-3.2.0-4-486 linux-headers-3.2.0-4-common linux-kbuild-3.2
    /usr/bin/module-assistant -t a-i leds-alix
    /sbin/modprobe leds-alix
    /sbin/modprobe ledtrig-default-on
    /sbin/modprobe ledtrig-timer
fi

