#!/bin/bash

# ============================================================================
# Usage Example:
# ./download_hdf.sh "AIRICRAD_6.7_0226_texas.txt" /nuke/hzin/airs/texas
#
# To download from a single link:
# wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies \
# --keep-session-cookies "<url>" -P "download_directory"
# ============================================================================


# Function to count total lines in a file
count_lines() {
    echo $(wc -l < "$1")
}

# Check if url.txt and download_directory arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <url.txt> <download_directory>"
    exit 1
fi

# Assign arguments to variables
url_file=$1
download_directory=$2

# Check if url.txt file exists
if [ ! -f "$url_file" ]; then
    echo "Error: $url_file not found."
    exit 1
fi

# Check if download directory exists
if [ ! -d "$download_directory" ]; then
    echo "Error: $download_directory does not exist."
    exit 1
fi

# Count total lines in url.txt
total_lines=$(count_lines "$url_file")

# Initialize counter
count=0

# Run wget command with options
wget \
--load-cookies ~/.urs_cookies \
--save-cookies ~/.urs_cookies \
--keep-session-cookies \
-i "$url_file" -P "$download_directory" \
> /dev/null 2>&1 &
wget_pid=$!

# Monitor progress
while kill -0 "$wget_pid" >/dev/null 2>&1; do
    downloaded=$(ls -1 "$download_directory" | wc -l)
    echo -ne "Downloaded $downloaded of $total_lines files\r"
    sleep 5
done

# Final progress message
downloaded=$(ls -1 "$download_directory" | wc -l)
echo "Downloaded $downloaded of $total_lines files"