"""Convert HDF5 data to Parquet format."""

# ============================================================================
# Usage:
#   python3 convert_to_parquet.py /path/to/file.h5
# ============================================================================

import os
import argparse
import h5py
import pandas as pd
from datetime import datetime, timedelta


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

            rad = data['Data Fields']['radiances'][:]
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

            return [rad, lat, lon, time], swath_attributes
        
    except FileNotFoundError:
        print("File not found!")

    except Exception as e:
        print("An error occurred:", e)


def process_data_to_dataframe(data):
    """Process data and convert to DataFrame."""
    try:
        rad, lat, lon, time = data
        df = pd.DataFrame({
            #'stime': [str(convert_to_timestamp(sec)) for 
            #          sec in time.astype('float64').flatten()],
            #'lat': lat.astype('float64').flatten(),
            #'lon': lon.astype('float64').flatten(),
            'rad': rad.astype('float64').reshape(-1, 2645).tolist()
        })  
        return df
    
    except Exception as e:
        print("Error occurred while processing data:", e)


def save_dataframe_to_parquet(df, output_file):
    """Save DataFrame to Parquet file."""
    try:
        df.to_parquet(output_file, index=False)
    except Exception as e:
        print("Error occurred while saving data:", e)


def main(filename):
    """Main function."""
    # Extracting directory path
    directory = os.path.dirname(filename)
    # Extracting file name without extension
    file_name_without_extension = os.path.splitext(
        os.path.basename(filename))[0]

    # Constructing output file paths
    output_file = f"{directory}/{file_name_without_extension}.parquet"
    output_file_metadata = \
        f"{directory}/{file_name_without_extension}_attr.parquet"

    # Read the HDF5 file
    data, metadata = read_h5_data(filename)

    if data:
        df_data = process_data_to_dataframe(data)
        
        if df_data is not None:
            save_dataframe_to_parquet(df_data, output_file)

    if metadata:
        df_metadata = pd.DataFrame([metadata])
        save_dataframe_to_parquet(df_metadata, output_file_metadata)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Process H5 data and save it to Parquet format.")
    parser.add_argument(
        "filename", 
        help="Name of the H5 file.")
    args = parser.parse_args()
    main(args.filename)
