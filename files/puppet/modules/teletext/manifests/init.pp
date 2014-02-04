class teletext($teletext_enabled = '') {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    File {
        owner => "root",
        group => "root",
    }

    $packages = [
        "beanstalkd",
        "python-gevent",
        "python-yaml",
        "python-imaging",
    ]

    package { $packages:
        ensure => installed,
        notify => Service["gunicorn"],
    }

    file { "/etc/nginx/sites-available/teletext":
        source => "puppet:///modules/teletext/nginx-site-teletext",
    }

    file { "/etc/default/beanstalkd":
        source => "puppet:///modules/teletext/etc-default-beanstalkd",
    }

    file { "/var/local/enigmasuite/teletext-avatars":
        ensure => directory,
        owner => "www-data",
    }

    if($teletext_enabled == '1'){

        file { "/etc/nginx/sites-enabled/teletext":
            ensure => link,
            target => "/etc/nginx/sites-available/teletext",
            require => File["/etc/nginx/sites-available/teletext"],
            notify => Service["nginx"],
        }

    }else{

        file { "/etc/nginx/sites-enabled/teletext":
            ensure => absent,
            notify => Service["nginx"],
        }

    }

    service { "beanstalkd":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ Package["beanstalkd"], File["/etc/default/beanstalkd"] ],
    }

    service { "gunicorn":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => false,
        require => [ Package["python-yaml"], Package["python-gevent"], Package["python-imaging"] ],
    }

}
