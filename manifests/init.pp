class enigmasuite() {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

    file { "/etc/apt/apt.conf.d/99translations":
        source => "puppet:///modules/enigmasuite/99translations",
    }

    file { "/usr/local/sbin/housekeeping.sh":
        source => "puppet:///modules/enigmasuite/housekeeping.sh",
        mode => 755,
    }

    cron {"housekeeping":
        command => "/usr/local/sbin/housekeeping.sh &> /dev/null",
        user => root,
        hour => '4',
        minute => '40',
    }

    cron {"apt-update":
        command => "/usr/bin/apt-get update &> /dev/null",
        ensure => absent,
    }

    # remove old crontab (puppet-unmanaged, we need to hide the output)
    exec { "crontab -r":
        onlyif => "test `crontab -l | egrep '33.*/usr/sbin/ntpdate pool.ntp.org' | wc -l` -gt 0",
    }

    cron {"timesync":
        command => "/usr/sbin/ntpdate pool.ntp.org &> /dev/null",
        user => root,
        hour => '1',
        minute => '35',
    }

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

    file { "/var/local/enigmasuite/teletext.tar.gz":
        source => "puppet:///modules/enigmasuite/teletext.tar.gz",
        require => File["/var/local/enigmasuite"],
        notify => Service["enigmasuite"],
    }

    file { "/var/local/enigmasuite/roundcube.tar.gz":
        source => "puppet:///modules/enigmasuite/roundcube.tar.gz",
        require => File["/var/local/enigmasuite"],
        notify => Service["roundcube"],
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

    package { "nginx":
        ensure => installed,
    }

    file { "/var/www":
        ensure => directory,
    }

    file { "/etc/init.d/nginx":
        source => "puppet:///modules/enigmasuite/nginx-initd",
        mode => 755,
        owner => "root",
        group => "root",
    }

    file { "/var/log/gunicorn":
        ensure => directory,
        owner => "www-data",
        group => "www-data",
    }

    file { "/etc/logrotate.conf":
        source => "puppet:///modules/enigmasuite/logrotate.conf",
        owner => "root",
        group => "root",
    }

    file { "/etc/nginx/sites-enabled/default":
        ensure => absent,
        notify => Service["nginx"],
    }

    file { "/etc/nginx/sites-available/enigmasuite":
        source => "puppet:///modules/enigmasuite/enigmasuite.conf",
        require => Package["nginx"],
        notify => Service["nginx"],
    }

    file { "/etc/nginx/sites-enabled/enigmasuite":
        ensure => link,
        target => "/etc/nginx/sites-available/enigmasuite",
        require => File["/etc/nginx/sites-available/enigmasuite"],
        notify => Service["nginx"],
    }

    file { "/etc/gunicorn.d/enigmasuite":
        source => "puppet:///modules/enigmasuite/gunicorn.d-enigmasuite",
        require => Package["gunicorn"],
        notify => Service["enigmasuite"],
    }

    file { "/etc/gunicorn.d/teletext":
        source => "puppet:///modules/enigmasuite/gunicorn.d-teletext",
        require => Package["gunicorn"],
        notify => Service["enigmasuite"],
    }

    file { "/etc/init.d/enigmasuite":
        source => "puppet:///modules/enigmasuite/enigmasuite-initscript",
        require => [ Package["gunicorn"], Package["python-django-south"] ],
        mode => 755,
    }

    file { "/etc/init.d/roundcube":
        source => "puppet:///modules/enigmasuite/roundcube-initscript",
        require => File["/var/local/enigmasuite/roundcube.tar.gz"],
        mode => 755,
    }

    service { "enigmasuite":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ File["/etc/init.d/enigmasuite"], File["/var/local/enigmasuite/puppet.tar.gz"] ],
    }

    service { "nginx":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [ Package["nginx"], Service["enigmasuite"], File["/etc/init.d/nginx"] ],
    }

    service { "roundcube":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => File["/etc/init.d/roundcube"],
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
