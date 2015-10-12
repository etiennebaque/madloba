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

    this.socket.onmessage = function(e) {
        // We will have a status message in our response:
        // mapok
        // error
        // new_marker
        var response = JSON.parse(e.data);
        var status = response['status'];
        var map_info = response['map_info'];

        switch(status) {
            case "mapok":
                _this.refresh_map(map_info);
                break;
            case "error":
                _this.error_map(map_info);
                break;
            case "new_marker":
                _this.add_marker(map_info);
                break;
        }

    };
};

AdSocket.prototype.sendNavState = function(value) {
    this.socket.send(value);
};

// After selection of a category in the guided navigation, we need to refresh the map accordingly.
AdSocket.prototype.refresh_map = function (new_map_info){
    // First we need to clear all the current layers.

    markers.group.clearLayers();
    markers.postal_group.clearLayers();
    markers.district_group.clearLayers();

    if (new_map_info['markers'] != ''){
        markers.place_exact_locations_markers(new_map_info['markers']);
    }

    if (new_map_info['postal'] != ''){
        drawPostalCodeAreaOnMap(new_map_info['postal']);
    }

    if (new_map_info['district'] != ''){
        drawDistrictsOnMap(new_map_info['district']);
    }
};

AdSocket.prototype.error_map = function (new_map_info){

};

AdSocket.prototype.add_marker = function (new_map_info){

};