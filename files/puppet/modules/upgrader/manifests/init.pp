class upgrader() {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    $packages = [
        "busybox-static",
        "parted",
    ]

    package { $packages:
        ensure => latest,
    }

    file { "/etc/enigmabox":
        ensure => directory,
    }

    file { "/etc/enigmabox/rsa-pubkey.pem":
        source => "puppet:///modules/upgrader/rsa-pubkey.pem",
    }

    file { "/usr/sbin/upgrader":
        source => "puppet:///modules/upgrader/upgrader",
        mode => 755,
    }

}
