#!/bin/bash

# This is done to update info about each PR that was updated
# Clear the bucket
influx bucket delete --name pr_statistics

# Create it again
influx bucket create --name pr_statistics --retention 30d

# Add data to newly created bucket
influx write -b pr_statistics -f prs.csv \
  --header "#constant measurement,pull_requests" \
  --header "#datatype long,string,string,dateTime:RFC3339"