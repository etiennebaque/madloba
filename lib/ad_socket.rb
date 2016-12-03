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

        if prefix == 'new'
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