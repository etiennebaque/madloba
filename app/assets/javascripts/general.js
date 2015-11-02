// Object used for autocompletion when user searches for an item, in navigation bar
searched_ad_items = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
        url: '/getItems?item=QUERY&type=search_ad_items',
        wildcard: 'QUERY'
    }
});

searched_ad_items.clearPrefetchCache();
searched_ad_items.initialize();

// Object containing the scripts to load on different pages of the application.
// See 'custom-leaflet.js' file for map-related scripts.
var events = {
    
    // Scripts to load on the "New Ad" page.
    init_new_ad_page: function() {
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
        // Initially created in 'application.html.erb' layout, this div is now removed.
        $("#ad-block").remove();

        // On the "New ad" form, open automatically the new location form, if the user is anonymous,
        // or never created any location as a signed in user.
        if (typeof current_page != "undefined" && current_page == "new_ad"
            && typeof can_choose_existing_locations != "undefined" && can_choose_existing_locations == false){
            setTimeout(function() {
                $("#new_location_form a.add_fields").trigger('click');
                $("#locations_from_list").hide();
                $("#location a.add_fields").hide();
                initLeafletMap(map_settings);
                init_location_form(districts_bounds, leaf.map);
            },20);
        }

        // Create an ad: adding the location form dynamically, via Cocoon
        $("#new_location_form a.add_fields").
            data("association-insertion-position", 'before').
            data("association-insertion-node", 'this');

        $('#new_location_form').bind('cocoon:after-insert',
            function() {
                $("#locations_from_list").hide();
                $("#new_location_form a.add_fields").hide();
                // Call to the JS functions that will initialize the new location form and the map.
                initLeafletMap(map_settings);
                init_location_form(districts_bounds, leaf.map);
            });
        $('#new_location_form').bind("cocoon:after-remove", function() {
            $("#locations_from_list").show();
            $("#new_location_form a.add_fields").show();
        });
    },

    // Scripts to load on the "New Ad" and "Edit Ad" page.
    init_new_and_edit_pages: function(){
        bindTypeaheadToItemSelect($('#items .selectpicker-items'));

        // "Create/Edit ad" form: create message when image needs to be uploaded.
        $('#new_ad').submit(function() {
            var image_path = $('#ad_image').val();
            if (image_path != null && image_path != ''){
                $('#upload-in-progress').html('<i>'+gon.vars['new_image_uploading']+'</i>');
            }
        });

        // Events to be triggered when item field added or removed, in the ad form.
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
            }
        );

        // Function call to initialize the location form (Location edit form, all Ad forms).
        if (typeof districts_bounds != "undefined") {
            init_location_form(districts_bounds, leaf.map);
        }
    },

    // Scripts to load on the "Setup" pages.
    init_setup_pages: function() {
        // Setup pages - event for modal window on Map page.
        $('#gmail_modal_link').click(function(){
            $('#gmail_modal').modal('show');
        });
    },

    // Scripts related to the events on the navigation bar.
    init_navigation_bar: function() {
        // Navigation bar: press Enter to valid form.
        $("#searchFormId input").keypress(function(event) {
            if (event.which == 13) {
                event.preventDefault();
                getLocationsPropositions();
            }
        });

        // Navigation bar: event tied to "up" arrow, to go back to the top of the page.
        $('#navbar-up-link').click(function(){
            $('html, body').animate({ scrollTop: 0 }, 1000);
        });

        //Checks if we need to show the arrow up, in the navigation bar, on mobile devices.
        show_hide_up_arrow();

        $(window).on("scroll", function() {
            show_hide_up_arrow();
        });

        // Navigation - Search form: Ajax call to get locations proposition, based on user input in this form.
        $("#btn-form-search").bind("click", getLocationsPropositions);

        // Navigation bar on device: closes the navigation menu, when click.
        $('#about-nav-link').on('click', function(){
            if($('.navbar-toggle').css('display') !='none'){
                $(".navbar-toggle").click()
            }
        });

        // Home page: When clicking on about, scroll to the home page upper footer.
        $("#about-nav-link").click(function(){
            $('html, body').animate({
                scrollTop: $("#upper-footer-id").offset().top
            }, 2000);
        });

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
        $('#item').typeahead(null, {
            name: 'item-search',
            display: 'value',
            source: searched_ad_items
        });

        // Navigation bar: changing the typeahead query, depending of user choice between "I'm giving away" and "I'm searching for"
        $('#q').change(function(){
            searched_ad_items.remote.url = '/getItems?item=QUERY&type=search_ad_items&q='+$('#q').val();
            // As the type of search changes, the item name field needs to be reset.
            $('#item').val('');
        }).change();
    },

    // Scripts related to the home page and some other pages.
    init_home_page_and_others: function() {
        // Offcanvas related scripts
        $('[data-toggle=offcanvas]').click(function() {
            $('.row-offcanvas').toggleClass('active');
        });

        // This event replaces the 'zoomToBoundsOnClick' MarkerCluster option. When clicking on a marker cluster,
        // 'zoomToBoundsOnClick' would zoom in too much, and push the markers to the edge of the screen.
        // This event underneath fixes this behaviour, the markers are not pushed to the boundaries of the map anymore.
        if(markers.group != ''){
         markers.group.on('clusterclick', function (a) {
         var bounds = a.layer.getBounds().pad(0.5);
         leaf.map.fitBounds(bounds);
         });
        }

        // This is to correct a behavior that was happening in Chrome: when clicking on the zoom control panel, in the home page, the page would scroll down.
        // When clicking on zoom in/zoom out, this will force to be at the top of the page
        $('#home-map-canvas-wrapper .leaflet-control-zoom-out, #home-map-canvas-wrapper .leaflet-control-zoom-in').click(function(){
            $("html, body").animate({ scrollTop: 0 }, 0);
        });
    },

    // Scripts related to the admin pages.
    init_admin_pages: function(){
        // Map settings admin page: refreshing map, when "Map type" field is modified.
        $('#maptype').change(function(){
            var selected_map = "";
            $( "select option:selected" ).each(function() {
                selected_map = $(this).val();
            });
            map_settings['chosen_map'] = selected_map;
            map_settings['tiles_url'] = map_settings[selected_map]['tiles_url']
            map_settings['attribution'] = map_settings[selected_map]['attribution']
            initLeafletMap(map_settings);
        });

        // Area settings admin page: show either the "postal code" or the "district" section.
        // "Create ad" form: show appropriate section when entering an exact address
        $(".area_postal_code").click(function(){
            $("#postal_code_section").toggle(0, function(){});
        });

        if($('.area_postal_code').is(':checked')) {
            $("#postal_code_section").css('display', 'block');
        }

        // Area settings page: show appropriate section when choosing an area
        $(".area_district").click(function(){
            $("#district_section").toggle(0, function(){});
            initLeafletMap(map_settings);
        });

        if($('.area_district').is(':checked')) {
            $("#district_section").css('display', 'block');
            initLeafletMap(map_settings);
        }

        // "Edit ad" form: create message when image needs to be uploaded.
        $('#ad-edit-form').submit(function() {
            var image_path = $('#ad_image').val();
            if (image_path != null && image_path != ''){
                $('#upload-in-progress').html('<i>'+gon.vars['new_image_uploading']+'</i>');
            }
        });

        // Character counter (class 'textarea_count'), for text area, in 'General settings'.
        $( ".textarea_count" ).keyup(function() {
            var maxlength = $(this).attr('maxlength');
            var textlength = $(this).val().length;
            $(".remaining_characters").html(maxlength - textlength);
        });

        $( ".textarea_count" ).keydown(function() {
            var maxlength = $(this).attr('maxlength');
            var textlength = $(this).val().length;
            $(".remaining_characters").html(maxlength - textlength);
        });

        // Category edit page: opening up the icon modal window.
        $(".btn-icon-modal").click(function (){
            $('#myModalIcon').modal('show');
        });

        // Onclick event triggered when Icon clicked in modal window, in Category edit page.
        $(".icon-for-category").click(function (){
            var icon_key = $(this).attr('id');
            $('#myModalIcon').modal('toggle');
            $('#category_icon').val(icon_key);
        });

        // Manage record page: go to the right tab, if page loads with an anchor in url (like 'http://...#categories')
        if (window.location.href.indexOf("managerecords") > -1 && window.location.hash){
            $('#records-tabs a[href='+window.location.hash+']').tab('show')
        }
    }
}

