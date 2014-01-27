Feature: Building an application with the spell checker enabled

  Scenario: When the spelling is correct
    Given a fixture app "correct_spelling_app"
    When I run `middleman build`
    Then the exit status should be 0

  Scenario: When the spelling is incorrect
    Given a fixture app "incorrect_spelling_app"
    When I run `middleman build`
    Then the exit status should be 1
