## Tasks

- add missing specs for full coverage
- task names should be strings, not symbols
- formalize (public) task names as _Task, _task.rb ?
- integration testing for RSpec, RSpecEach tasks
  - sample spec files with known output(s)
- extract common Results object superclass
  - defaults for #passing?, #pending?, #failing?, #errored?
  - implement #==, #merge, #to_h
  - simple DSL for hash-access-with-default method definitions
    - also updates #to_h
  - delegate #to_s to #summary

### Apps

### CI

- task ci:cucumber
  - Configuration settings
  - enable for ci:steps
  - with file, automatically load default files (step_definitions)
    - configurable

- task ci:rspec: |

  Add --env option

- task ci:rspec_each: |

  Add --env option

  Add --gemfile option

- task ci:steps: |

  Add --diff option

    only runs ci steps on changed files/parts of files.

  Checks for configuration file and runs CI steps, concatenating the results.

### Files

- task file:new [filename]: |

  add smarter/configurable pattern matching
  e.g. configure _controller.rb to use controller.erb template

  (optional) opens files in text editor?

- task file:move [source] [target]

### Git

- task git:delete-merged
