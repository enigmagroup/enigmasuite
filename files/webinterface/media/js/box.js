(function(){
    $('.confirmation').click(function(){
        return confirm('Bist Du sicher?');
    });
    setInterval(function(){
        $('.puppet-output').load('/puppet_output/');
    }, 500);
})();
