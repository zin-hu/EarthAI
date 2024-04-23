"""Convert HDF5 data to csv format."""

# ============================================================================
# Usage:
#   python3 convert_to_csv.py /path/to/<file>.h5
# ============================================================================

import os
import argparse
import h5py
import pandas as pd
from datetime import datetime, timedelta
import csv


def convert_to_timestamp(seconds):
    """Convert seconds since start date to timestamp."""
    start_date = datetime.strptime("1993-01-01T00:00:00Z", 
                                   "%Y-%m-%dT%H:%M:%SZ")
    return start_date + timedelta(seconds=seconds)


def read_h5_data(file_path):
    """Read data from HDF5 file."""
    try:
        with h5py.File(file_path, 'r') as file:
            data = file['L1C_AIRS_Science']

            spectral = data['Data Fields']['spectral_clear_indicator'][:]
            lat = data['Geolocation Fields']['Latitude'][:]
            lon = data['Geolocation Fields']['Longitude'][:]
            time = data['Geolocation Fields']['Time'][:]

            # Retrieve swath attributes
            swath_attributes = {}
            for t in data['Swath Attributes']:
                if (isinstance(data['Swath Attributes'][t], h5py.Dataset) 
                        and not t.startswith("_FV")):
                    swath_attributes[t] = \
                        data['Swath Attributes'][t]['AttrValues'][0]

            return [spectral, lat, lon, time], swath_attributes
        
    except FileNotFoundError:
        print("File not found!")

    except Exception as e:
        print("An error occurred:", e)


def process_data_to_csv_data(data):
    """Process data and convert to DataFrame."""
    try:
        spectral, lat, lon, time = data
        csv_data = spectral.astype('int64').reshape(-1, 12150)
        return csv_data[0]
    
    except Exception as e:
        print("Error occurred while processing data:", e)


def save_data_to_csv(csv_data, output_file):
    """Save DataFrame to csv file."""
    #try:
    with open(output_file, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(csv_data)
    return
    #except Exception as e:
    #    print("Error occurred while saving data:", e)


def main(filename):
    """Main function."""
    # Check if directory exists
    directory = '../data_csv'
    os.makedirs(directory, exist_ok=True)
    # Extracting file name without extension
    file_name_without_extension = os.path.splitext(
        os.path.basename(filename))[0]

    # Constructing output file paths
    output_file = f"{directory}/{file_name_without_extension}.csv"
    output_file_metadata = \
        f"{directory}/{file_name_without_extension}_attr.csv"

    # Read the HDF5 file
    data, metadata = read_h5_data(filename)

    if data:
        csv_data = process_data_to_csv_data(data)
        if csv_data is not None:
            save_data_to_csv(csv_data, output_file)

    if metadata:
        df_metadata = pd.DataFrame([metadata])
        save_data_to_csv(df_metadata, output_file_metadata)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Process H5 data and save it to csv format.")
    parser.add_argument(
        "filename", 
        help="Name of the H5 file.")
    args = parser.parse_args()
    main(args.filename)