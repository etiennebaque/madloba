$(document).ready(function(){
    var url = window.location.pathname;
//var urlRegExp = new RegExp(url.replace(/\/$/,'') + "$"); // create regexp to match current url pathname and remove trailing slash if present as it could collide with the link in navigation in case trailing slash wasn't present there
// now grab every link from the navigation
    var urlsplit = url.split('/');
    var page = urlsplit[urlsplit.length - 1]
    $('#userLeftMenuId a').each(function(){
        // and test its normalized href against the url pathname regexp
        var linksplit = this.href.split('/');
        var link = linksplit[linksplit.length - 1];
        if(page == link){
            $(this).parent('li').addClass('active');
        }
    });
});