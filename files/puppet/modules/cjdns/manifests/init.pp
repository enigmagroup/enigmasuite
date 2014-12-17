class cjdns(
    $private_key,
    $public_key,
    $ipv6,
    $autopeering = '0',
    $peering_port = '57671',
    $peering_password = '',
    $connect_to = '',
    $outgoing_connections = '',
    $puppetmasters = '',
    $wlan_ssid = '',
    $wlan_pass = '',
    $wlan_txpower = '1mW',
    $wlan_rate = '11M',
    $wlan_security = 'WPA',
    $wlan_group = 'TKIP',
    $wlan_pairwise = 'TKIP',
    $network_preference = 'regular',
    ) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    File {
        owner => "root",
        group => "root",
    }

    file { "/box/cjdroute.conf":
        mode => 400,
        content => template("cjdns/cjdroute.conf.erb"),
        notify => [ Service["cjdns"], Service["asterisk"] ],
    }

    file { "/etc/init.d/cjdns":
        source => "puppet:///modules/cjdns/cjdns-initscript",
        mode => 755,
        require => File["/box/cjdroute.conf"],
    }

    file { "/etc/init.d/restart_enigmabox":
        source => "puppet:///modules/cjdns/restart_enigmabox-initscript",
        mode => 755,
    }

    if($network_preference == 'topo128') {

        file { "/usr/sbin/cjdroute":
            source => "puppet:///modules/cjdns/cjdroute-v10.$architecture",
            mode => 755,
            notify => Service["cjdns"],
        }

    } else {

        file { "/usr/sbin/cjdroute":
            source => "puppet:///modules/cjdns/cjdroute.$architecture",
            mode => 755,
            notify => Service["cjdns"],
        }

    }

    service { "restart_enigmabox":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => File["/etc/init.d/restart_enigmabox"],
    }

    service { "cjdns":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ File["/etc/init.d/cjdns"], File["/box/cjdroute.conf"], File["/usr/sbin/cjdroute"] ],
    }

    package { "vnstat":
        ensure => installed,
        require => Service["cjdns"],
    }

    package { ["wireless-tools", "wpasupplicant", "firmware-ralink"]:
        ensure => installed,
    }

    file { "/etc/wpa_supplicant/wpa_supplicant.conf":
        content => template("cjdns/wpa_supplicant.conf.erb"),
    }

    if($outgoing_connections) {

        file { "/usr/local/sbin/setup-cjdns-networking":
            content => template("cjdns/setup-cjdns-networking.erb.$hardwaremodel"),
            mode => 755,
            require => Service["cjdns"],
        }

        cron {"setup enigmabox networking":
            command => "/usr/local/sbin/setup-cjdns-networking &> /dev/null",
            user => root,
            minute => '*',
            require => File["/usr/local/sbin/setup-cjdns-networking"],
        }

    }

}
