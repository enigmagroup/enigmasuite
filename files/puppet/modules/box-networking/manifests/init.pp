class box-networking($puppetmasters = '', $addresses = '', $peering_port = '', $teletext_enabled = '', $display_expiration_notice = '', $global_availability = '0') {

    File {
        owner => "root",
        group => "root",
    }

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/etc/hosts":
        content => template("box-networking/hosts.erb"),
        notify => Service["dnsmasq"],
    }

    file { "/etc/display_names":
        content => template("box-networking/display_names.erb"),
    }

    file { "/usr/sbin/rebuild-iptables":
        mode => 755,
        content => template("box-networking/iptables.erb.$hardwaremodel"),
    }

    exec { "reload iptables":
        command => "/usr/sbin/rebuild-iptables",
        subscribe => File["/usr/sbin/rebuild-iptables"],
        refreshonly => true,
    }

    file { "/etc/rc.local":
        source => "puppet:///modules/box-networking/rc.local",
        mode => 755,
    }

    file { "/usr/local/sbin/backup-stuff":
        source => "puppet:///modules/box-networking/backup-stuff",
        mode => 755,
    }

    file { "/usr/local/sbin/restore-stuff":
        source => "puppet:///modules/box-networking/restore-stuff",
        mode => 755,
    }

    package { "dnsmasq":
        ensure => installed,
    }

    package { "bash":
        ensure => latest,
    }

    package { "isc-dhcp-client":
        ensure => latest,
    }

    package { "libc-bin":
        ensure => latest,
    }

    package { "busybox-static":
        ensure => latest,
    }

    file { "/etc/dnsmasq.conf":
        source => "puppet:///modules/box-networking/dnsmasq.conf.$hardwaremodel",
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

#    exec { "renew dhcp for nameservers":
#        command => "dhclient eth0",
#        subscribe => File["/etc/dhcp/dhclient.conf"],
#        refreshonly => true,
#    }

    service { "isc-dhcp-server":
        ensure => running,
        enable => true,
        hasrestart => true,
        require => File["/etc/dhcp/dhcpd.conf"],
    }

}
