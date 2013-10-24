class security(
    $webinterface_password = '',
    $mailbox_password = '',
    $webmail_password = '',
    ) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    File {
        owner => "root",
        group => "root",
    }

    if($webinterface_password != '') {

        file { "/etc/nginx/auth/webinterface.conf":
            content => template("security/webinterface.conf.erb"),
            notify => Service["nginx"],
        }

        file { "/etc/nginx/auth/webinterface.htpasswd":
            content => template("security/webinterface.htpasswd.erb"),
        }

    } else {

        file { "/etc/nginx/auth/webinterface.conf":
            ensure => absent,
            notify => Service["nginx"],
        }

    }

    if($webmail_password != '') {

        file { "/etc/nginx/auth/webmail.conf":
            content => template("security/webmail.conf.erb"),
            notify => Service["nginx"],
        }

        file { "/etc/nginx/auth/webmail.htpasswd":
            content => template("security/webmail.htpasswd.erb"),
        }

    } else {

        file { "/etc/nginx/auth/webmail.conf":
            ensure => absent,
            notify => Service["nginx"],
        }

    }

}
