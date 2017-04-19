## Tasks

- add missing specs for full coverage
- task names should be strings, not symbols

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

### Git

- task git:delete-merged
