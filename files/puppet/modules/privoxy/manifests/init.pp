class privoxy(
    $filter_ads = '',
    $filter_headers = '',
    $disable_browser_ident = '',
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

    package { "privoxy":
        ensure => installed,
    }

    file { "/etc/privoxy/config":
        content => template("privoxy/config.erb"),
        notify => Service["privoxy"],
        require => Package["privoxy"],
    }

    file { "/etc/privoxy/user.action":
        content => template("privoxy/user.action.erb"),
        notify => Service["privoxy"],
        require => Package["privoxy"],
    }

    service { "tinyproxy":
        ensure => stopped,
        enable => false,
        hasrestart => true,
        hasstatus => false,
    }

    service { "privoxy":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => false,
        require => [ File["/etc/privoxy/config"], Service["tinyproxy"] ],
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
