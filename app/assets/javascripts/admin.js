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

});
