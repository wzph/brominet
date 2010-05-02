Feature: Simple
  In order to play with brominet
  As an iPhone developer with testing needs
  I want to see how brominet interacts with cucumber

  Scenario: A Button
    Given a new run
    Then I should see a button labelled "A Button"

  # @failz
  # Scenario: Looking up stations
  #   Given a test server
  #   When I look up my stations
  #   Then I should see the stations "KNRK,KOPB"
  # 
  # @restart
  # Scenario: Remembering stations
  #   Given a list of radio stations "KBOO,KINK"
  #   And a test server
  #   When I restart the app
  #   Then I should see the stations "KBOO,KINK"
  # 
  # Scenario: Deleting stations
  #   Given a list of radio stations "KNRK,KOPB"
  #   When I delete the first station
  #   Then I should see the stations "KOPB"
