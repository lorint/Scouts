require_relative './actioncable_pubsub_stub'

# This is the minimal ActionCable connection stub to make the features pass
# ApplicationCable::Connection
class TestConnection
  attr_reader :identifiers, :logger, :server, :pubsub

  def initialize(identifiers_hash = {}, server = nil)
    @identifiers = identifiers_hash.keys
    @logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(StringIO.new))
    # Used during unsubscribe
    @pubsub = TestPubSub.new(self)

    # This is an equivalent of providing `identified_by :identifier_key` in ActionCable::Connection::Base subclass
    identifiers_hash.each do |identifier, value|
      define_singleton_method(identifier) do
        value
      end
    end
    @server = server
  end

  # Called when confirming the subscription to the client
  def transmit(stuff)
  end
end