/**
 * Loading scripts here.
 */
$(document).ready(function() {

    events.init_home_page_and_others();
    events.init_new_ad_page();
    events.init_new_and_edit_pages();
    events.init_navigation_bar();
    events.init_setup_pages();

    // load additional scripts when user is in the admin panel.
    if (is_in_admin_panel()) {
        events.init_admin_pages();
    }

});


/**
 * Function that binds events to the item drop down list (in ads#new and ads#edit pages)
 * These events consists of making ajax call to check what items exists, in order to
 * create a type-ahead for the search bar of that drop drown box.
 * @param object
 */
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
                    var params = {item: '{{{q}}}', type: 'search_items'};
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
                // Populating the item drop-down box
                for(var i = 0; i < len; i++){
                    var item = data[i];
                    items.push({'value': item.id, 'text': item.value, 'disable': false});
                }
                return items;
            },
            preserveSelected: false
        });
}


/**
 * This critical function initializes the location form (Location edit form, Ad forms)
 * as well as all the events tied to its relevant elements.
 */
function init_location_form(districts_bounds, map){

    if ($('#map').length > 0){
        $(".location_type_exact").click(function(){
            removes_location_layers();
            show_exact_address_section();
        });

        if($('.location_type_exact').is(':checked')) {
            show_exact_address_section();
        }

        $(".location_type_postal_code").click(function(){
            removes_location_layers();
            show_postal_code_section();
        });

        if($('.location_type_postal_code').is(':checked')) {
            show_postal_code_section();
        }

        $(".location_type_district").click(function(){
            removes_location_layers();
            show_district_section();
        });

        if($('.location_type_district').is(':checked')) {
            show_district_section();
        }
    }

    // "Postal code" functionality: display a help message to inform about what the area will be named,
    // after the postal code is entered.
    $('.location_postal_code').focusout(function() {
        if($('.location_type_postal_code').is(':checked')) {
            var area_code_length, postal_code_length;
            var postal_code = $('.location_type_postal_code').val();
            var postal_code_value = $('.location_postal_code').val();

            if(typeof area_code_length == 'undefined' && typeof postal_code_length == 'undefined'){

                $.get("/user/getAreaSettings", {}, function (data){
                    if (data['code'] != null && data['area'] != null){
                        // Based on the retrieved settings, we display which area code will be used for this ad.
                        area_code_length = data['area'];
                        if (postal_code.length >= area_code_length){
                            $('#postal_code_notification').html("<i>"+ gon.vars['area_show_up'] +"'"+postal_code_value.substring(0, area_code_length)+"'</i>");
                        }
                    }
                });

            }
        }
    });

    // Help messages for fields on "Create ad" form
    $('.help-message').popover();

    // Initializing onclick event on "Locate me on the map" button, when looking for location on map, based on user input.
    find_geocodes();
}


