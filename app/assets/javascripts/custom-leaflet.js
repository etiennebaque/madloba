/**
 * Initialization of the leaf object (called 'leaf' as because of the main use of the Leaflet library :) )
 * This object attributes consists of the map object, map tiles and other map-related objects.
 */
var leaf = {
    map: null,
    map_tiles: null,
    my_lat: '',
    my_lng: '',
    drawn_items: null,
    districts: null,
    searched_address: '',

    // By default, it is not possible to zoom in/out when using
    // the mouse wheel, unless clicking on the map (toggle).
    init: function (map_settings) {
        leaf.map = L.map('map', {scrollWheelZoom: false});

        leaf.map.on('click', function() {
            if (leaf.map.scrollWheelZoom.enabled()) {
                leaf.map.scrollWheelZoom.disable();
            } else {
                leaf.map.scrollWheelZoom.enable();
            }
        });

        leaf.my_lat = map_settings['lat'];
        leaf.my_lng = map_settings['lng'];
        leaf.searched_address = map_settings['searched_address'];

        if (map_settings['chosen_map'] == 'mapbox' || map_settings['chosen_map'] == 'osm'){
            // Mapbox or OSM
            leaf.map_tiles = L.tileLayer(map_settings['tiles_url'], {
                attribution: map_settings['attribution']
            });
        }else{
            // Mapquest
            leaf.map_tiles = MQ.mapLayer();
        }
        leaf.map_tiles.addTo(leaf.map);
        leaf.map.setView([leaf.my_lat, leaf.my_lng], map_settings['zoom_level']);

        // Load districts when available (eg. on area settings page, when all of them need to show up on a map...)
        if (typeof districts != 'undefined' && districts != null){
            leaf.districts = districts;
        }
    },

    // This method is used on the ad details page (ads#show) to display
    // the right feature on the map (eg. marker, district area or postal code area)
    show_features_on_ad_details_page: function(map_settings) {
        if (map_settings['ad_show_is_area'] == true){
            // Postal or district address (area type).
            // Shows an area icon on the map of the ads show page.
            if (map_settings['loc_type'] == 'district'){
                // Drawing the district related to this ad.
                var district_latlng = leaf.show_single_district(map_settings['popup_message'], map_settings['bounds']);
                leaf.map.setView(district_latlng, map_settings['zoom_level']);
            }else{
                // Drawing the postal code area circle related to this ad.
                var area = new L.circle([leaf.my_lat, leaf.my_lng], 600, {
                    color: markers.postal_code_area_color,
                    fillColor: markers.postal_code_area_color,
                    fillOpacity: 0.3
                });

                area.addTo(leaf.map).bindPopup(map_settings['popup_message']).openPopup();
                leaf.map.setView([leaf.my_lat, leaf.my_lng], map_settings['zoom_level']);
            }
        }else{
            // Exact address. Potentially several center markers on the map.
            // Displays a marker for each item tied to the ad we're showing the details of.
            // Using the Marker Cluster plugin to spiderfy this ad's item marker.
            markers.group = new L.MarkerClusterGroup({spiderfyDistanceMultiplier : 2, zoomToBoundsOnClick: false});
            for (var i= 0; i<map_settings['ad_show'].length; i++){
                var item_category = map_settings['ad_show'][i];
                var icon_to_use = L.AwesomeMarkers.icon({
                    prefix: 'fa',
                    markerColor: item_category['color'],
                    icon: item_category['icon']
                });

                var map_center_marker = L.marker([leaf.my_lat, leaf.my_lng], {icon: icon_to_use});
                if (map_settings['marker_message'] != ""){
                    map_center_marker.bindPopup(map_settings['marker_message'] + ' - ' + item_category['item_name']).openPopup();
                }

                markers.group.addLayer(map_center_marker);
            }
            leaf.map.addLayer(markers.group);
            leaf.map.setView([leaf.my_lat, leaf.my_lng], map_settings['zoom_level']);
        }
    },

    // Method showing a single feature on a map.
    show_single_marker: function(map_settings){
        if (map_settings['loc_type'] == 'postal'){
            // Drawing the postal code area circle related to this ad.
            markers.postal_code_circle = new L.circle([leaf.my_lat, leaf.my_lng], 600, {
                color: markers.postal_code_area_color,
                fillColor: markers.postal_code_area_color,
                fillOpacity: 0.3
            });

            markers.postal_code_circle.addTo(leaf.map).bindPopup(map_settings['marker_message']).openPopup();

        }else if (map_settings['loc_type'] == 'district'){
            leaf.show_single_district(map_settings['marker_message'], map_settings['bounds']);
        }else{
            // we are displaying the center point.
            var center_marker = L.marker([leaf.my_lat, leaf.my_lng], {icon: markers.default_icon});
            if (map_settings['marker_message'] != ""){
                center_marker.addTo(leaf.map).bindPopup(map_settings['marker_message']).openPopup();
                //center_marker.bindPopup(map_settings['marker_message']).openPopup();
            }else{
                center_marker.addTo(leaf.map);
            }
        }
    },

    // Method defining different events bound to the map, depending on which page this map is displayed.
    // Also displaying specific markers, like searched location marker
    setup_custom_behaviors: function(map_settings){
        if (map_settings['clickableMapMarker'] != 'none'){
            // Getting latitude and longitude of clicked point on the map.
            leaf.map.on('click', onMapClickLocation);
        }

        if (map_settings['page'] == 'mapsettings'){
            leaf.map.on('zoomend', function() {
                $('#zoom_level').val(leaf.map.getZoom());
            });
        }

        // Adding specific events on the 'Area settings' page, needed when drawing and saving districts.
        if (map_settings['page'] == 'areasettings'){
            leaf.init_map_on_area_settings();
        }
    },


    // Method that displays a single district on a map.
    // Returns the center of the district, needed to center the feature on the map for ads#show
    show_single_district: function(district_name, bounds){
        // Before adding the selected district, we need to remove all the currently displayed districts.
        if (markers.selected_area != ''){
            leaf.map.removeLayer(markers.selected_area);
        }

        var latlng = '';

        // Drawing the selecting district on the map.
        L.geoJson(JSON.parse(bounds), {
            onEachFeature: function (feature, layer) {
                layer.bindPopup(district_name);
                layer.setStyle({color: markers.district_color});
                leaf.map.addLayer(layer);
                latlng = layer.getBounds().getCenter();
                layer.openPopup(latlng);
                markers.selected_area = layer;
            }
        });

        return latlng;
    },


    // Method initializes districts on the "Area settings" map, and tools to edit/delete them.
    init_map_on_area_settings: function(){
        leaf.drawn_items = L.featureGroup().addTo(leaf.map);
        var district_bounds;
        var layer;

        // Adding drawing control panel to the map
        leaf.map.addControl(new L.Control.Draw({
            edit: { featureGroup: leaf.drawn_items }
        }));

        if (leaf.districts != null){
            // Adding existing districts to the map
            for (var i=0; i<leaf.districts.length; i++){
                // Adding the district id and name to the geoJson properties.
                L.geoJson(leaf.districts[i], {
                    onEachFeature: function (feature, layer) {
                        layer.bindPopup(leaf.districts[i]['properties']['name']);
                        layer.setStyle({color: markers.district_color});
                        leaf.drawn_items.addLayer(layer);
                    }
                });
            }
        }

        // Event to activate 'Save district' button when district name not empty.
        $('#map').on('keyup', '.save_district_text', function(){
            if ($('.save_district_text').val().length > 0){
                $('.save_district').removeClass('disabled');
            }else{
                $('.save_district').addClass('disabled');
            }
        });

        // Events triggered once the polygon (district) has been drawn.
        leaf.map.on('draw:created', function(e) {
            layer = e.layer;
            leaf.drawn_items.addLayer(layer);

            // Text field and "Save district" button to show up in the popup.
            var popup = L.popup({closeButton: false}).setContent("<input type='text' class='save_district_text' style='margin-right:5px;' placeholder='District name'><button type='button' class='btn btn-xs btn-success save_district disabled'>Save district</button>");

            layer.bindPopup(popup);
            district_bounds = layer.toGeoJSON();

            layer.openPopup(layer.getBounds().getCenter());
        });

        // Necessity to unbind click on map, to make the "on click" event right below work.
        $('#map').unbind('click');

        // Saving district drawing (bounds) and name.
        $('#map').on('click', '.save_district', function(){
            var district_name = $('.save_district_text').val();

            $.post("/user/areasettings/save_district", {bounds: JSON.stringify(district_bounds), name: district_name}, function (data){
                $('#district_notification_message').html("<span class='"+data.style+"'><strong>"+data.message+"</strong></span>");
                if (data.status == 'ok'){
                    leaf.drawn_items.removeLayer(layer);

                    district_bounds['properties']['id'] = data.id;
                    district_bounds['properties']['name'] = district_name;

                    L.geoJson(district_bounds, {
                        onEachFeature: function (feature, layer) {
                            layer.bindPopup(district_name);
                            layer.setStyle({color: data.district_color});
                            leaf.drawn_items.addLayer(layer);
                        }
                    });
                }
            });
        });

        // Update district name into the GeoJSON properties hash.
        $('#map').on('click', '.update_district', function(){
            var new_district_name = $('.update_district_text').val();
            var district_id = $('.update_district_text').attr('id');

            $.post("/user/areasettings/update_district_name", {id: district_id, name: new_district_name}, function (data){
                $('#district_notification_message').html("<span class='"+data.style+"'><strong>"+data.message+"</strong></span>");
            });

            // Going through the districts and checking which one to update.
            leaf.drawn_items.eachLayer(function (layer) {
                district_bounds = layer.toGeoJSON();
                if (district_id == district_bounds['properties']['id']){
                    layer.bindPopup("<input type='text' id='"+district_bounds['properties']['id']+"' class='update_district_text' style='margin-right:5px;' placeholder='District name' value='"+new_district_name+"'><button type='button' id='save_"+district_bounds['properties']['id']+"' class='btn btn-xs btn-success update_district'>OK</button><br /><div class='district_notif'></div>");
                    layer.closePopup();
                }

            });
        });

        // When starting to edit a district, create new popup for each district with current name in text field.
        leaf.map.on('draw:editstart', function(e){
            leaf.drawn_items.eachLayer(function (layer) {
                district_bounds = layer.toGeoJSON();
                layer.bindPopup("<input type='text' id='"+district_bounds['properties']['id']+"' class='update_district_text' style='margin-right:5px;' placeholder='District name' value='"+district_bounds['properties']['name']+"'><button type='button' id='save_"+district_bounds['properties']['id']+"' class='btn btn-xs btn-success update_district'>OK</button><br /><div class='district_notif'></div>");
            });

        });

        // After saving new name of district, remove the text input and display new name as text only.
        leaf.map.on('draw:editstop', function(e){
            leaf.drawn_items.eachLayer(function (layer) {
                district_bounds = layer.toGeoJSON();
                layer.bindPopup(district_bounds['properties']['name']);
            });

        });

        // Event triggered when polygon (district) has been edited, and "Save" has been clicked.
        leaf.map.on('draw:edited', function (e) {
            var layers = e.layers;
            var updated_districts = [];
            layers.eachLayer(function (layer) {
                district_bounds = layer.toGeoJSON();
                updated_districts.push(district_bounds);
            });

            $.post("/user/areasettings/update_districts", {districts: JSON.stringify(updated_districts)}, function (data){
                $('#district_notification_message').html("<span class='"+data.style+"'><strong>"+data.message+"</strong></span>");
            });

        });

        // Event triggered after deleting districts and clicking on 'Save'.
        leaf.map.on('draw:deleted', function (e) {
            var layers = e.layers;
            var district_ids = [];
            layers.eachLayer(function (layer) {
                var district = layer.toGeoJSON();
                district_ids.push(district['properties']['id']);
            });

            $.post("/user/areasettings/delete_districts", {ids: district_ids}, function (data){
                $('#district_notification_message').html("<span class='"+data.style+"'><strong>"+data.message+"</strong></span>");
            });

        });
    }
};


