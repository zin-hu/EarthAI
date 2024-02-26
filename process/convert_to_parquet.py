"""Convert HDF5 data to Parquet format."""

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

            return [rad, lat, lon, time]
        
    except FileNotFoundError:
        print("File not found!")

    except Exception as e:
        print("An error occurred:", e)


def process_data_to_dataframe(data):
    """Process data and convert to DataFrame."""
    try:
        rad, lat, lon, time = data
        df = pd.DataFrame({
            'stime': [str(convert_to_timestamp(sec)) for 
                      sec in time.astype('float64').flatten()],
            'lat': lat.astype('float64').flatten(),
            'lon': lon.astype('float64').flatten(),
            'rad': rad.astype('float64').reshape(-1, 2645).tolist()
        })  
        return df
    
    except Exception as e:
        print("Error occurred while processing data:", e)


def save_dataframe_to_parquet(df, output_file):
    """Save DataFrame to Parquet file."""
    try:
        df.to_parquet(output_file, index=False)
        print("Data successfully saved to:", output_file)
    except Exception as e:
        print("Error occurred while saving data:", e)


def main():
    # Provide the path to your HDF5 file
    file_path = "../data/0131.h5"
    output_file = "../data/0131.parquet"

    # Read the HDF5 file
    print("Reading HDF5 file...")
    data = read_h5_data(file_path)

    if data:
        df = process_data_to_dataframe(data)
        
        if df is not None:
            save_dataframe_to_parquet(df, output_file)

if __name__ == "__main__":
    main()
