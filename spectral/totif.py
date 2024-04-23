import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import griddata
import tifffile
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

    d0 = griddata(
        data[data[:, 3] == 0, :2],
        data[data[:, 3] == 0, 2],
        (grid_lat, grid_lon),
        method='nearest'
    )
    d1 = griddata(
        data[data[:, 3] == 1, :2],
        data[data[:, 3] == 1, 2],
        (grid_lat, grid_lon),
        method='nearest'
    )
    d2 = griddata(
        data[data[:, 3] == 2, :2],
        data[data[:, 3] == 2, 2],
        (grid_lat, grid_lon),
        method='nearest'
    )

    dstack = np.stack((d0, d1, d2))
    mean_array = np.mean(dstack, axis=0)
    d = np.round(mean_array).astype(int)

    tifffile.imwrite(output_tiff_file, d)



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Interpolate and save data as TIFF.")
    parser.add_argument("input_file", help="Path to the input data file.")
    parser.add_argument("output_tiff_file", help="Path to save the output TIFF file.")
    args = parser.parse_args()

    interpolate_and_save(args.input_file, args.output_tiff_file)
