# Server side of the websocket in charge of showing the relevant ads on the home page,
# based on guided navigation selection.
class AdSocket

  def initialize(app)
     @app = app
     @clients = []
  end

  def call(env)
    @env = env
    if socket_request?
      socket = spawn_socket
      @clients << socket
      socket.rack_response
    else
      @app.call env
    end
  end

  private

  attr_reader :env

  def socket_request?
    Faye::WebSocket.websocket? env
  end

  def spawn_socket
    socket = Faye::WebSocket.new env

    socket.on :message do |event|
      begin
        # the 3 first characters of the incoming message defines what processing needs to take place.
        prefix = event.data[0..2]
        incoming_message = event.data[3..-1]

        if prefix == 'map'
          # From the home page, based on the selected navigation, get the relevant ads.
          new_nav_states = incoming_message.split('&')
          nav_params = {}
          new_nav_states.each do |state|
            info = state.split('=')
            nav_params[info[0]] = info[1]
          end

          if nav_params['cat'] && nav_params['cat'] != ''
            selected_categories = []
            selected_categories = nav_params['cat'].split('+')
          end

          if nav_params['item'] && nav_params['item'] != ''
            selected_item_ids = []
            # An item is being searched.
            searched_item = nav_params['item']
            selected_item_ids = Item.joins(:ads).where('name LIKE ?', "%#{searched_item}%").pluck(:id).uniq
          end

          response = {}
          response['status'] = 'mapok'
          response['map_info'] = {}
          response['map_info']['markers'] = Ad.search(selected_categories, searched_item, selected_item_ids, nav_params[:q], nil)
          response['map_info']['postal'] = Location.search('postal', selected_categories, searched_item, selected_item_ids, nav_params[:q], nil)
          response['map_info']['district'] = Location.search('district', selected_categories, searched_item, selected_item_ids, nav_params[:q], nil)

          socket.send response.to_json(:include => { :ads => { :include =>  {:items => { :include => :category }}}})

        elsif prefix == 'new'
          # Adding new ad on the home page map of other users.
          ad_id = incoming_message.to_i
          response = {}
          response['status'] = 'new_ad'
          response['map_info'] = {}
          response['map_info']['markers'] = Ad.search(nil, nil, nil, nil, ad_id)

          @clients.reject { |client| client == socket }.each do |client|
            client.send response.to_json(:include => { :ads => { :include =>  {:items => { :include => :category }}}})
          end

        end

      rescue Exception => e
        p e
        p e.backtrace
        response['status'] = 'error'
        response['map_info'] = I18n.t('errors.ws_error')
      end
    end

    socket
  end

end