/**
 * Object gathering different markers and icons that are used on the Madloba maps.
 */
var markers = {
    // Single feature to appear on pages like new ad form (location form), or ad detail page.
    new_marker: '',
    selected_area: '',
    postal_code_circle: '',

    // Group of features, to appear mainly on the main map (home page).
    group: '',
    postal_group: '',
    district_group: '',

    // Icons and feature colors
    default_icon: null,
    new_icon: null,
    marker_colors: null,
    postal_code_area_color: null,
    district_color: null,

    // Geocodes needed to draw the postal code circles or the district boundaries
    area_geocodes: null,

    // There are 2 types of markers, when defining a new location:
    // exact (by full address, default one), and area (by postal code, or district)
    location_marker_type: null,

    // Marker that will be in the center of the map.
    center_marker: null,

    init: function (map_settings) {
        markers.default_icon = L.icon ({
            iconUrl: map_settings['default_marker_icon'],
            iconAnchor: [12, 41],
            popupAnchor:  [0, -34]
        });

        markers.new_icon = L.icon ({
            iconUrl: map_settings['new_marker_icon'],
            iconAnchor: [12, 41],
            popupAnchor:  [0, -34]
        });

        markers.location_marker_type = map_settings['clickableMapMarker'];

        markers.district_color = map_settings['district_color'];
        markers.postal_code_area_color = map_settings['postal_code_area_color'];
    },

    // Method that creates markers representing ads tied to exact-type location.
    place_exact_locations_markers_test: function (locations_exact, is_bouncing_on_add) {
        for (var i=0; i<locations_exact.length; i++){

            var ad = locations_exact[i];

            for (var j=0; j<ad['markers'].length; j++){
                var item = ad['markers'][j];

                var marker_icon = L.AwesomeMarkers.icon({
                    prefix: 'fa',
                    markerColor: item['color'],
                    icon: item['icon']
                });

                var marker = L.marker([ad['lat'], ad['lng']], {icon: marker_icon, bounceOnAdd: is_bouncing_on_add});
                marker.ad_id = ad['ad_id'];
                marker.item_id = item['item_id'];
                var popup = L.popup({minWidth: 250, maxWidth: 300}).setContent('Loading...');
                marker.bindPopup(popup);

                // When a marker is clicked, an Ajax call is made to get the content of the popup to display
                marker.on('click', function(e) {
                    var popup = e.target.getPopup();
                    $.ajax({
                        url: "/showAdPopup",
                        global: false,
                        type: "GET",
                        data: { ad_id: this.ad_id, item_id: this.item_id },
                        dataType: "html",
                        beforeSend: function(xhr) {
                            xhr.setRequestHeader("Accept", "text/html-partial");
                        },
                        success: function(data) {
                            popup.setContent(data);
                            popup.update();
                        },
                        error: function(data) {
                            popup.setContent(data);
                            popup.update();
                        }
                    });
                });
                markers.group.addLayer(marker);
            }
        }
    },

    // Method that creates markers representing ads tied to exact-type location.
    place_exact_locations_markers: function (locations_exact, is_bouncing_on_add) {
        for (var i=0; i<locations_exact.length; i++){
            var location = locations_exact[i];

            for (var j=0; j<location['ads'].length; j++){
                var popup_html_text;
                var marker;

                var ad = location['ads'][j];

                for (var k=0; k<ad['items'].length; k++){

                    var item = ad['items'][k];

                    var marker_icon = L.AwesomeMarkers.icon({
                        prefix: 'fa',
                        markerColor: item['category']['marker_color'],
                        icon: item['category']['icon']
                    });

                    // HTML snippet for the popup
                    if (location['name'] != ''){
                        popup_html_text = createPopupHtml("<b>"+location['name']+"</b><br />" +location['street_number'] + " " + location['address'], ad, k);
                    }else{
                        popup_html_text = createPopupHtml("<b>" +location['street_number'] + " " + location['address'] + "</b>", ad, k);
                    }

                    var marker = '';
                    if (is_bouncing_on_add){
                        marker = L.marker([location['latitude'], location['longitude']], {icon: marker_icon, title: location['full_address'], bounceOnAdd: is_bouncing_on_add});
                    }else{
                        marker = L.marker([location['latitude'], location['longitude']], {icon: marker_icon, title: location['full_address']});
                    }

                    var popup = L.popup({minWidth: 250}).setContent(popup_html_text);

                    marker.bindPopup(popup);
                    markers.group.addLayer(marker);
                }
            }
        }
    },

    // Method that draws circles, representing ads tied to a postal code only.
    draw_postal_code_areas: function (locations_postal) {
        if (locations_postal != null && Object.keys(locations_postal).length > 0){

            markers.postal_group = L.featureGroup().addTo(leaf.map);

            // Adding event to show/hide these districts from the checkbox in the guided navigation.
            $("#show_area_id").change(function() {
                if ($('#show_area_id').prop('checked')) {
                    // Drawing districts in this function, when checkbox is checked.
                    drawPostalCodeAreaOnMap(locations_postal);
                }else{
                    markers.postal_group.eachLayer(function (layer) {
                        markers.postal_group.removeLayer(layer);
                    });
                }
            }).change();
        }
    },

    // Method drawing the boundaries of districts on a map. Only the districts related to an active ad are drawn.
    draw_district_areas: function (locations_district) {
        // Snippet that creates markers, to represent ads tied to district-type location.
        if (locations_district != null && Object.keys(locations_district).length > 0){
            markers.district_group = L.featureGroup().addTo(leaf.map);

            // Adding event to show/hide these districts from the checkbox in the guided navigation.
            $("#show_area_id").change(function() {
                if ($('#show_area_id').prop('checked')) {
                    // Drawing districts in this function, when checkbox is checked.
                    drawDistrictsOnMap(locations_district);
                }else{
                    markers.district_group.eachLayer(function (layer) {
                        markers.district_group.removeLayer(layer);
                    });
                }
            }).change();
        }
    }
}

