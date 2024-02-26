#!/bin/bash

# Check if username argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Assign username to variable
username=$1

# Prompt for password without echoing to the terminal
read -s -p "Enter password for $username: " password
echo

# Store current directory
current_dir=$(pwd)

# Change directory to home directory
cd ~

# Create .netrc file with NASA Earthdata credentials
echo "machine urs.earthdata.nasa.gov login $username password $password" > .netrc

# Restrict permissions of .netrc file
chmod 0600 .netrc

# Create .urs_cookies and .dodsrc files
touch .urs_cookies
touch .dodsrc

# Populate .dodsrc file with required configurations
echo "HTTP.NETRC=$HOME/.netrc" > .dodsrc
echo "HTTP.COOKIEJAR=$HOME/.urs_cookies" >> .dodsrc

# Run Python script
python3 "${current_dir}/auth.py"
