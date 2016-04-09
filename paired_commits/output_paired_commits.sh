#!/bin/bash

# Assumes it is being run within a git repo.
# Outputs a comma-delimited list of files linked
# within distinct commits, with number of connections
# and percentage of overall.
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
git --no-pager log --name-status --no-merges | awk -f $MY_DIR/format_git_logs.awk
