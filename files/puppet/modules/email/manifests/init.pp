class email($ipv6, $addresses) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }



    # SOFTWARE

    $software = [
        "exim4",
        "dovecot-common",
        "dovecot-imapd",
        "dovecot-pop3d",
    ]

    package { $software:
        ensure => installed,
    }



    # FILES

#    file { "/box/vmail":
#        ensure => directory,
#        owner => "vmail",
#        group => "vmail",
#        require => User["vmail"],
#    }

    file { "/etc/dovecot/dovecot.conf":
        source => "puppet:///modules/email/dovecot.conf",
        owner => "dovecot",
        group => "dovecot",
        require => Package["dovecot-common"],
        notify => Service["dovecot"],
    }

    file { "/etc/dovecot/users.conf":
        content => template("email/users.conf.erb"),
        owner => "root",
        group => "root",
        require => Package["dovecot-common"],
        notify => Service["dovecot"],
    }

    file { "/etc/exim4/exim4.conf":
        content => template("email/exim4.conf.erb"),
        owner => "root",
        group => "root",
        require => Package["exim4"],
        notify => Service["exim4"],
    }



    # SERVICES

    service { "exim4":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["exim4"],
    }

    service { "dovecot":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["dovecot-common"],
    }



    # USERS

#    group { "vmail":
#        gid => 5000,
#    }

#    user { "vmail":
#        ensure => present,
#        uid => 5000,
#        gid => "vmail",
#        home => "/box/vmail",
#        comment => "virtual mail user",
#        managehome => true,
#        require => Group["vmail"],
#    }

}
