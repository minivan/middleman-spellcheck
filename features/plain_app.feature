Feature: Launching a plain application

  Scenario: Shows a simple page
    Given the Server is running at "plain_app"
    When I go to "/"
    Then I should see 'Hello, test'
