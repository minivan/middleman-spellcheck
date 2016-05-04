Feature: Building an application with the spell checker while ignoring specific directories

  Scenario: The spelling errors in the parameters that are within ignored directories are skipped
    Given a fixture app "ignored_dirs_app"
    When I run `middleman build`
    Then the exit status should be 0
