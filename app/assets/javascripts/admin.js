$(document).ready(function(){

    // Map settings admin page: refreshing map, when "Map type" field is modified.
    $('#maptype').change(function(){
        var selected_map = "";
        $( "select option:selected" ).each(function() {
            selected_map = $(this).val();
        });
        map_settings_array['chosen_map'] = selected_map;
        map_settings_array['tiles_url'] = map_settings_array[selected_map]['tiles_url']
        map_settings_array['attribution'] = map_settings_array[selected_map]['attribution']
        initLeafletMap(map_settings_array);

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
        initLeafletMap(map_settings_array);
    });

    if($('.area_district').is(':checked')) {
        $("#district_section").css('display', 'block');
        initLeafletMap(map_settings_array);
    }

    // "Edit ad" form: create message when image needs to be uploaded.
    $('#ad-edit-form').submit(function() {
        var image_path = $('#ad_image').val();
        if (image_path != null && image_path != ''){
            $('#upload-in-progress').html('<i>'+gon.vars['new_image_uploading']+'</i>');
        }
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
            '<input type="text" name="mytext[]" id="new_district_text" class="form-control" placeholder="'+gon.vars['type_district_name']+'"/> ' +
            '<span class="latitude_text">'+gon.vars['latitude']+'</span>, <span class="longitude_text">'+gon.vars['longitude']+'</span>&nbsp;' +
            '<button type="button" id="new_dynamic_button_add" class="btn btn-info btn-sm disabled">'+gon.vars['add']+'</button>&nbsp;' +
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
            $(this).text(gon.vars['update']);

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
            $('#district_message_notification').html(gon.vars['updating_district']);
            var status = ''
            var posting = $.post("/user/areasettings/update_districts", { data: districts, dataType: 'json'}, function(data) {status = data.status})

            posting.done(function() {
                if (status == 'ok'){
                    // Districts were updated via
                    $('#district_message_notification').html('');
                    $("#areaSettingFormId").submit();
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

});


/**
 * Function that adds a district to the list of districts, in the "Area settings" page (admin panel)
 * @param e
 */
function add_district(e){
    var latitude_text = $(".latitude_text").first().text();
    var longitude_text = $(".longitude_text").first().text();

    var to_append = '<tr><td>'+$("#new_district_text").val()+'</td><td class="center">'+latitude_text+'</td><td class="center">'+longitude_text+'</td><td class="center"><button id='+new_district_index+' type="button" class="dynamic_update btn btn-info btn-xs">'+gon.vars['update']+'</button></td></tr>';
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