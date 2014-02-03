class teletext($teletext_enabled = '') {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    File {
        owner => "root",
        group => "root",
    }

	$enhancers = [
        "beanstalkd",
        "python-bottle",
        "python-gevent",
        "python-yaml",
        "python-imaging",
    ]

	package { $enhancers:
		ensure => installed,
	}

    file { "/etc/nginx/sites-available/teletext":
        source => "puppet:///modules/teletext/nginx-site-teletext",
    }

    if($teletext_enabled == '1'){

        file { "/etc/nginx/sites-enabled/teletext":
            source => "puppet:///modules/teletext/nginx-site-teletext",
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

    service { "nginx":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => false,
    }

}
