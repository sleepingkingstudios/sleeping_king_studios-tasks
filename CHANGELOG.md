# Changelog

## 0.3.0

- Fix deprecation warnings in Ruby 2.7.
- Add support for Thor 1.0.

## 0.2.0

### Ci

- Implement tasks for Jest.js, ESLint.
- Add --format option, configuration value for RSpec, RSpec (Each) tasks.

## 0.1.0

Initial commit.

- Implement SleepingKingStudios::Tasks::Task, TaskGroup.

### Apps

Tasks for managing multiple applications within a single repository. Each application can have a separate Gemfile and configuration.

- Implement tasks for installing and updating bundled gems.
- Implement tasks for running and aggregating CI steps across applications.

### Ci

Tasks for running and aggregating CI steps.

- Implement tasks for RSpec, Cucumber, RuboCop, SimpleCov, and running each RSpec file individually.

### File

Tasks for creating and managing source files.

- Implement task for generating new source files with template support and optional spec file.
