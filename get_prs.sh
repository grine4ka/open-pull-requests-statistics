#!/bin/bash -e

# Get PRs starting from 2020-01-01
# gh cli uses GITHUB_TOKEN
# Such big limit to get most of PRs at first update
gh pr list --repo "Kotlin/kotlinx.serialization" \
    --state all --search "created:>2020-01-01" --limit 2000 \
    --json "number,closedAt,createdAt" \
    --jq '.[] | [.number, .closedAt, .createdAt] | @csv' > gh_prs.csv

# Timestamp column is needed only to overcome InfluxDB restrictions to 30 days retention policy
# Append incremented by 1 second timestamp to each line
timestamp_format="%Y-%m-%dT%H:%M:%SZ"
cat gh_prs.csv | while IFS= read -r line; do \
    timestamp=$(date -u +"$timestamp_format" -d "$timestamp + 1 second"); \
    echo "$line,\"$timestamp\""; \
done > prs.csv

# Add csv header
echo "number,closed_at,created_at,timestamp" > header.csv
cat header.csv prs.csv > combined.csv
mv combined.csv prs.csv
rm header.csv

# Remove extra files
rm gh_prs.csv
