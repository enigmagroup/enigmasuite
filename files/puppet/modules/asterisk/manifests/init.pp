class asterisk($addresses = '', $global_addresses = '') {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    package { "asterisk":
        ensure => installed,
    }

    file { "/etc/asterisk/sip.conf":
        content => template("asterisk/sip.conf.erb"),
        owner => asterisk,
        require => Package["asterisk"],
        notify => Service["asterisk"],
    }

    file { "/etc/asterisk/extensions.conf":
        content => template("asterisk/extensions.conf.erb"),
        owner => asterisk,
        require => Package["asterisk"],
        notify => Service["asterisk"],
    }

    exec { "fixing etc permissions":
        command => "chown -R asterisk:asterisk /etc/asterisk/",
        onlyif => "test `find /etc/asterisk -user root | wc -l` -gt 0",
    }

    exec { "fixing varlib permissions":
        command => "chown -R asterisk:asterisk /var/lib/asterisk/",
        onlyif => "test `find /var/lib/asterisk -user root | wc -l` -gt 0",
    }

    service { "asterisk":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ File["/etc/asterisk/sip.conf"], File["/etc/asterisk/extensions.conf"], Exec["fixing etc permissions"], Exec["fixing varlib permissions"] ],
    }

}