/**
 * Main function that initializes the map on different screens (eg home page, map setting page, ad page...).
 * @param map_settings - hash that contains all info needed to initialize the map.
 */
function initLeafletMap(map_settings){

    if (leaf != null && leaf.map != null){
        leaf.map.remove();
    }

    // Initialization of the map and markers.
    leaf.init(map_settings);
    markers.init(map_settings);


    if (map_settings['hasCenterMarker'] == true){
        if (map_settings['ad_show']){
            // Showing markers, district area or postal code area on the ad details page (ads#show)
            leaf.show_features_on_ad_details_page(map_settings);

        }else{
            // Center single marker on the map
            // Appearing only in admin map setting, and admin location page, on page load.
            // Define first if it should be the area icon (for addresses based only on postal codes), or the default icon.
            leaf.show_single_marker(map_settings);
        }
    }

    // Depending of the page, the map might react differently (eg. marker showing on onClick...)
    // This method sets up the map behavior in relation to the page the user's on.
    leaf.setup_custom_behaviors(map_settings);

}


/**
 * Populates the map with different markers (eg exact address and area-type markers, to show ads)
 * @param locations_hash - hash containing the info to create all different markers.
 */
function putLocationMarkers(locations_exact, locations_postal, locations_district, area_geocodes, marker_colors){

    // The MarkerClusterGroup object will allow to aggregate location markers (both 'exact location' and 'area' markers),
    // when they get too close to one another, as the user zooms out, on the home page.
    markers.group = new L.MarkerClusterGroup({spiderfyDistanceMultiplier : 2, zoomToBoundsOnClick: false});
    markers.area_geocodes = area_geocodes;
    markers.marker_colors = marker_colors;

    // Displaying markers on map
    markers.place_exact_locations_markers_test(locations_exact, false);

    // Displaying postal code area circles on map
    markers.draw_postal_code_areas(locations_postal);

    // Displaying district areas on map
    markers.draw_district_areas(locations_district);

    // Event to trigger when click on a link in a area popup, on the home page map. Makes a modal window appear.
    // Server side is in home_controller, method showSpecificAds.
    $('#map').on('click', '.area_link', function(){
        var input = $(this).attr('id').split('|');
        $.get("/showSpecificAds", {item: input[0], type: input[1], area: input[2]}, function (data){
            var html_to_append = '<ul>';
            for (var i = 0; i < data['ads'].length; i++) {
                var ad = data['ads'][i];
                html_to_append = html_to_append + '<li><a href="/ads/' + ad['id'] + '/">' + ad['title']+ '</a></li>';
            }
            html_to_append = html_to_append + '</ul>';
            $('#ads-modal-body-id').html(html_to_append);
            var icon = '';
            if (typeof data['icon'] != 'undefined'){
                icon = '<i class="fa '+ data['icon'] +'" style="color: '+ data['hexa_color'] +'; padding-right: 10px;"></i>';
            }

            $('#adsModalTitle').html(icon + gon.vars['ads_for']+' \'' + input[0].capitalizeFirstLetter() + '\' - ' + data['area_name']);
            var options = {
                "backdrop" : "static",
                "show" : "true"
            }

            $('#adsModal').modal(options);
        })
    });

    var searched_location_marker = '';
    if (typeof leaf.searched_address != 'undefined'){
        // Adding marker for the searched address, on the home page.
        searched_location_marker = L.marker([ leaf.my_lat, leaf.my_lng ], {icon: markers.default_icon}).bindPopup(leaf.searched_address);
        searched_location_marker.addTo(leaf.map);
        //markers.group.addLayer(searched_location_marker);
        //leaf.map.fitBounds(markers.group.getBounds().pad(0.1));
    }

    // Adding all the markers to the map.
    leaf.map.addLayer(markers.group);

    if (searched_location_marker != ''){
        searched_location_marker.openPopup();
    }


}


