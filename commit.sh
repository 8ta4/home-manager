#!/bin/bash

# Get git diff --cached output
diff=$(git diff --cached)

# Concatenate the output with the string
output="Suggest me a few good commit messages for my commit.\n\`\`\`\n$diff\n\`\`\`\n\nOutput results as a list, not more than 6 items."

# Output results as a list, not more than 6 items
echo -e "$output" | pbcopy
