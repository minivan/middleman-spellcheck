Feature: Building an application with the spell checker enabled for some paths

  Scenario: The spelling errors in the parameters that do not match the path are ignored
    Given a fixture app "spelling_path_app"
    When I run `middleman build`
    Then the exit status should be 0