/**
 * Creates the text to be shown in a marker popup, giving details about the selected exact location.
 * @param first_sentence
 * @param location
 * @returns Popup text content.
 */
function createPopupHtml(first_sentence, ad, index){
    var second_sentence = '';
    var result = '';
    var item = ad['items'][index];

    var popup_ad_link = "<a href='/ads/"+ad['id']+"/'>"+ad['title']+"</a>";
    var popup_item_name = "<span style='color:" + marker_colors[item['category']['marker_color']] + "';><strong>" + item['name'].capitalizeFirstLetter() + "</strong></span>";

    if (ad['is_giving'] == true){
        second_sentence = gon.vars['items_given']+"<br />" + popup_item_name + ': ' + popup_ad_link + '<br />';
    }else{
        second_sentence = gon.vars['items_searched']+"<br />" + popup_item_name + ': ' + popup_ad_link + '<br />';
    }

    if (ad['image']['thumb']['url'] != null && ad['image']['thumb']['url'] != ''){
        // Popup is created with a thumbnail image in it.
        var ad_image = "<img class='thumb_ad_image' onError=\"$('.thumb_ad_image').remove(); $('.image_notification').html('<i>"+gon.vars['image_not_available']+"</i>');\" src='"+ad['image']['thumb']['url']+"'><span class=\"image_notification\"></span>";
        result =  "<div style='overflow: auto;'><div class='col-sm-6'>"+first_sentence+"</div><div class='col-sm-6'>"+ad_image+"</div><div class='col-sm-12'><br>"+second_sentence+"</div></div>";
    }else{
        // Popup is created without any thumbnail image.
        result =  "<div style='overflow: auto;'>"+first_sentence+"<br><br>"+second_sentence+"</div>";
    }

    return result;
}


