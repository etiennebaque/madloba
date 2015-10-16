/**
 * Creation of the AdSocket class that holds all the behaviour related to websockets, client side.
 * Websocket-powered communication is used when selecting categories on the guided navigation.
 */
var AdSocket = function() {
    //this.nav_state = new NavState();
    this.nav_state = {
        cat: [],
        q: '',
        item: '',
        lat: '',
        lon: ''
    };
    this.socket = new WebSocket(App.websocket_url+"/websocket");
    this.initBinds();
};

var messagePrefix = {
    refresh_map: 'map',
    add_new_marker: 'new'
}

// Method that turns the current navigation state into a string.
AdSocket.prototype.stringifyState = function() {
    var _this = this;
    var complete_state = '';
    if (_this.nav_state.cat.length > 0){
        complete_state = 'cat='
        complete_state += _this.nav_state.cat.join('+');
    }

    if (_this.nav_state.item != ''){
        complete_state = append_to_state(complete_state, 'item', _this.nav_state.item);
    }
    if (_this.nav_state.q != ''){
        complete_state = append_to_state(complete_state, 'q', _this.nav_state.q);
    }
    if (_this.nav_state.lat != ''){
        complete_state = append_to_state(complete_state, 'lat', _this.nav_state.lat);
    }
    if (_this.nav_state.lon != ''){
        complete_state = append_to_state(complete_state, 'lon', _this.nav_state.lon);
    }
    return complete_state
};

function append_to_state(complete_state, param, value){
    if (complete_state != ''){
        complete_state = complete_state + '&' + param + '=' + value;
    }else{
        complete_state = param + '=' + value;
    }
    return complete_state
}

// Initialisation of the websocket.
AdSocket.prototype.initBinds = function() {
    var _this = this;

    $('#sidebar').on('click', '.guided-nav-category', function(){
        // Copying the html of the selected category and inserting it in the "Selected categories" section.
        var selectedLinkHtml = $(this).clone();
        var link_id = $(this).attr('id');

        if (_this.nav_state.cat.indexOf(link_id) > -1){
            // User is removing this category from the "Your selection" section.
            selectedLinkHtml.find('i.align-cross').remove();
            $('#available_categories').append(selectedLinkHtml.prop('outerHTML'));

            // Deleting the html of the selected category in initial list.
            $(this).remove();

            _this.nav_state.cat = jQuery.grep(_this.nav_state.cat, function(value) {
                return value != link_id;
            });

            if (_this.nav_state.cat.length == 0){
                $('#refinementsId').html('');
            }

        }else{
            // User is selecting this category to refine their search.
            if ($('#refinementsId').html().trim() == ''){
                $('#refinementsId').html('<h4>Your selection</h4>')
            }
            selectedLinkHtml.append("<i class='glyphicon glyphicon-remove align-cross' style='float: right;'></i>");
            $('#refinementsId').append(selectedLinkHtml.prop('outerHTML'));

            // Deleting the html of the selected category in initial list.
            $(this).remove();

            _this.nav_state.cat.push($(this).attr('id'));
        }

        _this.sendNavState(_this.stringifyState());
    });

    // Message sent to server when a new ad has just been created
    // (ie. new ad notification message has been loaded on ads#show)
    $(document).ready(function() {
        var new_ad_id = $('#new_ad_id').val();
        if (typeof new_ad_id != "undefined"){
            console.log($('#new_ad_id').val());
            _this.sendNewAdNotification(new_ad_id);
        }
    });

    this.socket.onmessage = function(e) {
        // We will have a status message in our response:
        // mapok
        // error
        // new_marker
        var response = JSON.parse(e.data);
        var status = response['status'];
        var map_info = response['map_info'];
        var new_nav_state = _this.nav_state;

        switch(status) {
            case "mapok":
                _this.refresh_map(map_info, new_nav_state);
                break;
            case "error":
                _this.error_map(map_info);
                break;
            case "new_ad":
                _this.add_marker(map_info);
                break;
        }

    };
};

// Sending the new navigation state to the server, in order to get the relevant markers and areas.
AdSocket.prototype.sendNavState = function(value) {
    this.socket.send(messagePrefix.refresh_map+value);
};

// Sending a message to the server to notify other users that a new ad has been created, and to display on other users' home page map.
AdSocket.prototype.sendNewAdNotification = function(value) {
    this.send(messagePrefix.add_new_marker+value);
};

// After selection of a category in the guided navigation, we need to refresh the map accordingly.
AdSocket.prototype.refresh_map = function (new_map_info, new_nav_state){
    // First we need to clear all the current layers.
    if (markers.group != ''){
        markers.group.clearLayers();
    }
    if (markers.postal_group != ''){
        markers.postal_group.clearLayers();
    }
    if (markers.district_group != ''){
        markers.district_group.clearLayers();
    }

    // Then we place the different markers and areas.
    if (new_map_info['markers'] != ''){
        markers.place_exact_locations_markers(new_map_info['markers'], false);
    }

    if (new_map_info['postal'] != ''){
        drawPostalCodeAreaOnMap(new_map_info['postal']);
    }

    if (new_map_info['district'] != ''){
        drawDistrictsOnMap(new_map_info['district']);
    }

    //this.updateURL(new_nav_state);
};

// This method allows to update the URL without redirecting, when a category is selected.
// By doing so, we give the user the possibility to reload the page on a specific category nav state.
// (Not used for now)
AdSocket.prototype.updateURL = function (new_nav_state){
    var params = location.search;
    var current_url = window.location.href;
    var new_cat_params = 'cat='+new_nav_state.cat.join('+');
    var new_url = '';

    if (params != ''){
        var param_array = params.replace('?','').split('&');
        var cat_param = ''
        for (var i = 0; i < param_array.length; i++){
            if (param_array[i].indexOf("cat=") > -1){
                cat_param = param_array[i];
                break;
            }
        }
        if (cat_param != ''){
            if (new_cat_params == 'cat='){
                new_url = current_url.replace(cat_param, '');
            }else{
                new_url = current_url.replace(cat_param, new_cat_params);
            }
        }else{
            new_url = current_url + '&'+ new_cat_params;
        }

    }else{
        if (new_cat_params == 'cat='){
            new_url = current_url;
        }else{
            new_url = current_url + '?' + new_cat_params;
        }
    }

    if (new_url.indexOf("?#") > -1){
        new_url = new_url.replace("?#","");
    }

    history.replaceState('data', '', new_url);

}

AdSocket.prototype.error_map = function (message){
    // if there's been an websocket error, use the 'search_error_message' div in navbar to display an error message
    $('#search_error_message').html(message);
};

// Method that place the new markers sent back from the server
AdSocket.prototype.add_marker = function (new_map_info){
    var ad_items = new_map_info['markers'][0]['ads'][0]['items'];
    if (ad_items.length > 1){
        // There are several markers to add on the map. Let's not bounce them, as animation conflicts with MarkerClusterGroup.
        markers.place_exact_locations_markers(new_map_info['markers'], false);
    }else{
        // 1 marker to add, let's make it bounce.
        markers.place_exact_locations_markers(new_map_info['markers'], true);
    }

};

// Custom 'send' function, making sure that the websocket connection is available.
AdSocket.prototype.send = function (message) {
    var socket = this.socket;
    this.waitForConnection(function () {
        socket.send(message);
    }, 1000);
};

AdSocket.prototype.waitForConnection = function (callback, interval) {
    if (this.socket.readyState === 1) {
        callback();
    } else {
        var that = this;
        // optional: implement backoff for interval here
        setTimeout(function () {
            that.waitForConnection(callback, interval);
        }, interval);
    }
};