/**
 * Event triggered when click on "Locate me on the map" button,
 * on the "Create ad" form, and on the Ad edit form.
 */
function find_geocodes(){
    $('#findGeocodeAddressMapBtnId').button().click(function () {

        var location_type = 'exact';

        if ($('.location_type_postal_code').is(':checked')){
            // We're on the location edit page, and 'Postal code' or 'District' location type is checked.
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
                if (data != null && data.status == 'ok'){
                    // Geocodes were found: the location is shown on the map.
                    var myNewLat = Math.round(data.lat*100000)/100000
                    var myNewLng = Math.round(data.lon*100000)/100000

                    $(".latitude_hidden").val(myNewLat);
                    $(".longitude_hidden").val(myNewLng);

                    // Update the center of map, to show the general area
                    leaf.map.setView(new L.LatLng(myNewLat, myNewLng), data.zoom_level);

                }else{
                    // The address' geocodes were not found - the user has to pinpoint the location manually on the map.
                    $('#myErrorModal').modal('show');
                }
                // Displaying notification about location found.
                $('#findGeocodeLoaderId').html('<i>'+data.address_found+'</i>');
            }
        });

    });
}


/**
 * On the location form, removes layers representing a previously clicked exact location, postal code area,
 * or selected district.
 */
function removes_location_layers(){
    if (markers.new_marker != null){leaf.map.removeLayer(markers.new_marker);}
    if (markers.selected_area != null){leaf.map.removeLayer(markers.selected_area);}
    if (markers.postal_code_circle != null){leaf.map.removeLayer(markers.postal_code_circle);}
}

/**
 * Function used in the location form - show appropriate section when entering an exact address
 */
function show_exact_address_section(){
    $("#postal_code_section").removeClass('hide');
    $("#district_section").addClass('hide');
    $(".exact_location_section").removeClass('hide');
    markers.location_marker_type = 'exact';
    leaf.map.on('click', onMapClickLocation);
    $('#map_notification_postal_code_only').addClass('hide');
    $('#map_notification_exact').removeClass('hide');
}


/**
 * Function used in the location form - show appropriate section when choosing a postal code-based area
 */
