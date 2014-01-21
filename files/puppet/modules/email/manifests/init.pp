class email($ipv6, $addresses, $mailbox_password) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }



    # SOFTWARE

    $software = [
        "exim4",
        "dovecot-common",
        "dovecot-imapd",
        "dovecot-pop3d",
        "php5-fpm",
        "php5-mcrypt",
        "php5-intl",
        "php5-sqlite",
        "php-apc",
        "nginx",
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
        mode => 644,
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

    file { "/etc/php5/conf.d/30-date_timezone.ini":
        source => "puppet:///modules/email/php-date_timezone.ini",
        owner => "root",
        group => "root",
        require => Package["php5-fpm"],
        notify => Service["php5-fpm"],
    }

    file { "/etc/php5/conf.d/30-upload_size.ini":
        source => "puppet:///modules/email/php-upload_size.ini",
        owner => "root",
        group => "root",
        require => Package["php5-fpm"],
        notify => Service["php5-fpm"],
    }

    file { "/etc/php5/fpm/pool.d/www.conf":
        source => "puppet:///modules/email/php-fpm-pool.conf",
        owner => "root",
        group => "root",
        require => Package["php5-fpm"],
        notify => Service["php5-fpm"],
    }

    file { "/var/log/nginx":
        ensure => directory,
    }

    file { "/etc/nginx/sites-available/roundcube":
        source => "puppet:///modules/email/roundcube.conf",
        require => Package["nginx"],
        notify => Service["nginx"],
    }

    file { "/etc/nginx/sites-enabled/roundcube":
        ensure => link,
        target => "/etc/nginx/sites-available/roundcube",
        require => File["/etc/nginx/sites-available/roundcube"],
        notify => Service["nginx"],
    }

    file { "/etc/nginx/sites-enabled/default":
        ensure => absent,
        notify => Service["nginx"],
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

    service { "php5-fpm":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["php5-fpm"],
    }

    service { "nginx":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ Package["nginx"], File["/var/log/nginx"] ],
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
