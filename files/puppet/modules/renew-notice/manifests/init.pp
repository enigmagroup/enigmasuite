class renew-notice($display_expiration_notice = '') {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    file { "/var/www/renew-notice":
        ensure => directory,
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

    file { "/usr/local/sbin/hide_expiration_notice":
        source => "puppet:///modules/renew-notice/hide_expiration_notice",
        mode => 755,
    }

    if($display_expiration_notice == '1'){
        file { "/etc/nginx/sites-enabled/renew-notice":
            ensure => link,
            target => "/etc/nginx/sites-available/renew-notice",
            require => File["/etc/nginx/sites-available/renew-notice"],
            notify => Service["nginx"],
        }
    }else{
        file { "/etc/nginx/sites-enabled/renew-notice":
            ensure => absent,
            notify => Service["nginx"],
        }
    }

}
