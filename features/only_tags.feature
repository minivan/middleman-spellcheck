Feature: Building an application with the spell checker enabled for some tags

  Scenario: The spelling errors in other tags are ignored
    Given a fixture app "only_tags_app"
    When I run `middleman build`
    Then the exit status should be 0
