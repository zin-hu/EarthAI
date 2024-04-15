#!/bin/bash

# ============================================================================
# This script is used to convert HDF files to H5 files and then to 
# parquet files. The parquet files are then loaded into the database.
# Usage:
#   ./pipeline.sh <HDF_FOLDER_PATH> <H5_FOLDER_PATH>
# ============================================================================

# Function to count total number of files in url.txt
count_files() {
    find "$1" -maxdepth 1 -name "*.hdf" | wc -l
}

# Function to process a single file
process_file() {
    hdf_file="$1"
    h5_folder_path="$2"
    progress="$3"

    # Extract date and granule number from the file name
    file_name=$(basename "$hdf_file")
    date=$(echo "$file_name" | awk -F'[_.]' '{print $2"-"$3"-"$4}')
    granule_number=$(echo "$file_name" | awk -F'[_.]' '{print $5}')

    echo "... $progress - Date: $date, Granule Number: $granule_number"

    # Convert HDF to H5
    h5_file="$h5_folder_path/airs_"$date"_"$granule_number".h5"
    echo "... $progress - Converting to H5: $h5_file"
    ./h4toh5 "$hdf_file" "$h5_file"

    # Process the H5 file
    echo "... $progress - Converting to Parquet: $h5_file"
    python3 convert_to_parquet.py "$h5_file"

    # Load the parquet file into the database
    echo "... $progress - Loading parquet file into database"
    hive \
    --hiveconf date=$date \
    --hiveconf granule=$granule_number \
    --hiveconf path=$h5_folder_path \
    -f load_data.sql 2>/dev/null
}

# Check if correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <HDF_FOLDER_PATH> <H5_FOLDER_PATH>"
    exit 1
fi

# Assign arguments to variables
hdf_folder_path="$1"
h5_folder_path="$2"

# Check if HDF folder exists
if [ ! -d "$hdf_folder_path" ]; then
    echo "Error: $hdf_folder_path does not exist."
    exit 1
fi

# Check if H5 folder exists
if [ ! -d "$h5_folder_path" ]; then
    echo "Error: $h5_folder_path does not exist."
    exit 1
fi

# Get the total number of HDF files in the folder
total_files=$(count_files "$hdf_folder_path")

# Initialize counter
count=0

# Loop through each HDF file in the folder
for hdf_file in "$hdf_folder_path"/*.hdf; do
    if [ -e "$hdf_file" ]; then
        # Increment counter
        ((count++))

        # Call function to process the file in the background
        progress="${count}/${total_files}"
        echo "Processing file $progress%: $hdf_file at $(date)"
        process_file "$hdf_file" "$h5_folder_path" "$progress" &

    else
        echo "No HDF files found in $hdf_folder_path"
        exit 1
    fi
done
