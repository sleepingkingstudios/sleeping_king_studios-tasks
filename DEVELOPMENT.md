## Tasks

- add missing specs for full coverage
- task names should be strings, not symbols
- formalize (public) task names as _Task, _task.rb ?
- remove erubis dependency

### Apps

- extract Configuration object for applications?

- step(s) runner: |

  RSpecResults#merge
  RSpecWrapper - extends ApplicationsTask, invokes Ci::RSpec with config
  Configuration.apps.ci.steps
  StepsRunner - runs each step for each application

  generalization of steps:
  - handling apps-specific config?
    - source files, spec directories, etc.
    - subclass regular tasks with addl. configuration?
      - e.g. a task for "run STEP for one application"

  two strategies:
  - for each application, run each configured step
  - for each configured step, run each application
    - requires preprocess to determine configured steps?

### CI

- task ci:steps: |

  Add --diff option

    only runs ci steps on changed files/parts of files.

  Checks for configuration file and runs CI steps, concatenating the results.

  Add --only, --except

    only runs filtered CI steps

### Files

- task new [filename]: |

  add smarter/configurable pattern matching
  e.g. configure _controller.rb to use controller.erb template

  (optional) opens files in text editor?

### Git

- task git:delete-merged
