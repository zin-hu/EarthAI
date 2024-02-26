#!/bin/bash

# ============================================================================
# Usage Example:
# ./download_hdf.sh "AIRICRAD_6.7_0226_texas.txt" /nuke/hzin/airs/texas &
#
# To download from a single link:
# wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies \
# --keep-session-cookies "<url>" -P "download_directory"
# ============================================================================

# Check if url.txt argument is provided
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

# Run wget command with options
wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies -i "$url_file" -P "$download_directory"
