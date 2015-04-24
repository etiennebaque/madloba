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

    function get_category_name() {
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
    }

    // Activates type-ahead on the "Create an Ad" page
    if (typeof all_items != 'undefined'){
        $('#ad_item').typeahead({source: all_items});
        $('.ad_item').typeahead({source: all_items});
    }

    // When the focus is out of the item field, we check whether this item is already in the database.
    // If it is, the category for this item already exists. If it is not, the user has to choose a category for this new item.
    // Also, the 'sendAjaxRequest' variable is used to make sure that we make only 1 Ajax call - using timeout was making multiple
    // unnecessary ajax calls (timeout is needed in order to make sure the item field is populated after onclick on typeahead, before making ajax call).
    var sendAjaxRequest = false;
    $('#ad_item').focusin(function(){
        sendAjaxRequest = true;
    });


    $('#ad_item').on('focusout change', function(){
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


    // "Create/Edit ad" form: adding items
    // Add text fields dynamically, when "Add item" link is clicked.


    /*var max_fields      = 10; //maximum input boxes allowed
    var wrapper         = $("#item_wrapper"); //Fields wrapper
    var add_button      = $("#add_item_link"); //Add button ID

    var x = 1; //initial text box count
    $(add_button).click(function(e){ //on add input button click
        e.preventDefault();
        $(".item-update").addClass('disabled');
        $("#add_item_link").addClass('disabled');
        if(x < max_fields){ //max input box allowed
            x++; //text box increment
            var html_to_append = '<div class="form-inline">' + item_name_field +'&nbsp;'+ category_select + '&nbsp;'+
                quantity_field + '&nbsp;'+ '<button type="button" id="new_item_button_add" class="btn btn-info btn-sm disabled">Add item</button>&nbsp;<a href="#" class="remove_field">Remove</a></div>'
            $(wrapper).append(html_to_append); //add input box
            $('#ad_item').typeahead({source: all_items});
            $('#ad_item').focusin(function(){
                sendAjaxRequest = true;
            });
            $('#ad_item').on('focusout change', function(){
                setTimeout(function() {
                    get_category_name();
                }, 400);
            });

        }
    });*/


    // Create/Edit ad page and Area settings page: JQuery snippet to add text fields dynamically, when "Add district..." link is clicked.
    var max_fields      = 10; //maximum input boxes allowed
    var wrapper         = $("#dynamic_wrapper"); //Fields wrapper
    var add_button      = $("#dynamic_add_link"); //Add button ID

    var is_district_page = (window.location.href.indexOf("areasettings") > -1);

    var x = 1; //initial text box count
    $(add_button).click(function(e){ //on add input button click
        e.preventDefault();
        $(".dynamic_update").addClass('disabled');
        $("#dynamic_add_link").addClass('disabled');
        if(x < max_fields){ //max input box allowed
            x++; //text box increment
            var html_to_append = '<div class="form-inline">' + item_name_field +'&nbsp;'+ category_select + '&nbsp;'+
                quantity_field + '&nbsp;'+ '<button type="button" id="new_dynamic_button_add" class="btn btn-info btn-sm disabled">Add</button>&nbsp;<a href="#" class="remove_field">Remove</a></div>'
            //$(wrapper).append('<div class="form-group"><div class="form-inline"><input type="text" name="mytext[]" id="new_district_text" class="form-control" placeholder="Type a district name here..."/> <span class="latitude_text">(latitude)</span>, <span class="longitude_text">(longitude)</span>&nbsp;<button type="button" id="new_district_button_add" class="btn btn-info btn-sm disabled">Add</button>&nbsp;<a href="#" class="remove_field">Remove</a></div></div>'); //add input box
            $(wrapper).append(html_to_append); //add input box

            if (!is_district_page){
                // Create / Edit ad pages: adding typeahead event to added text field.
                $('#ad_item').typeahead({source: all_items});
                $('#ad_item').focusin(function(){
                    sendAjaxRequest = true;
                });
                $('#ad_item').on('focusout change', function(){
                    setTimeout(function() {
                        get_category_name();
                    }, 400);
                    if ($('#ad_item').val().replace(/ /g,'') != ''){
                        $("#new_dynamic_button_add").removeClass('disabled');
                    }
                });
            }

        }
    });

    // Event to fire, when "Update"/"OK" buttons are clicked, when updating an existing district
    var is_being_updated = false;
    $('#dynamic-table').on("click",".dynamic_update", function(e){
        if (is_district_page){
            // We are on the "Manage area" admin page.
            update_district(e, is_being_updated);
        }else{
            // We are on the ad edit or the ad new pages.
            e.preventDefault();

            var updated_item_index = $(this).attr('id').split('aditem_')[1];
            var quantity_td = $(this).parent().prev();
            var categories_td = quantity_td.prev();
            var item_name_td = categories_td.prev();

            if (is_being_updated){
                // User just clicked on 'OK' button.
                $(this).removeClass('being-updated');
                $(this).text("Update");

                // Updating here the hidden value.
                var updated_hidden_value = $("#ad_item").val() + '|' + $("#category").val() + '|' + $("#new_quantity_text").val();
                $( "input[name='items["+updated_item_index+"]']").val(updated_hidden_value);

                item_name_td.html($('#ad_item').val());
                categories_td.html($('#category option:selected').text());
                quantity_td.html($('#new_quantity_text').val());

                $("#dynamic_add_link").removeClass('disabled');
                $(".dynamic_update").removeClass('disabled');
                $("#area_settings_submit").removeClass('disabled');

                is_being_updated = false;

            }else{
                // User just clicked on 'Update' button
                $(this).addClass('being-updated');
                $(this).text("OK");

                // We're creating an input text field, in order to make update possible
                var current_cat = categories_td.text();
                var current_category_select = category_select.replace('>'+current_cat, 'selected >'+current_cat).replace('id="category"','id="category" disabled');

                item_name_td.html('<input autocomplete="off" class="form-control ad_item" data-provide="typeahead" id="ad_item" size="30" type="text" value="'+item_name_td.text()+'">');
                categories_td.html(current_category_select);
                quantity_td.html('<input class="form-control" id="new_quantity_text" value="'+quantity_td.text()+'">');

                $('#ad_item').typeahead({source: all_items});
                $('#ad_item').focusin(function(){
                    sendAjaxRequest = true;
                });
                $('#ad_item').on('focusout change', function(){
                    setTimeout(function() {
                        get_category_name();
                    }, 400);
                });

                $("#dynamic_add_link").addClass('disabled');
                $('.dynamic_update').addClass('disabled');
                $('.being-updated').removeClass('disabled');
                //$("#area_settings_submit").addClass('disabled');

                is_being_updated = true;
            }
        }
    });

    // Event when user clicks on the "Remove" link, when about to add a district.
    $(wrapper).on("click",".remove_field", function(e){ //user click on remove text
        e.preventDefault(); $(this).parent('div').remove(); x--;
        $(".dynamic_update").removeClass('disabled');
        $("#dynamic_add_link").removeClass('disabled');
    })

    // Event fired when "Add" button is clicked, when adding a new district to the district list.
    $(wrapper).on("click","#new_dynamic_button_add", function (e) {
        if (is_district_page){
            // We are on the "Manage area" admin page.
            add_district(e);
        }else{
            // We are on the ad edit or the ad new pages.
            add_item(e, item_index);
            item_index = item_index + 1;
        }

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


    e.preventDefault(); $(this).parent('div').remove(); x--;
    $(".dynamic_update").removeClass('disabled');
    $("#dynamic_add_link").removeClass('disabled');
}

function add_item(e, index){
    var to_append = '<tr><td class="vert-align">'+$("#ad_item").val()+'</td><td class="vert-align">'+$("#category option:selected").text()+'</td><td class="vert-align">'+$("#new_quantity_text").val()+'</td><td class="center"><button id="aditem_'+index+'" type="button" class="dynamic_update btn btn-info btn-xs">Update</button></td></tr>';

    // To each added item, we create the following hidden value: 'item_name|category_id|quatity'
    var hidden_value = $("#ad_item").val() + '|' + $("#category").val() + '|' + $("#new_quantity_text").val();
    var hidden_field = '<input type="hidden" name="items['+index+']" value="'+hidden_value+'"/>';
    $("#items_body").append(to_append).append(hidden_field);

    e.preventDefault();
    $('#dynamic_wrapper').empty();
    $(".dynamic_update").removeClass('disabled');
    $("#dynamic_add_link").removeClass('disabled');
}


function update_district(e, is_being_updated){
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
        latitude_td.attr('id','');
        longitude_td.attr('id','');

        $("#dynamic_add_link").removeClass('disabled');
        $(".dynamic_update").removeClass('disabled');
        $("#area_settings_submit").removeClass('disabled');

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
        latitude_td.attr('class','latitude_text');
        longitude_td.attr('class','longitude_text');

        putSingleMarker(latitude_td.text(), longitude_td.text(), 'area', district_name);

        $("#dynamic_add_link").addClass('disabled');
        $('.dynamic_update').addClass('disabled');
        $('.being-updated').removeClass('disabled');
        $("#area_settings_submit").addClass('disabled');

        is_being_updated = true;
    }
}


function update_item(e, is_being_updated){

}