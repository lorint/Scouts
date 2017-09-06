# Support for #receive and #allow
require 'cucumber/rspec/doubles'
require_relative '../support/actioncable_connection_stub'
require_relative '../support/actioncable_server_stub'

# Yes, I know that Cucumber is not often used in this way :)
# (After all, these scenarios all use RSpec's with_temporary_scope!)
# Because the goal is to test interaction between the SalespersonChannel
# and the Salesperson model, I felt that it was broader than just unit
# testing, and opted for this approach.

Given(/^the "([^"]*)" channel has been established$/) do |channel_name|
  @channel = Object.const_get("#{channel_name}Channel").new(TestConnection.new({}, TestServer.new), {})
  current_grid = Salesperson.grid
  current_grid.interrupt unless current_grid.nil?
end

When(/^a client subscribes to the channel \.\.\. Then streaming is established to "([^"]*)" \.\.\. And the "([^"]*)" model receives "([^"]*)"$/) do |stream_name, model_name, method_name|
  RSpec::Mocks.with_temporary_scope do
    model = Object.const_get(model_name)
    expect(@channel).to receive(:stream_from).with(stream_name)
    expect(model).to receive(method_name.to_sym)
    @channel.subscribe_to_channel
  end
end

When(/^a client subscribes to the channel \.\.\. Then grid data is broadcast$/) do
  RSpec::Mocks.with_temporary_scope do
    current_channel = nil
    current_info = nil
    allow(ActionCable.server).to receive(:broadcast) do |channel, info|
      current_channel = channel
      current_info = info
      Thread.exit  # So it doesn't run incessantly
    end
    @channel.subscribe_to_channel
    # Time out if we don't see anything in 2 seconds
    200.times do
      break unless current_info.nil?
      sleep 0.01
    end
    expect(current_channel).to eq("salesperson")
    expect(current_info).to be_a(Hash)
    expect(current_info[:distance]).to be_a(Float)
    expect(current_info[:points]).to be_a(Array)
    expect(current_info[:points].first).to be_a(Array)
    expect(current_info[:points].first.count).to eq(2)
  end
end

When(/^the user selects "([^"]*)" \.\.\. Then no change happens in regard to streaming \.\.\. And the "([^"]*)" model receives "([^"]*)"$/) do |action_name, model_name, method_name|
  RSpec::Mocks.with_temporary_scope do
    expect(@channel).to_not receive(:stream_from)
    model = Object.const_get(model_name)
    expect(model).to receive(method_name.to_sym)
    @channel.perform_action({"action" => action_name})
  end
end

When(/^a grid is complete and the client selects "([^"]*)" \.\.\. Then a new grid is built and data is broadcast$/) do |action_name|
  RSpec::Mocks.with_temporary_scope do
    current_grid = nil
    allow(ActionCable.server).to receive(:broadcast) do |channel, info|
      current_grid = Salesperson.grid
      Thread.exit  # So it doesn't keep trying to solve
    end

    @channel.subscribe_to_channel

    # Time out if we don't see anything in 2 seconds
    200.times do
      break unless current_grid.nil?
      sleep 0.01
    end

    expect(current_grid).to be_a(GeneticGrid)
    first_oid = current_grid.object_id
    current_grid.top[:is_done] = true
    current_grid = nil

    @channel.perform_action({"action" => action_name})

    200.times do
      break unless current_grid.nil?
      sleep 0.01
    end

    # Ensure this grid is a different object
    expect(current_grid).to be_a(GeneticGrid)
    expect(first_oid).to_not eq(current_grid.object_id)
  end
end

When(/^two clients subscribe \.\.\. Then the grid object they see should be the same \.\.\. And the reference count is 2$/) do
  RSpec::Mocks.with_temporary_scope do
    @channel.subscribe_to_channel
    first_oid = Salesperson.class_variable_get(:@@grid).object_id
    @channel.subscribe_to_channel
    second_oid = Salesperson.class_variable_get(:@@grid).object_id

    expect(first_oid).to eq(second_oid)
    expect(Salesperson.num_clients).to eq(2)
  end
end

When(/^a client subscribes to the channel \.\.\. And soon unsubscribes \.\.\. Then the "([^"]*)" model receives "([^"]*)"$/) do |model_name, method_name|
  RSpec::Mocks.with_temporary_scope do
    @channel.subscribe_to_channel

    model = Object.const_get(model_name)
    expect(model).to receive(method_name.to_sym)
    @channel.unsubscribe_from_channel
  end
end

When(/^a client subscribes to the channel \.\.\. And soon unsubscribes \.\.\. Then the reference count is 0 \.\.\. And the top grid is marked as is_done$/) do
  RSpec::Mocks.with_temporary_scope do
    @channel.subscribe_to_channel
    @channel.unsubscribe_from_channel

    allow(ActionCable.server).to receive(:broadcast) do |channel, info|
      current_info = info
    end

    # Count up if we get more than 1 final broadcast while waiting a full second
    current_info = nil
    num_broadcasts = 0
    100.times do
      unless current_info.nil?
        break if (num_broadcasts += 1) > 1
        current_info = nil
      end
      sleep 0.01
    end

    expect(Salesperson.num_clients).to eq(0)
    expect(Salesperson.grid.top[:is_done]).to eq(true)

    # Usually 0, but at most one more final message
    expect(num_broadcasts).to be < 2
  end
end

When(/^two clients subscribe \.\.\. And one soon unsubscribes \.\.\. Then the reference count is 1 \.\.\. And the top grid is not marked as is_done \.\.\. And data continues to be broadcast$/) do
  RSpec::Mocks.with_temporary_scope do
    @channel.subscribe_to_channel
    @channel.subscribe_to_channel
    @channel.unsubscribe_from_channel

    current_info = nil
    allow(ActionCable.server).to receive(:broadcast) do |channel, info|
      current_info = info
      Thread.exit  # So it doesn't run incessantly
    end
    200.times do
      break unless current_info.nil?
      sleep 0.01
    end

    expect(Salesperson.num_clients).to eq(1)
    expect(Salesperson.grid.top[:is_done]).to be_falsey
    expect(current_info).to be_a(Hash)
  end
end