/**
 * This function draws districts (where at least one current ad is included)
 * on the map of the home page.
 */
 function drawDistrictsOnMap(locations_district){
    Object.keys(locations_district).forEach(function (district_id) {
        var locations = locations_district[district_id];
        var district_name = markers.area_geocodes[district_id]['name'];
        var district_bounds = markers.area_geocodes[district_id]['bounds'];

        var popup_html_text = createPopupHtmlArea(gon.vars['in_this_district'] + " (<b>"+district_name+"</b>)<br /><br />", locations, 'district', district_id);

        // Adding the districts (which have ads) to the home page map.
        L.geoJson(JSON.parse(district_bounds), {
            onEachFeature: function (feature, layer) {
                layer.bindPopup(popup_html_text);
                layer.setStyle({color: markers.district_color});
                markers.district_group.addLayer(layer);
            }
        });
    })
 }

/**
 * This function draws postal code areas (where at least a current ad is included)
 * on the map of the home page.
 */
function drawPostalCodeAreaOnMap(locations_postal){
    Object.keys(locations_postal).forEach(function (area_code) {
        var locations = locations_postal[area_code];

        var popup_html_text = createPopupHtmlArea("In this area (<b>"+area_code+"</b>)<br /><br />", locations, 'postal', area_code);

        var area = L.circle([markers.area_geocodes[area_code]['latitude'], markers.area_geocodes[area_code]['longitude']], 600, {
            color: markers.postal_code_area_color,
            fillColor: markers.postal_code_area_color,
            fillOpacity: 0.3
        }).bindPopup(popup_html_text);

        markers.postal_group.addLayer(area);
    });
}

