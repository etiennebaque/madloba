MapTile.seed(:id,
  {id: 1, name: 'openstreetmap', tile_url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'},
  {id: 2, name: 'mapbox', map_name: 'mapbox.streets'},
  {id: 3, name: 'mapquest', tile_url: 'http://open.mapquestapi.com/sdk/leaflet/v1.s/mq-map.js?key=%{api_key}'}
)