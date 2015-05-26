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
                    emptyTitle: 'Search for items...',
                    statusInitialized: 'Start typing an item',
                    statusNoResults: "No results. Select 'Create a new item'."
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
            $('#upload-in-progress').html('<i>New image is being uploaded. Please wait.</i>');
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


    // Area settings page: JQuery snippet to add text fields dynamically, when "Add district..." link is clicked.
    var wrapper         = $("#dynamic_wrapper"); //Fields wrapper
    var add_button      = $("#dynamic_add_link"); //Add button ID

    $(add_button).click(function(e){ //on add input button click
        e.preventDefault();
        $(".dynamic_update").addClass('disabled');
        $(".dynamic_remove").addClass('disabled');
        $("#dynamic_add_link").addClass('disabled');
        $('.remove-existing-district').addClass('disabled');

        // Area setting page, for list of districts
        var html_to_append = '<div class="form-group"><div class="form-inline">' +
        '<input type="text" name="mytext[]" id="new_district_text" class="form-control" placeholder="Type a district name here..."/> ' +
        '<span class="latitude_text">(latitude)</span>, <span class="longitude_text">(longitude)</span>&nbsp;' +
        '<button type="button" id="new_dynamic_button_add" class="btn btn-info btn-sm disabled">Add</button>&nbsp;' +
            '<a href="#" class="remove_field"><i class="glyphicon glyphicon-remove" style="color: red;"></i></a>' +
        '</div></div>';

        // Adding dynamically the fields to the page.
        $(wrapper).append(html_to_append); //add input box

    });

    var is_being_updated = false;

    // Event to fire, when "Update"/"OK" links are clicked, when updating an existing district
    $('#dynamic-table').on("click",".dynamic_update", function(e){
        // We are on the "Manage area" admin page.
        e.preventDefault();

        var district_id = $(this).attr('id');
        var longitude_td = $(this).parent().prev();
        var latitude_td = longitude_td.prev();
        var name_td = latitude_td.prev();

        if (is_being_updated){
            // User just clicked on 'OK' button.
            $(this).removeClass('being-updated');
            $(this).text("Update");

            var district_name = name_td.val();
            var new_name = $('#district_name_update').val();

            // We update the json object that will be sent to server, on form submit.
            districts[district_id]['name'] = new_name;
            districts[district_id]['latitude'] = latitude_td.text();
            districts[district_id]['longitude'] = longitude_td.text();

            name_td.html(new_name);
            latitude_td.removeClass('latitude_text');
            longitude_td.removeClass('longitude_text');

            $("#dynamic_add_link").removeClass('disabled');
            $(".dynamic_update").removeClass('disabled');
            $("#area_settings_submit").removeClass('disabled');
            $('.remove-existing-district').removeClass('disabled');

            is_being_updated = false;

            // We remove the marker from the map for this district, as we're done updating.
            map.removeLayer(newmarker);

        }else{
            // User just clicked on 'Update' button
            $(this).addClass('being-updated');
            $(this).text("OK");

            // We're creating an input text field, in order to make update possible
            var district_name = name_td.text();
            name_td.html('<input id="district_name_update" type="text" class="form-control" value="'+district_name+'" />');
            latitude_td.addClass('latitude_text');
            longitude_td.addClass('longitude_text');

            putSingleMarker(latitude_td.text(), longitude_td.text(), 'area', district_name);

            // Disabling a few actions in the district table, while we update the current district.
            $("#dynamic_add_link").addClass('disabled');
            $('.dynamic_update').addClass('disabled');
            $('.remove-existing-district').addClass('disabled');
            $('.being-updated').removeClass('disabled');
            $("#area_settings_submit").addClass('disabled');

            is_being_updated = true;
        }
    });

    // Event when user clicks on the "Remove" link, when about to add a item/district.
    $(wrapper).on("click",".remove_field", function(e){ //user click on remove text
        e.preventDefault(); $(this).parent('div').remove(); x--;
        $(".dynamic_update").removeClass('disabled');
        $("#dynamic_add_link").removeClass('disabled');
    })

    // Event fired when "Add" button is clicked, when adding a new district to the district list.
    $(wrapper).on("click","#new_dynamic_button_add", function (e) {
        // We are on the "Manage area" admin page.
        add_district(e);
    });

    // Area setting page - submit button.
    $('#area_settings_submit').button().click(function () {
        if($('.area_district').is(':checked')) {
            // We need to make a POST Ajax call, to update the districts, before submitting the page.
            $('#district_message_notification').html('Updating district list...');
            var status = ''
            var posting = $.post("/user/areasettings/update_districts", { data: districts, dataType: 'json'}, function(data) {status = data.status})

            posting.done(function() {
                if (status == 'ok'){
                    // Districts were updated via
                    $('#district_message_notification').html('');
                    $( "form:first" ).submit();
                }else{
                    // Something bad happened. We're not submitting the page.
                    $('#district_message_notification').html(status);
                    $('#district_message_notification').attr('style', 'color:red;');
                }
            });
        }else{
            // We're on the postal code page. We just need to submit the page
            $( "form:first" ).submit();
        }
    });

    // Area setting page - Delete an existing district
    $('.remove-existing-district').click(function(){
        var line_to_remove = $(this).closest('tr');
        var index_to_remove = line_to_remove.attr('id');
        districts[index_to_remove]['to_delete'] = true;
        line_to_remove.remove();
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


/**
 * Function that adds a district to the list of districts, in the "Area settings" page (admin panel)
 * @param e
 */
function add_district(e){
    var latitude_text = $(".latitude_text").first().text();
    var longitude_text = $(".longitude_text").first().text();

    var to_append = '<tr><td>'+$("#new_district_text").val()+'</td><td class="center">'+latitude_text+'</td><td class="center">'+longitude_text+'</td><td class="center"><button id='+new_district_index+' type="button" class="dynamic_update btn btn-info btn-xs">Update</button></td></tr>';
    $("#district_body").append(to_append);

    districts[new_district_index] = {};
    districts[new_district_index]['name'] = $("#new_district_text").val();
    districts[new_district_index]['latitude'] = latitude_text;
    districts[new_district_index]['longitude'] = longitude_text;
    new_district_index = new_district_index + 1;

    e.preventDefault();

    // Removing the input field we used to add a district.
    $('#dynamic_wrapper').empty();

    $(".dynamic_update").removeClass('disabled');
    $(".dynamic_remove").removeClass('disabled');
    $('.remove-existing-district').removeClass('disabled');
    $("#dynamic_add_link").removeClass('disabled');
}
