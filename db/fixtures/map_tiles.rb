MapTile.seed(:id,
  {id: 1, name: 'open_street_map', tile_url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'},
  {id: 2, name: 'mapbox', map_name: 'mapbox.streets'},
  {id: 3, name: 'map_quest', tile_url: 'https://www.mapquestapi.com/sdk/leaflet/v2.2/mq-map.js?key=<api_key>'}
)