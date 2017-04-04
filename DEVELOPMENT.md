## Tasks

### CI

- task ci (*paths): |

  Arguments:
  - *paths: the file paths to test. If omitted, runs ci steps on all directories.

  Options:
  - --diff: only runs ci steps on changed files/parts of files.

  Checks for configuration file and runs CI steps, concatenating the results.

### Files

- task new [filename]: |

  Arguments:
  - filename: the name of the file to create

  Options:
  - --dry-run
  - --no-spec
  - --template

  Prerun:
  - list directories to create
  - list files to create
  - prompt for confirmation (Y/n)

  Run:
  - create needed directories (if relative to current directory)
  - create file by filename
  - add filename as comment at top of file
  - (LATER) add require statement
  - (LATER) add module definition
  - (LATER) add class definition
  - if .rb file and not in spec directory
    - create needed directories in ./spec
    - create spec file by filename
    - add filename as comment at top of spec file
    - (LATER) add require statement
    - (LATER) add RSpec.describe block with pending

### Git

- task git:delete-merged
