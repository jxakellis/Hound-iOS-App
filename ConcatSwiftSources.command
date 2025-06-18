#!/bin/bash
# Concatenate all .swift files in this directory (recursively) into all_swift_sources.txt
find "$(dirname "$0")" -type f -name "*.swift" -print0 | xargs -0 cat > "$(dirname "$0")/all_swift_sources.txt"
[ $? -eq 0 ] && exit