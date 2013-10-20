class box-networking($puppetmasters = '', $addresses = '', $peering_port = '') {

    File {
        owner => "root",
        group => "root",
    }

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/etc/hosts":
        content => template("box-networking/hosts.erb"),
        notify => Service["dnsmasq"],
    }

    file { "/usr/sbin/rebuild-iptables":
        mode => 755,
        content => template("box-networking/iptables.erb"),
    }

    exec { "reload iptables":
        command => "/usr/sbin/rebuild-iptables",
        subscribe => File["/usr/sbin/rebuild-iptables"],
        refreshonly => true,
    }

    file { "/etc/rc.local":
        source => "puppet:///modules/box-networking/rc.local",
    }

    package { "dnsmasq":
        ensure => installed,
    }

    file { "/etc/dnsmasq.conf":
        source => "puppet:///modules/box-networking/dnsmasq.conf",
        require => Package["dnsmasq"],
    }

    service { "dnsmasq":
        ensure => running,
        enable => true,
        hasrestart => true,
        require => File["/etc/dnsmasq.conf"],
    }

    package { "isc-dhcp-server":
        ensure => installed,
    }

    file { "/etc/dhcp/dhcpd.conf":
        source => "puppet:///modules/box-networking/dhcpd.conf",
        notify => Service["isc-dhcp-server"],
        require => Package["isc-dhcp-server"],
    }

    file { "/etc/dhcp/dhclient.conf":
        source => "puppet:///modules/box-networking/dhclient.conf",
    }

    exec { "renew dhcp for nameservers":
        command => "dhclient eth0",
        subscribe => File["/etc/dhcp/dhclient.conf"],
        refreshonly => true,
    }

    service { "isc-dhcp-server":
        ensure => running,
        enable => true,
        hasrestart => true,
        require => File["/etc/dhcp/dhcpd.conf"],
    }

}
