class tinyproxy(
    $filter_ads = '',
    $filter_headers = '',
    $set_browser = 'none',
    $block_facebook = '',
    $block_google = '',
    $block_twitter = '',
    $custom_rules = '',
    $custom_rules_text = '',
    ) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    File {
        owner => "root",
        group => "root",
    }

    package { "tinyproxy":
        ensure => installed,
    }

    file { "/etc/tinyproxy.conf":
        content => template("tinyproxy/tinyproxy.conf.erb"),
        notify => Service["tinyproxy"],
        require => Package["tinyproxy"],
    }

    file { "/etc/filter":
        content => template("tinyproxy/filter.erb"),
        notify => Service["tinyproxy"],
        require => Package["tinyproxy"],
    }

    service { "tinyproxy":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => false,
        require => File["/etc/tinyproxy.conf"],
    }

#    exec { "transparent fw rule eth1 port 80":
#        command => "iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 8888 &>/dev/null",
#        onlyif => "test `iptables -L -n -v -t nat | grep 8888 | grep eth1 | grep 80 | wc -l` -eq 0",
#    }
#
#    exec { "transparent fw rule eth2 port 80":
#        command => "iptables -t nat -A PREROUTING -i eth2 -p tcp --dport 80 -j REDIRECT --to-port 8888 &>/dev/null",
#        onlyif => "test `iptables -L -n -v -t nat | grep 8888 | grep eth2 | grep 80 | wc -l` -eq 0",
#    }

    # note: transparent SSL doesn't work! browser has to know that it's using a proxy.
    # see http://www.faultserver.com/q/answers-howto-create-a-transparent-https-proxy-with-firehol-and-tinyproxy-447166.html

}
