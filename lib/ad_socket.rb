# Server side of the websocket in charge of showing the relevant ads on the home page, based on guided navigation selection.
class AdSocket
  def initialize app
     @app = app
     @clients = []
  end

  def call env
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
        # Based on the selected navigation, get the relevant ads.
        new_nav_states = event.data.split('&')
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
          selected_item_ids = Item.joins(:ads).where("name LIKE '%#{searched_item}%'").pluck(:id).uniq
        end

        response = {}
        response['status'] = 'mapok'
        response['map_info'] = {}
        response['map_info']['markers'] = Location.search('exact', selected_categories, searched_item, selected_item_ids, nav_params[:q])
        response['map_info']['postal'] = Location.search('postal', selected_categories, searched_item, selected_item_ids, nav_params[:q])
        response['map_info']['district'] = Location.search('district', selected_categories, searched_item, selected_item_ids, nav_params[:q])

        socket.send response.to_json(:include => { :ads => { :include =>  {:items => { :include => :category }}}})

      rescue Exception => e
        p e
        p e.backtrace
      end
    end

    socket
  end

end