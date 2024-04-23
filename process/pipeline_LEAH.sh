#!/bin/bash

# Function to count total number of files in h5_folder_path
count_files() {
    find "$1" -maxdepth 1 -name "*.h5" | wc -l
}

# Function to process a single file
process_file() {
    h5_file="$1"
    h5_folder_path="$2"
    progress="$3"

    # Extract date and granule number from the file name
    file_name=$(basename "$h5_file")
    date=$(echo "$file_name" | awk -F'[_.-]' '{print $2"-"$3"-"$4}')
    granule_number=$(echo "$file_name" | awk -F'[_.-]' '{print $5}')

    #echo "... $progress - Date: $date, Granule Number: $granule_number"

    python convert_to_csv_LEAH.py "$h5_folder_path"/"$h5_file"

    hive \
    --hiveconf date=$date \
    --hiveconf granule=$granule_number \
    --hiveconf path=$h5_folder_path \
    -f load_data_LEAH.sql 2>/dev/null
}

# Check if correct number of arguments are passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <H5_FOLDER_PATH>"
    exit 1
fi

# Assign arguments to variables
h5_folder_path="$1"

# Check if H5 folder exits
if [ ! -d "$h5_folder_path" ]; then
    echo "Error: $h5_folder_path does not exist."
    exit 1
fi

# Get the total number of H5 files in the folder
total_files=$(count_files "$h5_folder_path")

# Initialize counter
count=0

# Loop through each H5 file in the folder
for h5_file in "$h5_folder_path"/*.h5; do
    if [ -e "$h5_file" ]; then
        # Increment counter
        ((count++))

        progress="${count}/${total_files}"
        echo "Processing file $progress: $h5_file at $(date)"
        process_file "$h5_file" "$h5_folder_path" "$progress" &
    
    else
        echo "No H5 files found in $h5_folder_path"
        exit 1
    fi
done

