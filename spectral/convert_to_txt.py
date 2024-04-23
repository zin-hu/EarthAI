import os
import argparse
import h5py
import numpy as np

def save_spec(input_file, output_file):
    """Read data from HDF5 file, and save to txt."""
    try:
        with h5py.File(input_file, 'r') as file:
            data = file['L1C_AIRS_Science']

            spec = data['Data Fields']['spectral_clear_indicator'][:].flatten()
            lat = data['Geolocation Fields']['Latitude'][:].flatten()
            lon = data['Geolocation Fields']['Longitude'][:].flatten()

            data_array = np.column_stack((lat, lon, spec))
            np.savetxt(output_file, data_array, delimiter="\t", fmt='%f')
        
    except FileNotFoundError:
        print("File not found!")

    except Exception as e:
        print("An error occurred:", e)

def main(filename):
    """Main function."""
    # Extracting directory path
    directory = os.path.dirname(filename)
    # Extracting file name without extension
    file_name_without_extension = os.path.splitext(
        os.path.basename(filename))[0]

    # Constructing output file paths
    output_file = f"{directory}/{file_name_without_extension}.txt"

    # Save spectral data to text file
    save_spec(filename, output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Retrieve spectral indicator from H5 file and save it to txt.")
    parser.add_argument(
        "filename", 
        help="Name of the H5 file.")
    args = parser.parse_args()
    main(args.filename)