/**
 * Creates the text to be shown in a marker popup,
 * giving details about the selected area-type location (postal or district).
 * @param first_sentence
 * @param location
 * @returns Popup text content.
 */
function createPopupHtmlArea(first_sentence, locations_from_same_area, area_type, area_id){
    var is_giving_item = false;
    var is_accepting_item = false;

    // Adding a explanatory note, before listing items
    var explanation = "<i>"+gon.vars['select_item']+"</i><br /><br />"
    first_sentence = first_sentence + explanation;

    var people_give = gon.vars['items_given']+"<br />";
    var people_accept = gon.vars['items_searched']+"<br />";

    // This hash will count how many ads we have, per promoted item.
    var ad_number_per_item = {};

    // This array will be used to sort items alphabetically.
    var sorted_items = [];

    for (var i=0; i<locations_from_same_area.length; i++){
        var location = locations_from_same_area[i];

        for (var j= 0; j<location['ads'].length; j++){
            var ad = location['ads'][j];

            for (var k=0; k<ad['items'].length; k++){
                var item = ad['items'][k];

                var item_marker_color = item['name'] + '|' + markers.marker_colors[item['category']['marker_color']];

                if (item_marker_color in ad_number_per_item){
                    ad_number_per_item[item_marker_color]['number'] = ad_number_per_item[item_marker_color]['number'] + 1;
                }else{
                    ad_number_per_item[item_marker_color] = {};
                    ad_number_per_item[item_marker_color]['number'] = 1;
                    ad_number_per_item[item_marker_color]['is_giving'] = ad['is_giving'];
                    sorted_items.push(item_marker_color);
                }

            }
        }
    }

    // We now sort all the items we worked with right above (they are appended with marker colors, but still, items get sorted).
    sorted_items = sorted_items.sort();

    // Popup for this area is created here.
    for (var i=0; i<sorted_items.length; i++){
        var item_marker_color = sorted_items[i];

        var item_info = item_marker_color.split('|');
        var item_name = item_info[0];
        var marker_color = item_info[1];
        var number_of_ads = ad_number_per_item[item_marker_color]['number'];

        var popup_item_name = "<span style='color:" + marker_color + ";' >" + item_name.capitalizeFirstLetter() + "</span>";
        var link_id = item_name+'|'+area_type+'|'+area_id;
        var popup_ad_link = "- <a href='#' class='area_link' id='"+link_id+"'>"+popup_item_name+" ("+number_of_ads+")</a>"

        if (ad_number_per_item[item_marker_color]['is_giving'] == true){
            is_giving_item = true;
            people_give = people_give + popup_ad_link + '<br />';
        }else{
            is_accepting_item = true;
            people_accept = people_accept + popup_ad_link + '<br />';
        }
    }

    // Putting all the sections of the popup together.
    if (!is_giving_item && is_accepting_item){
        first_sentence = first_sentence + people_accept;
    }else if (!is_accepting_item && is_giving_item){
        first_sentence = first_sentence + people_give;
    }else{
        first_sentence = first_sentence + people_give + '<br />' + people_accept;
    }

    return first_sentence;

}

