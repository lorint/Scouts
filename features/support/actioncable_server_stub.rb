# ActionCable::Server::Base
class TestServer
  include Enumerable
  def keys
    [:x]
  end
  def each(&block)
    [:x].each do |server|
      block.call(server)
    end
  end
  def event_loop
    ActionCable::Connection::StreamEventLoop.new
  end
end
