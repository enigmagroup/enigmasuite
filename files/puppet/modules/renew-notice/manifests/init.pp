class renew-notice() {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    file { "/var/www/renew-notice":
        ensure => directory,
        require => File["/var/www"],
    }

    file { "/var/www/renew-notice/index.html":
        source => "puppet:///modules/renew-notice/index.html",
        require => File["/var/www/renew-notice"],
    }

    file { "/etc/nginx/sites-available/renew-notice":
        source => "puppet:///modules/renew-notice/renew-notice.conf",
        require => Package["nginx"],
        notify => Service["nginx"],
    }

    file { "/etc/nginx/sites-enabled/renew-notice":
        ensure => link,
        target => "/etc/nginx/sites-available/renew-notice",
        require => File["/etc/nginx/sites-available/renew-notice"],
        notify => Service["nginx"],
    }

}
