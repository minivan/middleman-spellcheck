Feature: Building an application with the spell checker allowed for some words

  Scenario: The spelling errors in the allowed words is ignored
    Given a fixture app "allow_app"
    When I run `middleman build`
    Then the exit status should be 0
