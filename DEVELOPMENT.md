## Tasks

- add missing specs for full coverage
- task names should be strings, not symbols
- formalize (public) task names as _Task, _task.rb ?
- remove erubis dependency

### Apps

- task apps:ci:rspec_each: |

  Also add support for apps:ci:steps.

### CI

- task ci:rspec: |

  Add --env option

- task ci:rspec_each: |

  Add --env option

  Add --gemfile option

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
