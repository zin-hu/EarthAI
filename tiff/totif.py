import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import griddata
import tifffile
import rasterio
import argparse

def interpolate_and_save(input_file, output_tiff_file):
    # Load data
    data = np.loadtxt(input_file)

    # Get a standard grid
    lat, lon = data[:, 0], data[:, 1]
    min_lat = min(lat)
    max_lat = max(lat)
    min_lon = min(lon)
    max_lon = max(lon)

    resolution = 0.05
    grid_lat, grid_lon = np.meshgrid(
        np.arange(min_lat, max_lat, resolution),
        np.arange(min_lon, max_lon, resolution)
    )

    # Interpolate data
    d_list = []
    for i in range(3):
        selected_data = data[data[:, 8] == i]
        d = griddata(
            selected_data[:, :2],   # Coordinates
            selected_data[:, 2:8],  # Values
            (grid_lat, grid_lon),
            method='nearest'
        )
        d_list.append(d)

    d = np.concatenate(d_list, axis=2).transpose(2, 0, 1)

    # Rescale and convert to uint8
    min_vals = np.min(d, axis=(1, 2), keepdims=True)
    max_vals = np.max(d, axis=(1, 2), keepdims=True)
    rad_scaled = ((d - min_vals) / (max_vals - min_vals)) * 255
    rad_scaled = rad_scaled.astype(np.uint8)

    # Save as TIFF
    tifffile.imwrite(output_tiff_file, rad_scaled, photometric='rgb')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Interpolate and save data as TIFF.")
    parser.add_argument("input_file", help="Path to the input data file.")
    parser.add_argument("output_tiff_file", help="Path to save the output TIFF file.")
    args = parser.parse_args()

    interpolate_and_save(args.input_file, args.output_tiff_file)
