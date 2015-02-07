class upgrader() {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    file { "/etc/enigmabox":
        ensure => directory,
    }

    file { "/etc/enigmabox/rsa-pubkey.pem":
        source => "puppet:///modules/upgrader/rsa-pubkey.pem",
    }

}
