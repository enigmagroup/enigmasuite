#<pre>
node 'box' {

    class {"cjdns":
        ipv6 => "{{ box.ipv6 }}",
        public_key => "{{ box.public_key }}",
        private_key => "{{ box.private_key }}",
        autopeering => "{{ autopeering }}",
{% if allow_peering == '1' and peering_port and peering_password %}
        peering_port => "{{ peering_port }}",
        peering_password => "{{ peering_password }}",
{% endif %}

        connect_to => [
{% if peerings %}{% for peering in peerings %}
            {
                address => "{{ peering.address }}",
                password => "{{ peering.password }}",
                public_key => "{{ peering.public_key }}",
            },
{% endfor %}{% endif %}
        ],

        outgoing_connections => [
{% if peerings %}{% for peering in peerings %}
            "{{ peering.public_key }}",
{% endfor %}{% endif %}
        ],

        puppetmasters => [
{% if puppetmasters %}{% for pm in puppetmasters %}
            "{{ pm.ip }}",
{% endfor %}{% endif %}
        ],
    }

    class {"box-networking":
        addresses => [
{% if addresses %}{% for address in addresses %}
            {
                name => "{{ address.name }}",
                ipv6 => "{{ address.ipv6 }}",
            },
{% endfor %}{% endif %}
        ],

        puppetmasters => [
{% if puppetmasters %}{% for pm in puppetmasters %}
            {
                ip => "{{ pm.ip }}",
                hostname => "{{ pm.hostname }}",
            },
{% endfor %}{% endif %}
        ],

{% if allow_peering == '1' and peering_port %}
        peering_port => "{{ peering_port }}",
{% endif %}
    }

    class {"asterisk":
        addresses => [
{% if addresses %}{% for address in addresses %}{% if address.phone %}
            {
                name => "{{ address.name }}",
                ipv6 => "{{ address.ipv6 }}",
                phone => "{{ address.phone }}",
            },
{% endif %}{% endfor %}{% endif %}
        ],
    }

    class {"email":
        ipv6 => "{{ box.ipv6 }}",
        addresses => [
{% if addresses %}{% for address in addresses %}{% if address.phone %}
            {
                name => "{{ address.name }}",
                ipv6 => "{{ address.ipv6 }}",
            },
{% endif %}{% endfor %}{% endif %}
        ],
    }

    class {"tinyproxy":
    }

}
