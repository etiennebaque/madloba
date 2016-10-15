Todo.seed(:id,
   {id: 1, description: 'no_category', condition: 'any_category?', alert: 'danger'},
   {id: 2, description: 'one_category', condition: 'more_than_one_category?', alert: 'warning'},
   {id: 3, description: 'no_area_type', condition: 'area_types?', alert: 'info'},
   {id: 4, description: 'mapbox_missing', condition: 'mapbox_ready?', alert: 'warning'},
   {id: 5, description: 'mapquest_missing', condition: 'mapquest_ready?', alert: 'warning'},
   {id: 6, description: 'description_missing', condition: 'description?', alert: 'info'},
   {id: 7, description: 'no_social_media', condition: 'social_media?', alert: 'info'}
)