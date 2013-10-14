class email($ipv6, $addresses) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }



    # SOFTWARE

    $software = [
        "openssl",
        "ca-certificates",
        "libsasl2-2",
        "libsasl2-modules",
        "sasl2-bin",
        "postfix",
        "dovecot-common",
        "dovecot-imapd",
        "dovecot-pop3d",
    ]

    package { $software:
        ensure => installed,
    }



    # FILES

    file { "/box/vmail":
        ensure => directory,
        owner => "vmail",
        group => "vmail",
        require => User["vmail"],
    }

    file { "/etc/postfix/main.cf":
        content => template("email/main.cf.erb"),
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }

    file { "/etc/default/saslauthd":
        source => "puppet:///modules/email/saslauthd",
        owner => "root",
        group => "root",
    }

    file { "/etc/postfix/sasl/smtpd.conf":
        source => "puppet:///modules/email/smtpd.conf",
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }

#    exec { "create ssl certs":
#        command => "printf '\n\n\n\n\$domain\n\n' | openssl req -new -x509 -days 365 -nodes -out /etc/ssl/certs/postfix.pem -keyout /etc/ssl/private/postfix.key",
#        creates => "/etc/ssl/private/postfix.key",
#        require => Package["openssl"],
#    }

    file { "/etc/postfix/virtual_mailbox_domains":
        content => template("email/virtual_mailbox_domains.erb"),
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }

    exec { "postmap hash:/etc/postfix/virtual_mailbox_domains":
        subscribe => File["/etc/postfix/virtual_mailbox_domains"],
        refreshonly => true
    }

    file { "/etc/postfix/virtual_mailbox_maps":
        content => template("email/virtual_mailbox_maps.erb"),
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }

    exec { "postmap hash:/etc/postfix/virtual_mailbox_maps":
        subscribe => File["/etc/postfix/virtual_mailbox_maps"],
        refreshonly => true
    }

    file { "/etc/postfix/virtual_alias_maps":
        content => template("email/virtual_alias_maps.erb"),
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }

    exec { "postmap hash:/etc/postfix/virtual_alias_maps":
        subscribe => File["/etc/postfix/virtual_alias_maps"],
        refreshonly => true
    }

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

    file { "/etc/postfix/master.cf":
        source => "puppet:///modules/email/master.cf",
        owner => "root",
        group => "root",
        require => Package["postfix"],
        notify => Service["postfix"],
    }



    # SERVICES

    service { "saslauthd":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
    }

    service { "postfix":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["postfix"],
    }

    service { "dovecot":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["dovecot-common"],
    }



    # USERS

    group { "vmail":
        gid => 5000,
    }

    user { "vmail":
        ensure => present,
        uid => 5000,
        gid => "vmail",
        home => "/box/vmail",
        comment => "virtual mail user",
        managehome => true,
        require => Group["vmail"],
    }

}
