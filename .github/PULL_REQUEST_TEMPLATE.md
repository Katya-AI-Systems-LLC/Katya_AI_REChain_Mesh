name: Pull Request
description: Submit a pull request to contribute to the project
title: "[PR]: "
labels: ["pull-request"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for your contribution! Please fill out this template to help us review your pull request.

  - type: textarea
    id: description
    attributes:
      label: Description
      description: Describe what changes you made and why
      placeholder: |
        ## Summary
        [Brief description of changes]

        ## Motivation
        [Why these changes are needed]

        ## Changes Made
        - [Change 1]
        - [Change 2]
        - [Change 3]
    validations:
      required: true

  - type: dropdown
    id: type
    attributes:
      label: Type of Change
      description: What type of change does this PR introduce?
      options:
        - Bug fix
        - New feature
        - Breaking change
        - Documentation update
        - Code improvement/refactoring
        - Test addition/update
        - CI/CD improvement
        - Other
    validations:
      required: true

  - type: dropdown
    id: module
    attributes:
      label: Related Module
      description: Which module does this PR affect?
      options:
        - Blockchain
        - Gaming
        - IoT
        - Social
        - UI/Theme
        - Infrastructure
        - Testing
        - Documentation
        - Other
    validations:
      required: true

  - type: checkboxes
    id: testing
    attributes:
      label: Testing
      description: Please confirm the following about testing
      options:
        - label: I have added unit tests for new code
        - label: I have added widget tests for UI changes
        - label: I have tested on a real device (not just emulator)
        - label: I have tested on multiple platforms if applicable
        - label: All existing tests still pass
        - label: I have run the app and verified it works

  - type: checkboxes
    id: documentation
    attributes:
      label: Documentation
      description: Please confirm the following about documentation
      options:
        - label: I have updated README.md if needed
        - label: I have added code comments for complex logic
        - label: I have updated API documentation if APIs changed
        - label: I have added changelog entry
        - label: I have updated any relevant guides

  - type: textarea
    id: breaking-changes
    attributes:
      label: Breaking Changes
      description: Describe any breaking changes and migration steps
      placeholder: |
        ## Breaking Changes
        [Describe what breaks and how to migrate]

        ## Migration Steps
        1. [Step 1]
        2. [Step 2]
        3. [Step 3]

  - type: textarea
    id: screenshots
    attributes:
      label: Screenshots
      description: Add screenshots or videos showing the changes
      placeholder: |
        Before/After screenshots:
        [Add images or describe visual changes]

        Demo video:
        [Add link or describe functionality]

  - type: textarea
    id: additional
    attributes:
      label: Additional Context
      description: Add any other context about the pull request.

  - type: checkboxes
    id: checklist
    attributes:
      label: Final Checklist
      description: Please confirm all items before submitting
      options:
        - label: Code follows project style guidelines
        - label: Code has been formatted with `dart format`
        - label: No linting errors (`flutter analyze` passes)
        - label: All tests pass (`flutter test` passes)
        - label: Changes are backward compatible (or breaking changes are documented)
        - label: I have read and followed the contributing guidelines
        - label: I am willing to address any review feedback
