$(document).ready(function() {

    // This is a test to see if the user is using clients like AdBlock.
    // The use of AdBlock blocks a lot of markups on this website, unfortunately (eg. everything that has 'ad' in the class name)
    // When AdBlock is detected, we display a popup indicating that AdBlock should be deactivated for this Madloba website.
    if ($('#ad-block').length && !$('#ad-block').height()) {
        $('#wrap').append('<div class="blocking-notification alert alert-dismissible alert-warning" role="alert">' +
        '<button type="button" class="close" data-dismiss="alert">×</button>' +
        '<h5>'+gon.vars["adblock_warning"]+'</h5>' +
        '<p>'+gon.vars["adblock_browser"]+'<br />'+gon.vars["adblock_affecting"]+'</p>' +
        '<p>'+gon.vars["adblock_turnoff"]+'</p>' +
        '</div>');
    }
    // Initially created in 'home.html.erb' layout, this test div is now removed.
    $("#ad-block").remove();

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


    // Type-ahead for the item text field, in the main navigation bar.
    // searched_ad_items object is initialized in home layout template.
    if (typeof searched_ad_items != 'undefined') {
        $('#item').typeahead(null, {
            display: 'value',
            source: searched_ad_items
        });
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

    // Function that binds events to the item drop down list (in ads#new and ads#edit pages)
    // These events consists of making ajax call to check what items exists, in order to
    // create a type-ahead for the search bar of that drop drown box.
    function bindTypeaheadToItemSelect(object){
        object.selectpicker({
                liveSearch: true
            })
            .ajaxSelectPicker({
                ajax: {
                    url: '/getItems',
                    type: "GET",
                    dataType: 'json',
                    data: function () {
                        var params = {
                            item: '{{{q}}}',
                            type: 'search_items'
                        };
                        return params;
                    }
                },
                locale: {
                    emptyTitle: gon.vars['search_for_items'],
                    statusInitialized: gon.vars['start_typing_item'],
                    statusNoResults: gon.vars['no_result_create_item']
                },
                preprocessData: function(data){
                    var items = [];
                    var len = data.length;
                    for(var i = 0; i < len; i++){
                        var item = data[i];
                        items.push(
                            {
                                'value': item.id,
                                'text': item.value,
                                'disable': false
                            }
                        );
                    }
                    return items;
                },
                preserveSelected: false
            });
    }

    bindTypeaheadToItemSelect($('#items .selectpicker-items'));

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
    if (typeof location_number != 'undefined' && location_number == 0){
        $("#new_location_section").removeClass('hide');
        initLeafletMap(map_settings_array);
    }

    // "Create ad" form: when "New location" radio button is not selected.
    $(".existing_location").click(function(){
        $("#new_location_section").addClass('hide');
    });

    // "Create ad" form: create message when image needs to be uploaded.
    $('#new_ad').submit(function() {
        var image_path = $('#ad_image').val();
        if (image_path != null && image_path != ''){
            $('#upload-in-progress').html('<i>'+gon.vars['new_image_uploading']+'</i>');
        }
    });


    $("#items a.add_fields").
        data("association-insertion-position", 'before').
        data("association-insertion-node", 'this');

    $('#items').on('cocoon:after-insert',
        function() {
            $(".ad-item-fields a.add_fields").
                data("association-insertion-position", 'before').
                data("association-insertion-node", 'this');
                $('.selectpicker').selectpicker('refresh');
                bindTypeaheadToItemSelect($('#items .selectpicker-items'));

            $('.ad-item-fields').on('cocoon:after-insert',
                function() {
                    $(this).children(".item_from_list").remove();
                    $(this).children("a.add_fields").hide();
                });
        });

    $('.ad-item-fields').bind('cocoon:after-insert',
        function(e) {
            e.stopPropagation();
            $(this).find(".item_from_list").remove();
            $(this).find("a.add_fields").hide();
            $('.selectpicker').selectpicker('refresh');
        });


    // Location form: show appropriate section when entering an exact address
    function show_exact_address_section(){
        $("#postal_code_section").removeClass('hide');
        $("#district_section").addClass('hide');
        $(".exact_location_section").removeClass('hide');
        location_marker_type = 'exact';
        map.on('click', onMapClickLocation);
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').removeClass('hide');
    }

    $(".location_type_exact").click(function(){
        show_exact_address_section();
        if (newmarker != null){
            map.removeLayer(newmarker);
        }
    });

    if($('.location_type_exact').is(':checked')) {
        show_exact_address_section();
    }


    // Location form: show appropriate section when choosing a postal code-based area
    function show_postal_code_section(){
        $(".exact_location_section").addClass('hide');
        $("#district_section").addClass('hide');
        $("#postal_code_section").removeClass('hide');
        location_marker_type = 'area';
        map.on('click', onMapClickLocation);
        $('#map_notification_postal_code_only').removeClass('hide');
        $('#map_notification_exact').addClass('hide');
    }

    $(".location_type_postal_code").click(function(){
        show_postal_code_section();
        if (newmarker != null){
            map.removeLayer(newmarker);
        }
    });

    if($('.location_type_postal_code').is(':checked')) {
        show_postal_code_section();
    }


    // Location form: show appropriate section when choosing a district-based area
    function show_district_section(){
        $(".exact_location_section").addClass('hide');
        $("#postal_code_section").addClass('hide');
        $("#district_section").removeClass('hide');
        $('#map_notification_postal_code_only').addClass('hide');
        $('#map_notification_exact').addClass('hide');
        location_marker_type = 'area';
        map.off('click', onMapClickLocation);
        $("#map_notification").addClass('hide');
    }
    $(".location_type_district").click(function(){
        show_district_section();
        if (newmarker != null){
            map.removeLayer(newmarker);
        }
    });
    if($('.location_type_district').is(':checked')) {
        show_district_section();
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
                                $('#postal_code_notification').html("<i>"+ gon.vars['area_show_up'] +"'"+postal_code_value.substring(0, area_code_length)+"'</i>");
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
                $('#findGeocodeLoaderId').html(gon.vars['searching_location']);
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

    // This is to correct a behavior that was happening in Chrome: when clicking on the zoom control panel, in the home page, the page would scroll down.
    // When clicking on zoom in/zoom out, this will force to be at the top of the page
    $('.home-page .leaflet-control-zoom-out, .home-page .leaflet-control-zoom-in').click(function(){
        $("html, body").animate({ scrollTop: 0 }, 0);
    });

});
