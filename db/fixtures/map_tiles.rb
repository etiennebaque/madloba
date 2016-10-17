MapTile.seed(:id,
  {id: 1, name: 'open_street_map', tile_url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'},
  {id: 2, name: 'mapbox', tile_url: 'https://{s}.tiles.mapbox.com/v4/<map_id>/{z}/{x}/{y}.png?access_token=<api_key>',  map_name: 'mapbox.streets'},
  {id: 3, name: 'map_quest', tile_url: 'https://www.mapquestapi.com/sdk/leaflet/v2.2/mq-map.js?key=<api_key>', attribution: "© <a href='https://www.mapbox.com/about/maps/'>Mapbox</a> © <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> <strong><a href='https://www.mapbox.com/map-feedback/' target='_blank'>Improve this map</a></strong>"}
)