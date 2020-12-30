# SleepingKingStudios::Tasks [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tasks.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tasks)

**Note:** This project is deprecated, and will not receive further feature updates.

A toolkit providing an encapsulation layer around the Thor CLI library, with predefined tasks for development and continuous integration.

See also [https://github.com/erikhuda/thor](https://github.com/erikhuda/thor).

## Contribute

### GitHub

The canonical repository for this gem is on [GitHub](https://github.com/sleepingkingstudios/sleeping_king_studios-tasks).

## Task Classes

SleepingKingStudios::Tasks defines a wrapper around the Thor CLI.

### SleepingKingStudios::Tasks::Task

A class for encapsulating an individual Thor task. Provides built-in support for setting Thor metadata (task name, description, and options) and for automatically silencing output.

    class GreeterTask < SleepingKingStudios::Tasks::Task
      def self.description
        'Displays a cheery greeting!'
      end # class method description

      option :greeting,
        :type    => :String,
        :default => 'Greetings',
        :desc    => 'The greeting to use.'

      def call name
        say "Greetings, #{name}!"
      end # method call
    end # class

    GreeterTask.new({}).call('Alan')
    #=> 'Greetings, Alan!'

    GreeterTask.new('greeting' => 'Hello').call('Alan')
    #=> 'Hello, Dave!'

Command line arguments are passed in to the `#call` method as arguments, and options are passed in to the constructor and are available as an `options` instance method.

#### Class Methods

##### `::description`

Sets the description of the Thor task, which is displayed when running `thor help [COMMAND]`.

##### `::option(option_name, option_params)`

Defines an option for the task. For more information on task options, see [https://github.com/erikhuda/thor/wiki/Method-Options](https://github.com/erikhuda/thor/wiki/Method-Options).

##### `::task_name`

Sets the default name of the Thor task, which is used to call the task from the command line or displayed when running `thor list`. Note that the task group (see below) can override or alias the task name. Defaults to the underscored, unqualified class name, with any Task suffix also removed.

    GreeterTask.task_name
    #=> 'greeter'

    MyModule::DoSomethingTask.task_name
    #=> 'do_something'

    class TaskWithCustomName < SleepingKingStudios::Tasks::Task
      def self.task_name
        'custom_name'
      end # class method task_name
    end # class
    TaskWithCustomName.task_name
    #=> 'custom_name'

#### Instance Methods

##### `#call`

Executes the command. Can specify one or more arguments, which can be passed in from the command line.

##### `#options` (Private)

Exposes the options passed in from the command line in Hash format.

##### `#mute!` (Private)

Disables console output.

##### `#mute?` (Private) - Also `#muted?`

Checks if console output is disabled.

##### `#say` (Private)

Writes the given text to the console unless output is disabled.

### SleepingKingStudios::Tasks::TaskGroup

Exposes one or more tasks to the Thor interface.

    class SayTasks < SleepingKingStudios::Tasks::TaskGroup
      namespace :say

      task GreeterTask, :as => 'greet'
    end # class

    thor say:greet Alan
    #=> 'Greetings, Alan!'

#### Class Methods

##### `::namespace(name)`

Sets the namespace for the tasks in the group. For more information on namespaces, see [https://github.com/erikhuda/thor/wiki/Namespaces](https://github.com/erikhuda/thor/wiki/Namespaces).

##### `::task(definition, options = {})`

`param definition [Class]` A class that extends SleepingKingStudios::Task. When the task is called, an instance of the class will be created with the parsed command line options, and `#call` will be executed on the instance with the command line arguments (if any).

`option as [String]` The name of the task. If set, this overrides the `::task_name` method on the class.

Registers a task in the current namespace.

## Defined Tasks

SleepingKingStudios::Tasks also includes a set of predefined tasks for local development and continuous integration.

To include the predefined tasks, `load` (not `require`) the relevant files in your PROJECT_NAME.thor file at the root of your project directory.

### Configuration

SleepingKingStudios::Tasks has a number of configuration options, which can be set in your PROJECT_NAME.thor file.

    require 'sleeping_king_studios/tasks'

    SleepingKingStudios::Tasks.configure do |config|
      config.ci do |ci|
        ci.steps = %i(rspec cucumber)
      end # ci
    end # configure

The above code configures the `ci:steps` task to run the RSpec and Cucumber steps.

The following configuration options are defined:

`config.apps.ci.rspec [Hash]`: Step configuration for the RSpec step when running it across multiple applications (see Apps Tasks, below). All apps step configuration hashes have the same options:

- `class [String]`: The class defining the step task. Each app step task must take an application name and run the task for that application, unless the `global` option is set (see below). In either case, the step must return a results object.
- `require [String]`: The file path of the task for the step.
- `title [String]`: The title of the step, used in generating reports.
- `global [String]`: Defaults to false. If true, then the step applies to the entire repository, rather than to individual applications, and is added only to the Totals in the report.

`config.apps.ci.rubocop [Hash]`: Step configuration for the RuboCop step.

`config.apps.ci.simplecov [Hash]`: Step configuration for the RuboCop step.

`config.apps.ci.steps [Array]`: The names of the steps to run when calling `thor apps:ci:steps`. By default, the RSpec, RuboCop and SimpleCov steps are run.

`config.apps.config_file [String]`: The configuration file used to define the applications (see Apps Tasks, below). The default config file is 'applications.yml', in the root directory of your project.

`config.ci.cucumber [Hash]`: Step configuration for the Cucumber step. All ci step configuration hashes have the following options:

- `class [String]`: The class defining the step task. Each step task must take an optional list of files and run the task for matching files, or for all files relevant to that task if no files are specified. The step must return a results object.
- `require [String]`: The file path of the task for the step.
- `title [String]`: The title of the step, used in generating reports.

In addition, the cucumber step has the additional option:

- `default_files [Array]`: Files that are always loaded when running Cucumber, such as step definitions or support files. By default, this includes 'step_definitions.rb' and the 'step_definitions' directory inside 'features'.

`config.ci.rspec [Hash]`: Step configuration for the RSpec step. Has the same options as `config.ci.cucumber`, above, except for the aforementioned `default_files` option. In addition, the RSpec task has the following option:

- `format [String]`: The RSpec formatter used to format the spec results. Defaults to 'documentation'.

`config.ci.rspec_each [Hash]`: Step configuration for the RSpec Each step. Has the same configuration options as the RSpec step.

`config.ci.rubocop [Hash]`: Step configuration for the RuboCop step.

`config.ci.simplecov [Hash]`: Step configuration for the RuboCop step.

`config.ci.steps [Array]`: The names of the steps to run when calling `thor ci:steps`. By default, the RSpec, RuboCop and SimpleCov steps are run.

`config.file.template_paths`: The paths for templates to use in generating new files with the `thor file:new` command. Each template path is checked in order for a template matching the file to be created, and if a match is found the file is pregenerated using the given template, which is evaluated using `erubi`.

### Apps Tasks

    load 'sleeping_king_studios/tasks/apps/bundle/tasks.thor'

    load 'sleeping_king_studios/tasks/apps/ci/tasks.thor'

Tasks defined in SleepingKingStudios::Tasks::Apps are intended for a particular use case, namely a project where multiple "applications" (or more generally, self-contained groupings of code) are developed together in a single directory or repository. These tasks allow the developer to maintain separate environments, including different Gemfiles.

Tasks in the `apps:bundle` namespace provide support for multiple Gemfiles, running `bundler` tasks for each unique gemfile specified.

Tasks in the `apps:ci` namespace run CI actions for each application and generate a report on the results.

#### application.yml

Each of these tasks depends on a configuration file which defines the applications. By default, this file is located at the project root directory as 'applications.yml'; this can be changed in the configuration (see Configuration, above).

Here is a sample application.yml file:

    my_gem-core: {}
    my_gem-rails:
      name: "Rails integration"
      gemfile: "gemfiles/rails"
    my_gem-sinatra:
      name: "Sinatra integration"
      gemfile: "gemfiles/sinatra"
    my_gem-utilities:
      source_files:
      - lib/utils
      spec_files:
      - spec/utils

This file defines four applications - two core libraries and two integrations. Each of the integrations has a custom name set, which will be used when generating CI reports, and a gemfile, which allows those applications to have isolated environments with their own dependencies. The utilities application also specifies where the source and spec files for that application can be found.

The following options can be configured for each application:

`gemfile [String]` The gemfile used for the application. The `app:bundle` commands will install or upgrade the gems for each gemfile listed in applications.yml, and tasks for an application (including CI) will run using the specified bundle.

`name [String]` The name of the application; used in generating CI reports. Defaults to the application's key, e.g. 'my_gem-core' in the example above.

`source_files [Array]` A list of files and/or directories where the source code of the application is defined. By default, source files are expected in either apps/APP_NAME or lib/APP_NAME.

`spec_files [Array]` A list of directories where spec files for the application are defined. By default, spec files are expected either in apps/APP_NAME/spec or spec/APP_NAME.

#### Bundle - Install

    thor apps:bundle:install

`param *applications [Array]` An optional array of application keys (see application.yml, above). If any applications are specified, the task will only run for the specified application or applications.

Equivalent to running `BUNDLE_GEMFILE=gemfile bundle install` for each unique gemfile in applications.yml.

#### Bundle - Update

    thor apps:bundle:update

`param *applications [Array]` An optional array of application keys (see application.yml, above). If any applications are specified, the task will only run for the specified application or applications.

Equivalent to running `BUNDLE_GEMFILE=gemfile bundle update` for each unique gemfile in applications.yml.

#### Ci - RSpec

    thor apps:ci:rspec
    # Runs RSpec for each application.

`option --quiet [Boolean]` Suppress console output. Defaults to false.

`param *applications [Array]` An optional array of application keys (see application.yml, above). If any applications are specified, the task will only run for the specified application or applications.

Runs the RSpec suite for each specified application, using the Gemfile and spec files configured for that application, and generates a report listing the results for each application.

#### Ci - RuboCop

    thor apps:ci:rubocop
    # Runs RuboCop for each application.

`option --quiet [Boolean]` Suppress console output. Defaults to false.

`param *applications [Array]` An optional array of application keys (see application.yml, above). If any applications are specified, the task will only run for the specified application or applications.

Runs the RuboCop linter for each specified application, using the Gemfile and source and spec files configured for that application, and generates a report listing the results for each application.

#### Ci - SimpleCov

    thor apps:ci:simplecov

Aggregates the most recent SimpleCov results and returns the results as a results object.

#### Ci - Steps

    thor apps:ci:steps
    # Runs each configured CI step for each application and generates a report.

`option --except [Array]` Skips the specified steps.

`option --only [Array]` Runs only the specified steps.

`option --quiet [Boolean]` If set, the results of each step will not be printed to the console.

`param *applications [Array]` An optional array of application keys (see application.yml, above). If any applications are specified, the task will only run for the specified application or applications.

Runs each configured CI step (see Configuration, above) and generates a report on the results of each step for each application, as well as an aggregate total. The task will exit with an error code if any of the steps returns a results object that identifies as failing, so this task can be used in a CI provider to aggregate the results of different steps into a pass/fail condition.

### Ci Tasks

    load 'sleeping_king_studios/tasks/ci/tasks.thor'

Tasks defined in SleepingKingStudios::Tasks::Ci are designed to support continuous integration, encapsulating common testing requirements (running specs, linting, checking code coverage) with a common interface.

#### Cucumber

    thor ci:cucumber
    # Runs Cucumber on the entire feature suite.

    thor ci:cucumber features/path/to/files
    # Runs Cucumber for the features in features/path/to/files

`option --quiet [Boolean]` If set, the Cucumber results will not be printed to the console.

`option --raw [Boolean]` If true, the returned results will be in Hash format rather than a results object.

`param *files [Array]` An optional array of file paths. If any files or directories are given, Cucumber will run only the indicated features.

Runs the Cucumber feature suite and returns the results as either a results object or a Hash. If the `--quiet` option is not set, the results will also be printed to the console.

#### RSpec

    thor ci:rspec
    # Runs RSpec on the entire test suite.

    thor ci:rspec spec/path/to/files
    # Runs RSpec for the specs in spec/path/to/files

`option --coverage [Boolean]` Sets or clears the ENV['COVERAGE'] environment variable; configure your code coverage library to check for this variable. If the option is not set, then coverage is run by default if no file arguments are given (see below), and not run if any files are given, indicating that only part of the spec suite is to be run.

`option --gemfile [String]` The path to the gemfile to use when running the tests. If no gemfile is specified, will run the test with the gemfile at ENV['BUNDLE_GEMFILE'], which defaults to /Gemfile.

`option --quiet [Boolean]` If set, the RSpec results will not be printed to the console.

`option --raw [Boolean]` If true, the returned results will be in Hash format rather than a results object.

`param *files [Array]` An optional array of file paths. If any files or directories are given, RSpec will run only the indicated specs.

Runs the RSpec test suite and returns the results as either a results object or a Hash. If the `--quiet` option is not set, the results will also be printed to the console.

#### RSpec (Each)

    thor ci:rspec_each
    # Runs each spec file individually.

    thor ci:rspec spec/path/to/files
    # Runs each spec file in spec/path/to/files individually.

`option --quiet [Boolean]` If set, the results of each file will not be printed to the console.

`option --raw [Boolean]` If true, the returned results will be in Hash format rather than a results object.

`param *files [Array]` An optional array of file paths. If any files or directories are given, RSpec will run only the indicated specs.

For each spec file, runs the file in RSpec separately and aggregates the number of passing, pending, failing, and errored files. Running the files separately can expose issues, particularly around missing dependencies, and is recommended for gems or libraries.

#### RuboCop

    thor ci:rubocop
    # Runs the RuboCop linter.

    thor ci:rubocop path/to/files
    # Runs the RuboCop linter on the files at path/to/files.

`option --quiet [Boolean]` If set, the RuboCop results will not be printed to the console.

`option --raw [Boolean]` If true, the returned results will be in Hash format rather than a results object.

`param *files [Array]` An optional array of file paths. If any files or directories are given, RSpec will run only the indicated specs.

Runs the RuboCop linter and returns the results as either a results object or a Hash. If the `--quiet` option is not set, the results will also be printed to the console.

#### SimpleCov

    thor ci:simplecov
    # Retrieves the most recent SimpleCov results.

Retrieves the most recent SimpleCov results and returns the results as a results object.

#### Steps

    thor ci:steps
    # Runs each configured CI step and generates a report.

`option --except [Array]` Skips the specified steps.

`option --only [Array]` Runs only the specified steps.

`option --quiet [Boolean]` If set, the results of each step will not be printed to the console.

Runs each configured CI step (see Configuration, above) and generates a report on the results of each step. The task will exit with an error code if any of the steps returns a results object that identifies as failing, so this task can be used in a CI provider to aggregate the results of different steps into a pass/fail condition.

### File Tasks

    load 'sleeping_king_studios/tasks/file/tasks.thor'

#### New

    thor file:new lib/path/to/file.rb
    # Creates a new Ruby file at lib/path/to/file.rb and spec/path/to/file_spec.rb

`option --dry-run [Boolean]` Lists the file(s) to create, but does not change the filesystem. Defaults to false.

`option --force [Boolean]` Overwrite the files if the files already exist. Defaults to false.

`option --prompt [Boolean]` Prompt the user for confirmation before creating the files. Defaults to false.

`option --quiet [Boolean]` Suppress console output. Defaults to false.

`option --spec [Boolean]` If set, a spec file will be automatically generated. Defaults to true. Use `--spec=false` or `--no-spec` to disable the spec file generation.

`option --verbose [Boolean]` If set, additional information will be printed to the console. Ignored if `--quiet` is set. Defaults to false.

`param file_path [String]` The path to the file to be created.

Creates a new file at the specified file path, generating any intermediate directories as needed. Unless the `--no-spec` option is set, also automatically creates a spec file in /spec with the same relative path, e.g. at /spec/path/to/file_spec.rb.

By default, uses the pregenerated templates which create an empty module definition and RSpec description with pending flag. You can specify an alternate template directory in the configuration (see Configuration, above).