function show_postal_code_section(){
    $(".exact_location_section").addClass('hide');
    $("#district_section").addClass('hide');
    $("#postal_code_section").removeClass('hide');
    markers.location_marker_type = 'area';
    leaf.map.on('click', onMapClickLocation);
    $('#map_notification_postal_code_only').removeClass('hide');
    $('#map_notification_exact').addClass('hide');
}


/**
 * Function used in the location form - show appropriate section when choosing a district-based area
 */
function show_district_section(){
    $(".exact_location_section").addClass('hide');
    $("#postal_code_section").addClass('hide');
    $("#district_section").removeClass('hide');
    $('#map_notification_postal_code_only').addClass('hide');
    $('#map_notification_exact').addClass('hide');
    markers.location_marker_type = 'area';
    leaf.map.off('click', onMapClickLocation);
    $("#map_notification").addClass('hide');

    // Loading the district matching the default option in the district drop-down box.
    var id = $('.district_dropdown option:selected').val();
    var name = $('.district_dropdown option:selected').text();
    var bounds = districts_bounds[id];

    leaf.show_single_district(name, bounds);

    // Location form: when choosing a district from the drop-down box, we need to display the area on the map underneath.
    $('#district_section').on('change', '.district_dropdown', function() {
        id = $('.district_dropdown option:selected').val();
        name = $('.district_dropdown option:selected').text();
        bounds = districts_bounds[id];

        leaf.show_single_district(name, bounds);

    }).change();
}

/**
 * Before submitting the form with the location, we first do an Ajax call to see
 * if the Nominatim webservice comes back with several addresses.
 *
 * if it does, we show a modal window with this list of addresses. Once one is chosen,
 * the form is submitted.
 */
function getLocationsPropositions(){
    if ($('#location').val() != ''){
        // A location has been entered, let's use the Nominatim web service
        var locationInput = $('#location').val();
        $.ajax({
            url: "/getNominatimLocationResponses",
            global: false,
            type: "GET",
            data: { location: locationInput },
            cache: false,
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Accept", "application/json");
                xhr.setRequestHeader("Content-Type", "application/json");
                $("#btn-form-search").html("Loading...");
            },
            success: function(data) {
                var modalHtmlText = "";
                if (data != null && data.length > 0){
                    if (typeof data[0]['error_key'] != 'undefined'){
                        // There's been an error while retrieving info from Nominatim,
                        // or there is no result found for this address.
                        $('#search_error_message').html('<strong>'+data[0]['error_key']+'</strong>');
                    }else{
                        // Address suggestions were found.
                        // We need to create the HTML body of the modal window, based on the location proposition from OpenStreetMap.
                        modalHtmlText = "<p>Choose one of the following available locations</p><ul></ul>";

                        // We also need to consider whether an item is being searched/given at the same time.
                        var item = $('#item').val();
                        var search_action = $('#q').val();

                        for (var i = 0; i < data.length; i++) {
                            var proposed_location = data[i];
                            var url = "/search?lat="+proposed_location['lat']+"&lon="+proposed_location['lon']+"&loc="+proposed_location['display_name'];
                            if (item != ''){
                                url = url + "&item=" + item;
                            }
                            if (search_action != ''){
                                url = url + "&q=" + search_action;
                            }

                            modalHtmlText = modalHtmlText + "<li><a href='"+encodeURI(url)+"'>"+proposed_location['display_name']+"</a></li>";
                        }
                        modalHtmlText = modalHtmlText + "</ul>";
                        $('#modal-body-id').html(modalHtmlText);
                        var options = {
                            "backdrop" : "static",
                            "show" : "true"
                        }
                        $('#basicModal').modal(options);
                    }

                }

                // Webservice response came back - button label goes back to "Search"
                $("#btn-form-search").html("Search");

            }
        });
    }else if (($('#item').val() != '') || ($('#user_action').val() != '')){
        // no location is being searched, but an item is. We need to submit the form with this information.
        $("#searchFormId").submit();
    }
}

/**
 * Checks if we need to show the arrow up, in the navigation bar, on mobile devices.
 */
function show_hide_up_arrow (){
    var scrollPos = $(window).scrollTop();
    if (scrollPos <= 0) {
        $("#navbar-up-link").hide();
    } else {
        $("#navbar-up-link").show();
    }
}

/**
 * Checks whether the user is in the admin panel (has '/user/' in the url)
 */
function is_in_admin_panel(){
    return window.location.href.indexOf("/user/") > -1
}