#!/bin/bash

# Start and end dates for the loop
start_date="2014-01-07"
end_date="2015-02-04"

# Convert dates to UNIX timestamps
start_timestamp=$(date -d "$start_date" +%s)
end_timestamp=$(date -d "$end_date" +%s)

# Loop through each date
current_timestamp="$start_timestamp"
while [ "$current_timestamp" -le "$end_timestamp" ]; do
    # Convert current timestamp back to date format
    current_date=$(date -d "@$current_timestamp" +"%Y-%m-%d")

    # Print the current date being processed
    echo -e "Processing : $current_date ====="
    
    # Execute the Hive script for the current date
    hive --hiveconf date="$current_date" -f load_bands.sql >> load_bands.log 2>&1
    
    # Move to the next date
    current_timestamp=$((current_timestamp + 86400))  # Add one day in seconds (86400 seconds in a day)
done
