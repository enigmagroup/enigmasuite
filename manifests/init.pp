class enigmasuite() {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    file { "/var/local/enigmasuite":
        ensure => directory,
    }

    file { "/var/local/enigmasuite/puppet.tar.gz":
        source => "puppet:///modules/enigmasuite/puppet.tar.gz",
        require => File["/var/local/enigmasuite"],
        notify => Service["enigmasuite"],
    }

    file { "/var/local/enigmasuite/webinterface.tar.gz":
        source => "puppet:///modules/enigmasuite/webinterface.tar.gz",
        require => File["/var/local/enigmasuite"],
        notify => Service["enigmasuite"],
    }

    package { "sudo":
        ensure => installed,
    }

    package { "curl":
        ensure => installed,
    }

    file { "/etc/sudoers.d/enigmasuite":
        source => "puppet:///modules/enigmasuite/etc-sudoers.d-enigmasuite",
        mode => "0440",
        require => Package["sudo"],
    }

    package { "python-requests":
        ensure => installed,
    }

    package { "python-django":
        ensure => installed,
    }

    package { "python-django-south":
        ensure => installed,
        require => Package["python-django"],
    }

    package { "gunicorn":
        ensure => installed,
        require => [ File["/var/local/enigmasuite/webinterface.tar.gz"], File["/etc/sudoers.d/enigmasuite"] ]
    }

    file { "/etc/gunicorn.d/enigmasuite":
        source => "puppet:///modules/enigmasuite/gunicorn.d-enigmasuite",
        require => Package["gunicorn"],
        notify => Service["enigmasuite"],
    }

    file { "/etc/init.d/enigmasuite":
        source => "puppet:///modules/enigmasuite/enigmasuite-initscript",
        require => [ Package["gunicorn"], Package["python-django-south"] ],
        mode => 755,
    }

    service { "enigmasuite":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ File["/etc/init.d/enigmasuite"], File["/var/local/enigmasuite/puppet.tar.gz"] ],
    }

    file { "/usr/local/sbin/puppet-apply":
        source => "puppet:///modules/enigmasuite/puppet-apply",
        mode => 755,
        require => Service["enigmasuite"],
    }

    exec { "puppet apply":
        command => "puppet-apply -s 30 -r &",
        require => [ File["/usr/local/sbin/puppet-apply"], Package["curl"] ],
    }

}
