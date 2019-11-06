## Tasks

### Version 0.3.0

- add --retry option to Cucumber task.

### Future Tasks

- add documentation for "ci" option in applications.yml
- integration testing for RSpec, RSpecEach tasks
  - sample spec files with known output(s)
- extract common Results object superclass
  - defaults for #passing?, #pending?, #failing?, #errored?
  - implement #==, #merge, #to_h
  - simple DSL for hash-access-with-default method definitions
    - also updates #to_h
  - delegate #to_s to #summary
- configurable "base" namespace

#### Apps

#### CI

- configurable --format options for CI steps

- task ci:rspec_each: |

  Default to displaying --format=progress.

- task ci:steps: |

  Add --diff option

    only runs ci steps on changed files/parts of files.

- task ci:yard: |

  Checks the number of undocumented modules, classes, constants, methods, etc.

### Files

- task file:new [filename]: |

  add smarter/configurable pattern matching
  e.g. configure _controller.rb to use controller.erb template

  (optional) opens files in text editor?

- task file:move [source] [target]: |

  Alias as file:refactor?

#### Git

- task git:delete-merged
