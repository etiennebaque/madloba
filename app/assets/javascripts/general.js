$(document).ready(function(){

    // Popover when "Sign in / Register" link is clicked, in the navigation bar.
    $('#popover').popover({
        html : true,
        placement : 'bottom',
        title: function() {
            return $("#popover-head").html();
        },
        content: function() {
            return $("#popover-content").html();
        }
    });

    // Activates type-ahead functionality, in the item search bar, on the home page.
    if (typeof all_ads_items != 'undefined'){
        $('#item').typeahead({source: all_ads_items});
    }

    // Navigation bar on device: closes the navigation menu, when click.
    $('.nav a').on('click', function(){
        if($('.navbar-toggle').css('display') !='none'){
            $(".navbar-toggle").click()
        }
    });

    // Offcanvas related scripts
    $('[data-toggle=offcanvas]').click(function() {
        $('.row-offcanvas').toggleClass('active');
    });

    // ***********************
    // Create/Edit an ad pages
    // ***********************

    // Activates type-ahead on the "Create an Ad" page
    if (typeof all_items != 'undefined'){
        $('#ad_item').typeahead({source: all_items});
    }

    // When the focus is out of the item field, we check whether this item is already in the database.
    // If it is, the category for this item already exists. If it is not, the user has to choose a category for this new item.
    // Also, the 'sendAjaxRequest' variable is used to make sure that we make only 1 Ajax call - using timeout was making multiple
    // unnecessary ajax calls (timeout is needed in order to make sure the item field is populated after onclick on typeahead, before making ajax call).
    var sendAjaxRequest = false;
    $('#ad_item').focusin(function(){
        sendAjaxRequest = true;
    });
    $('#ad_item').focusout(function(){
        setTimeout(function() {
            var item_name = $('#ad_item').val();
            if (sendAjaxRequest){
                sendAjaxRequest = false;
                $.ajax({
                    url: "/checkItemExists",
                    global: false,
                    type: "GET",
                    data: { item_name: item_name },
                    cache: false,
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader("Accept", "application/json");
                        xhr.setRequestHeader("Content-Type", "application/json");
                    },
                    success: function(data) {
                        if (data['id'] != null && data['name'] != null){
                            // It is an existing item. We select the associated category, in the drop down box, on the same page.
                            $('#category').val(data.id)
                            $('#category').prop ('disabled', true);
                            $('#item_notification').html('');
                            $('#category-section').addClass('hide');
                        }else{
                            // This is not an existing item. We make the "categories" drop down box appear,
                            // so that the user can select the appropriate category from this item.
                            $('#item_notification').html('<i>Choose a category for this new item you just entered</i>');
                            $('#category').prop ('disabled', false);
                            $('#category-section').removeClass('hide');
                        }
                    }

                });
            }
        }, 400);
    });

    // "Create ad" form: when "New location" radio button is selected, or is already checked.
    if($('#new_location_radio').is(':checked')) {
        $("#new_location_section").removeClass('hide');
        initLeafletMap(map_settings_array);
    }
    $("#new_location_radio").click(function(){
        $("#new_location_section").removeClass('hide');
        initLeafletMap(map_settings_array);
    });

    // "Create ad" form: if the user has no existing location yet, open automatically the "New location" form
    if (location_number == 0){
        $("#new_location_section").removeClass('hide');
        initLeafletMap(map_settings_array);
    }

    // "Create ad" form: when "New location" radio button is not selected.
    $(".existing_location").click(function(){
        $("#new_location_section").addClass('hide');
    });


    // Location form: show appropriate section when entering an exact address
    $(".location_type_exact").click(function(){
        $("#postal_code_section").removeClass('hide');
        $("#district_section").addClass('hide');
        $(".exact_location_section").removeClass('hide');
        location_marker_type = 'exact';
        map.on('click', onMapClickLocation);

        if (newmarker != null){
            map.removeLayer(newmarker);
        }
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').removeClass('hide');
    });

    if($('.location_type_exact').is(':checked')) {
        $("#postal_code_section").removeClass('hide');
        $("#district_section").addClass('hide');
        $(".exact_location_section").removeClass('hide');
        location_marker_type = 'exact';
        map.on('click', onMapClickLocation);
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').removeClass('hide');
    }

    // Location form: show appropriate section when choosing a postal code-based area
    $(".location_type_postal_code").click(function(){
        $(".exact_location_section").addClass('hide');
        $("#district_section").addClass('hide');
        $("#postal_code_section").removeClass('hide');
        location_marker_type = 'area';
        map.on('click', onMapClickLocation);

        if (newmarker != null){
            map.removeLayer(newmarker);
        }

        $('#map_notification_postal_code_only').removeClass('hide');
        $('#map_notification_exact').addClass('hide');
    });

    if($('.location_type_postal_code').is(':checked')) {
        $(".exact_location_section").addClass('hide');
        $("#district_section").addClass('hide');
        $("#postal_code_section").removeClass('hide');
        location_marker_type = 'area';
        map.on('click', onMapClickLocation);

        $('#map_notification_postal_code_only').removeClass('hide');
        $('#map_notification_exact').addClass('hide');
    }

    // Location form: show appropriate section when choosing a district-based area
    $(".location_type_district").click(function(){
        $(".exact_location_section").addClass('hide');
        $("#postal_code_section").addClass('hide');
        $("#district_section").removeClass('hide');
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').addClass('hide');
        location_marker_type = 'area';
        map.off('click', onMapClickLocation);
        $("#map_notification").addClass('hide');

        if (newmarker != null){
            map.removeLayer(newmarker);
        }
    });

    if($('.location_type_district').is(':checked')) {
        $(".exact_location_section").addClass('hide');
        $("#postal_code_section").addClass('hide');
        $("#district_section").removeClass('hide');
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').addClass('hide');
        location_marker_type = 'area';
        map.off('click', onMapClickLocation);
    }

    // "Postal code" functionality: display a help message to inform about what the area will be named,
    // after the postal code is entered.
    $('.location_postal_code').focusout(function() {
        if($('.location_type_postal_code').is(':checked')) {
            var area_code_length, postal_code_length;
            var postal_code = $('.location_type_postal_code').val();
            var postal_code_value = $('.location_postal_code').val();

            if(typeof area_code_length == 'undefined' && typeof postal_code_length == 'undefined'){
                $.ajax({
                    url: "/user/getAreaSettings",
                    global: false,
                    type: "GET",
                    data: {},
                    cache: false,
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader("Accept", "application/json");
                        xhr.setRequestHeader("Content-Type", "application/json");
                    },
                    success: function(data) {
                        if (data['code'] != null && data['area'] != null){
                            // It is an existing item. We select the associated category, in the drop down box, on the same page.
                            area_code_length = data['area'];
                            if (postal_code.length >= area_code_length){
                                $('#postal_code_notification').html("<i>This location area will show up as '"+postal_code_value.substring(0, area_code_length)+"'</i>");
                            }
                        }
                    }

                });
            }
        }
    });

    // Location form: when choosing a district from the drop-down box, we need to display the area on the map underneath.
    $('.district_dropdown').change(function() {
        var id = $('.district_dropdown option:selected').val();
        var name = $('.district_dropdown option:selected').text();
        var latitude = districts_geocodes[id][0];
        var longitude = districts_geocodes[id][1];

        putSingleMarker(latitude, longitude, 'area', name);

        $(".latitude_hidden").val(latitude);
        $(".longitude_hidden").val(longitude);
    });

    // Help messages for fields on "Create ad" form
    $('.help-message').popover();


    // Event triggered when click on "Define geocodes & find address on the map" button,
    // on the "Create ad" form, and on the Ad edit form.
    $('#findGeocodeAddressMapBtnId').button().click(function () {

        var location_type = 'exact';

        if (typeof current_page != "undefined" && current_page == "new_ad"){
            // We are on the "Create ads" page
            if ($('#location_type_area_id').is(':checked')){
                //array_to_pass['type'] = 'area';
                location_type = 'area';
            }
        }

        if ($('.location_type_postal_code').is(':checked')){
            // We're on the location edit page, and 'Postal code' location type is checked.
            location_type = 'area';
        }

        // Ajax call to get geocodes (latitude, longitude) of an exact location defined by address, postal code, city...
        // This call is triggered by "Find this city", "Find this general location" buttons,
        // on Map settings page, location edit page, map setup page...
        $.ajax({
            url: "/getCityGeocodes",
            global: false,
            type: "GET",
            data: { street_number: $(".location_streetnumber").val(),
                    address: $(".location_streetname").val(),
                    city: $(".location_city").val(),
                    postal_code: $(".location_postal_code").val(),
                    state: $(".location_state").val(),
                    country: $(".location_country").val(),
                    type: location_type
            },
            cache: false,
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Accept", "application/json");
                xhr.setRequestHeader("Content-Type", "application/json");
                $('#findGeocodeLoaderId').html("Searching location...");
            },
            success: function(data) {
                if (data != null){
                    // Geocodes were found: the location is shown on the map.

                    var myNewLat = Math.round(data.lat*100000)/100000
                    var myNewLng = Math.round(data.lon*100000)/100000

                    $(".latitude_hidden").val(myNewLat);
                    $(".longitude_hidden").val(myNewLng);

                    // Update the center of map, to show the general area
                    map.setView(new L.LatLng(myNewLat, myNewLng), data.zoom_level);
                }else{
                    // The address' geocodes were not found - the user has to pinpoint the location manually on the map.
                    $('#myErrorModal').modal('show');
                }
                // Displaying notification about location found.
                $('#findGeocodeLoaderId').html('<i>'+data.address_found+'</i>');
            }
        });

    });

    // This event replaces the 'zoomToBoundsOnClick' MarkerCluster option. When clicking on a marker cluster,
    // 'zoomToBoundsOnClick' would zoom in too much, and push the markers to the edge of the screen.
    // This event underneath fixes this behaviour, the markers are not pushed to the boundaries of the map anymore.
    if(typeof markers != 'undefined'){
        markers.on('clusterclick', function (a) {
            var bounds = a.layer.getBounds().pad(0.5);
            map.fitBounds(bounds);
        });
    }

});
