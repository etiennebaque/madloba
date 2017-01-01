# Constants file

# OpenStreetMap's Nominatim webservice end point (used to retrieve geocodes)
OSM_NOMINATIM_URL = 'http://nominatim.openstreetmap.org/search?q=%{location}&format=json&polygon=0&addressdetails=0&accept-language=en'

GENERAL_AREA_ZOOM_LEVEL = 14
CLOSER_ZOOM_LEVEL = 16
MAX_ZOOM_LEVEL = 18

# Marker colors name and hexa-codes
MARKER_COLORS = {
    'blue' => '#38aadd',
    'cadetblue' => '#436978',
    'darkblue' => '#0066a2',
    'darkgreen' => '#728224',
    'darkpurple' => '#5b396b',
    'darkred' => '#a23336',
    'green' => '#72b026',
    'orange' => '#f69730',
    'purple' => '#d252b9',
    'red' => '#d63e2a',
}

# Selection of Font-Awesome icons, to be displayed in popup, when editing categories.
ICON_SELECTION =
    %w(fa-anchor fa-archive fa-automobile fa-beer fa-bell-o fa-bicycle fa-binoculars fa-birthday-cake fa-book
       fa-bug fa-bullhorn fa-bus fa-calculator fa-camera fa-car fa-check fa-child fa-circle fa-clock-o fa-cloud
       fa-coffee fa-cog fa-cutlery fa-envelope-o fa-exclamation-triangle fa-fax fa-female fa-film fa-flash fa-flask
       fa-futbol-o fa-gamepad fa-gift fa-glass fa-headphones fa-heart fa-home fa-laptop fa-leaf fa-lightbulb-o
       fa-male fa-money fa-moon-o fa-paint-brush fa-paw fa-phone fa-plane fa-plug fa-road fa-square fa-star
       fa-sun-o fa-thumbs-o-up fa-ticket fa-trash fa-angellist fa-briefcase fa-dashboard fa-envelope fa-globe
       fa-music fa-newspaper-o fa-tree fa-trophy fa-truck fa-umbrella fa-user fa-users fa-video-camera
       fa-wheelchair fa-wifi fa-wrench)

# Cache keys
CACHE_SETUP_STEP = 'cache_setup_step'
CACHE_APP_NAME = 'cache_app_name'
CACHE_CITY_NAME = 'cache_city_name'
CACHE_COUNTRY_NAME = 'cache_country_name'
CACHE_IMAGE_STORAGE = 'cache_image_storage'
CACHE_MAX_DAYS_EXPIRE = 'cache_max_days_expire'
CACHE_AREAS = 'cache_areas'
CACHE_CHOSEN_LANGUAGE = 'cache_chosen_language'

# Image storage constants
IMAGE_NO_STORAGE = 'nostorage'
IMAGE_AMAZON_S3 = 's3'
IMAGE_ON_SERVER = 'server'

# Constants used for type-ahead functionalities
PREFETCH_POST_ITEMS = 'prefetch_post_items'
SEARCH_IN_POST_ITEMS = 'search_post_items'
PREFETCH_ALL_ITEMS = 'prefetch_items'
SEARCH_IN_ALL_ITEMS = 'search_items'
