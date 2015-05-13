$(document).ready(function(){

    // Events related to the search form on the home page
    $("#searchFormId input").keypress(function(event) {
        if (event.which == 13) {
            event.preventDefault();
            getLocationsPropositions();
        }
    });

    $("#btn-form-search").bind("click", getLocationsPropositions);

    // When clicking on about, scroll to the home page upper footer.
    $("#about-nav-link").click(function(){
        $('html, body').animate({
            scrollTop: $("#upper-footer-id").offset().top
        }, 2000);
    });

});


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
                        modalHtmlText = "<p>Choose one of the following available locations, provided by OpenStreetMap</p><ul></ul>";

                        // We also need to consider whether an item is being searched/given at the same time.
                        var item = $('#item').val();
                        var search_action = $('#q').val();

                        for (var i = 0; i < data.length; i++) {
                            var proposed_location = data[i];
                            var url = "/search?lat="+proposed_location['lat']+"&lon="+proposed_location['lon'];
                            if (item != ''){
                                url = url + "&item=" + item;
                            }
                            if (search_action != ''){
                                url = url + "&q=" + search_action;
                            }

                            modalHtmlText = modalHtmlText + "<li><a href='"+url+"'>"+proposed_location['display_name']+"</a></li>";
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

                $("#btn-form-search").html("Search");

            }
        });
    }else if (($('#item').val() != '') || ($('#user_action').val() != '')){
        // no location is being searched, but an item is. We need to submit the form with this information.
        $("#searchFormId").submit();
    }
}

