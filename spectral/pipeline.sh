#!/bin/bash

# ============================================================================
# This script is used to extract spectral indicator from H5 files and then to 
# txt files. The txt files are then loaded into the database.
# Usage:
#   ./pipeline.sh <H5_FOLDER_PATH>
# ============================================================================

# Function to process a single file

process_file() {
    h5_folder_path="$1"
    h5file="$2"

    # Extract date and granule number from the file name
    file_name=$(basename "$h5file")
    date=$(echo "$file_name" | awk -F'[_.]' '{print $2}')
    granule_number=$(echo "$file_name" | awk -F'[_.]' '{print $3}')

    echo "... $progress - Date: $date, Granule Number: $granule_number"

    # Convert H5 to txt
    txt_file="$h5_folder_path/airs_${date}_${granule_number}.txt"
    echo "... $progress - Converting to txt: $txt_file"
    python3 convert_to_txt.py "$h5file"

    # Load the txt file into the database
    echo "... $progress - Loading txt file into database"
    hive \
    --hiveconf date="$date" \
    --hiveconf granule="$granule_number" \
    --hiveconf path="$h5_folder_path" \
    -f load_spectral.sql 2>/dev/null
}


# Check if correct number of arguments are passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <H5_FOLDER_PATH>"
    exit 1
fi

# Assign arguments to variables
h5_folder_path="$1"

# Check if H5 folder exists
if [ ! -d "$h5_folder_path" ]; then
    echo "Error: $h5_folder_path does not exist."
    exit 1
fi

# Loop through each HDF file in the folder
for h5file in "$h5_folder_path"/*.h5; do
    if [ -e "$h5file" ]; then
        process_file "$h5_folder_path" "$h5file"

    else
        echo "No H5 files found in $hdf_folder_path"
        exit 1
    fi
done