/**
 * This method initialize the right-hand side navigation bar, on the home page.
 */
function initializeSideBar(sidebar){

    // Side bar is shown, right before initializing it, after map is fully loaded.
    $('#sidebar').removeClass('hide');

    var sidebar = L.control.sidebar('sidebar', {
        closeButton: true,
        position: 'right'
    });

    // Navigation toggle button
    var btn = L.functionButtons([{ content: 'Categories / Create ad' }]);

    leaf.map.addControl(sidebar);

    var isSidebarOpen = false;
    var window_width = $(window).width();

    if (window_width < 768){
        leaf.map.addControl(btn);
    }else{
        sidebar.show();
        isSidebarOpen = true;
    }

    leaf.map.on('click', function () {
        if (isSidebarOpen){
            sidebar.hide();
            leaf.map.addControl(btn);
            isSidebarOpen = false;
        }
    });

    btn.on('clicked', function(data) {
        if( data.idx == 0 ) {
            sidebar.show();
            isSidebarOpen = true;
            leaf.map.removeControl(btn);
        }else{
            sidebar.hide();
            isSidebarOpen = false;
            leaf.map.addControl(btn);
        }
    });

    $('.leaflet-sidebar .close').click(function(){
        leaf.map.addControl(btn);
        isSidebarOpen = false;
    });

    // By default, we hide the navigation bar on phones and tablets (width < 992).
    // We should only see the map, when home page loads on mobile device.
    $(window).resize(function() {
        var old_window_width = window_width;
        window_width = $(window).width();
        if (window_width < 768){
            // On mobile, window_width gets refreshed when we scroll on open naviagation menu.
            // We used a trick with old_window_width: if width does not change (ie. we're scrolling), the opened
            // nav menu remains open.
            if (old_window_width != window_width){
                sidebar.hide();
                if (isSidebarOpen){
                    leaf.map.addControl(btn);
                    isSidebarOpen = false;
                }
            }
        }else{
            sidebar.show();
            if (!isSidebarOpen){
                leaf.map.removeControl(btn);
                isSidebarOpen = true;
            }
        }
    });

}


