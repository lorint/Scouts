Feature: SalespersonChannel

  Background:
    Given the "Salesperson" channel has been established

  # ------------------------------------------------------------------------------
  # As a user, when I visit the salesperson page,
  # a websocket connection should be established on the "salesperson" channel
  # and streaming should begin to the client
  # and one grid object should be established that gets re-used for additional connecting users.

  Scenario: A user views the page for the first time
    When a client subscribes to the channel ... Then streaming is established to "salesperson" ... And the "Salesperson" model receives "construct"


  # ------------------------------------------------------------------------------
  # As a user, when I visit the salesperson page,
  # grid data should be regularly broadcast

  Scenario: Data is sent as a user views the page
    When a client subscribes to the channel ... Then grid data is broadcast


  # ------------------------------------------------------------------------------
  # As a user, when a grid is fully solved and I send the "again" message,
  # a new grid is started and data is regularly broadcast to all connected users.

  Scenario: A user runs the algorithm again
    When the user selects "again" ... Then no change happens in regard to streaming ... And the "Salesperson" model receives "construct"

  Scenario: Data is sent when a user runs the algorithm again
    When a grid is complete and the client selects "again" ... Then a new grid is built and data is broadcast


  # ------------------------------------------------------------------------------
  # As a user, when connecting and a grid is in process of being solved,
  # a count of the number of connections is maintained, and existing grid data is broadcast.

  Scenario: A second user connects while an existing user is viewing live updates
    When two clients subscribe ... Then the grid object they see should be the same ... And the reference count is 2


  # ------------------------------------------------------------------------------
  # As the only connected user, when a grid is in process of being solved and I disconnect,
  # the grid processing is interrupted.

  Scenario: A user connects and then disconnects
    When a client subscribes to the channel ... And soon unsubscribes ... Then the "Salesperson" model receives "deconstruct"

  Scenario: A user connects and then disconnects
    When a client subscribes to the channel ... And soon unsubscribes ... Then the reference count is 0 ... And the top grid is marked as is_done


  # ------------------------------------------------------------------------------
  # As one of multiple connected users, when a grid is in process of being solved and I disconnect,
  # the grid processing is not interrupted, and other connected users continue to receive broadcast data.

  Scenario: Two users connect and then one disconnects
    When two clients subscribe ... And one soon unsubscribes ... Then the reference count is 1 ... And the top grid is not marked as is_done ... And data continues to be broadcast
