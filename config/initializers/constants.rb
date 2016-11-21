# Constants file
#
# Constants used across the application can be found here.

# Map tiles URL, and attribution mentions (for OSM, Mapbox and MapQuest)
# Some constants here need substitution when they're used (eg. MAPBOX_TILES_API).
OSM_TILES_URL='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
OSM_ATTRIBUTION='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
MAPBOX_TILES_URL='https://{s}.tiles.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=%{api_key}'
MAPBOX_ATTRIBUTION='<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'
MAPQUEST_TILES_URL='http://open.mapquestapi.com/sdk/leaflet/v1.s/mq-map.js?key=%{api_key}'

# OpenStreetMap's Nominatim webservice end point (used to retrieve geocodes)
OSM_NOMINATIM_URL = 'http://nominatim.openstreetmap.org/search?q=%{location}&format=json&polygon=0&addressdetails=0&accept-language=en'

# Constants for controllers, when initializing map.
AD_FLAG_FOR_MAP = 'ad'
ADMIN_FLAG_FOR_MAP = 'admin'
AREA_FLAG_FOR_MAP = 'area'
SHOW_AD_FLAG_FOR_MAP = 'show_ad'

NOT_CLICKABLE_MAP = 'none'
CLICKABLE_MAP_EXACT_MARKER = 'exact'
CLICKABLE_MAP_AREA_MARKER = 'area'

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
PREFETCH_AD_ITEMS = 'prefetch_ad_items'
SEARCH_IN_AD_ITEMS = 'search_ad_items'
PREFETCH_ALL_ITEMS = 'prefetch_items'
SEARCH_IN_ALL_ITEMS = 'search_items'
