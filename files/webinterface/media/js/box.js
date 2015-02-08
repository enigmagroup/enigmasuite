(function(){

    trans = window.translation;

    $('.confirmation').click(function(){
        return confirm(trans['are_you_sure']);
    });

    $unveil = $('.unveil');
    unveil_text = $unveil.data('text');
    $unveil.html('<a href="#">' + trans['show'] + '</a>');
    $unveil.on('click', function(){
        $unveil.html(unveil_text);
        return false;
    });

    $puppet_output = $('.puppet-output');

    if ($puppet_output.length){

        $puppet_output.height(parseInt($(window).height(), 10) - 400);

        if($('#loader-hint').data('value') == 'dry-run'){
            $('.loader').show();
            $('#button-dry-run, #button-run').attr('disabled', 'disabled');
            $('#lockscreen').show();
        }

        if($('#loader-hint').data('value') == 'run'){
            $('.loader').show();
            $('#button-dry-run, #button-run').attr('disabled', 'disabled');
            $('#lockscreen').show();

            setInterval(function(){
                ret = $.post('/api/v1/get_option', {
                    'key': 'config_changed'
                }, function(data){
                    if(data['value'] == 'False'){
                        $('.loader').hide();
                        $('#button-dry-run, #button-run, #button-apply').hide();
                        $('#success').fadeIn();
                        $('#lockscreen').hide();
                    }
                });
            }, 2000);
        }

        prev_data = '';
        setInterval(function(){
            $puppet_output.load('/puppet_output/', function(data){
                if(data != prev_data){
                    $puppet_output.animate({ scrollTop: $('.puppet-output')[0].scrollHeight}, 1000);
                    prev_data = data;
                    if(data.indexOf('Finished catalog run') > -1){
                        $('#button-dry-run, #button-run, #button-apply').removeAttr('disabled');
                        $('.loader').hide();
                        $('#lockscreen').hide();
                    }
                }
            });
        }, 1500);
    }

    var anchor = false;
    var window_href = window.location.href;
    if(window_href.indexOf('#') > -1){
        anchor = window.location.href.split('#')[1];
    }
    if(! anchor) {
        try {
            anchor = $('.nav-tabs li:first a').attr('href').replace('#', '');
        } catch (e) {}
    }

    try {
        $('.nav-tabs a[href=#' + anchor + ']').tab('show');
        $('.nav-tabs a').click(function (e) {
            $(this).tab('show');
        })
    } catch (e) {}

    $('.tooltip-hover').tooltip();

    $('#countrysort').sortable({
        cancel: ".ui-state-disabled",
        placeholder: "ui-state-highlight",
        update: function(ev) {
            var countries = [];
            $('#countrysort button[name=country]').each(function(i, c){
                countries.push($(c).val());
            });
            $.post('/api/v1/set_countries', {
                'countries': countries.join(',')
            });
        }
    });

    $backup_output = $('.backup-output');
    if ($backup_output.length){
        $backup_output.height(parseInt($(window).height(), 10) - 500);

        prev_data = '';
        setInterval(function(){
            $backup_output.load('/backup_output/', function(data){
                if(data != prev_data){
                    $backup_output.animate({ scrollTop: $('.backup-output')[0].scrollHeight}, 1000);
                    prev_data = data;
                }
            });
        }, 1500);
    }

    $btn_blink = $('.btn-blink');
    if ($btn_blink.length){

        var blinkerval = setInterval(function() {
            $btn_blink.addClass('btn-danger');
            setTimeout(function() {
                $btn_blink.removeClass('btn-danger');
            }, 600);
        }, 1200);

    }

    $('#start_upgrade').on('click', function() {
        var self = this;

        if(! confirm(trans['are_you_sure'])) {
            return false;
        }

        setTimeout(function() {
            $(self).attr('disabled', 'disabled');
        }, 10);

        var csrfmiddlewaretoken = $('input[name=csrfmiddlewaretoken]').val();
        $.post('/upgrade/', {
            'csrfmiddlewaretoken': csrfmiddlewaretoken,
            'start_upgrade': '1'
        });

        $('#fw-countdown').modal({
            'backdrop': 'static',
            'keyboard': false,
        });

        clearInterval(blinkerval);

        var remaining_seconds = 60 * 15;
        var total_remaining = remaining_seconds;
        var w = 0;
        setInterval(function() {
            $('.counter').text(remaining_seconds);
            w = Math.floor(100 - (100 / total_remaining * remaining_seconds));
            $('#fw-write-bar').css('width', w + '%');
            remaining_seconds = remaining_seconds - 1;
        }, 1000);

        setTimeout(function() {
            window.location.href = '/';
        }, 1000 * remaining_seconds); //15min for 4GB

        return false;
    });

})();