/**
 * Defines latitude and longitude, after a click on a map (eg on map settings page...).
 * Updates hidden fields, if needed, if the geocodes are part of a form.
 */
function onMapClickLocation(e) {
    var new_geocodes = onMapClick(e);
    var geocodeSplit= new_geocodes.split(',');

    // latitude_text and longitude_text are classes used on area settings page.
    $(".latitude_text").text(geocodeSplit[0]);
    $(".longitude_text").text(geocodeSplit[1]);
    $("#new_dynamic_button_add").removeClass('disabled');


    $(".latitude_hidden").val(geocodeSplit[0]);
    $(".longitude_hidden").val(geocodeSplit[1]);
}

/**
 * Callback function that returns geocodes of clicked location.
 * @param e
 * @returns "latitude,longitude"
 */
function onMapClick(e) {

	if (markers.new_marker != ''){leaf.map.removeLayer(markers.new_marker);}
    if (markers.postal_code_circle != ''){leaf.map.removeLayer(markers.postal_code_circle);}

	var myNewLat = e.latlng.lat;
	var myNewLng = e.latlng.lng;

    // Rounding up latitude and longitude, with 5 decimals
    myNewLat = Math.round(myNewLat*100000)/100000;
    myNewLng = Math.round(myNewLng*100000)/100000;

    if (markers.location_marker_type == 'exact'){
        markers.new_marker = new L.Marker(e.latlng, {icon: markers.new_icon}, {draggable:false});
        leaf.map.addLayer(markers.new_marker);
    }else if (markers.location_marker_type == 'area'){
        markers.postal_code_circle = new L.circle(e.latlng, 600, {
            color: markers.postal_code_area_color,
            fillColor: markers.postal_code_area_color,
            fillOpacity: 0.3
        });
        markers.postal_code_circle.addTo(leaf.map);
    }

    return myNewLat+','+myNewLng;
}

// Adding capitalization of first word of a string to String prototype.
// Used to capitalize item names, in marker popup and area modal windows.
String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}