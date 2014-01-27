Feature: Building an application with the spell checker enabled

  Scenario: Build an application
    Given a fixture app "correct_spelling_app"
    When I run `middleman build`
    Then a directory named "build" should exist
    And the exit status should be 0
