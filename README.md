# EarthAI

This repository contains the code and docs for the project "EarthAI".

## Data Collection

The data for this project is provided by AIRS, the Atmospheric Infrared Sounder on NASA's Aqua satellite, which gathers infrared energy emitted from Earth's surface and atmosphere globally on a daily basis. AIRS data are used by weather centers around the world to improve their forecasts, as well as scientists to study Earth's climate and weather. The data is available from the NASA GES DISC (Goddard Earth Sciences Data and Information Services Center) at this [link](https://disc.gsfc.nasa.gov/datasets?keywords=airs%20version%207&page=1&source=AQUA%20AIRS&processingLevel=1). There are two potential datasets we could use: [AIRICRAD_NRT 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_NRT_6.7/summary?keywords=airs%20version%207) and [AIRICRAD 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_6.7/summary?keywords=airs%20version%207). The former is the Near Real Time (NRT) dataset, which is available within 3 hours of observation but only for two weeks, and the latter is the standard dataset spanning from 2002.

To download data for a certain area, go to the website mentioned above, use either a circle or square selection tool to select the location range, specify the time range, and a list of file links will be available as a result. In the `download` folder of this repo, the list of file links are stored in the text files, each collection registered in the `yaml` file.

Then give execution access to `auth.sh` and run it with your username at NASA Earthdata as the argument. The purpose of this procedure is to get authentication for downloading the HDF files. Last, run the `download_hdf.sh`. Please see usage inside the file.

## Data Preprocessing

The AIRS L1C files are written in HDF-EOS swath format. According to "V6.7_L1C_Product_User_Guide.pdf", the recommended tool to visualize HDF-EOS files is [Panoply](https://www.giss.nasa.gov/tools/panoply/download/).

To retrieve the information from the HDF files, the first attempt was to read using `GDAL`. However, `GDAL` was not designed to be an expert in dealing with HDF4 files. Although it's able to retrieve the main dataset (radiances, etc.) from HDF-EOS files, it's very challenging to get a peek at the geolocation and timestamp of the corresponding instrument shutters. Instead, in the second attempt, HDF5 files were converted to HDF5 (or H5) format. H5 files are more modern and well-supported cross programming languages and platforms.

Different from regular images, infrared images of the AIRS dataset have 2645 channels. For a granule, the unit of satellite sweeping operations, the geo dimension is 135 by 90. The H4 or H5 file for such a granule could be several hundred Megabytes or even overl 1GB, if decompressed. It is thus processed, retrieving only the necessary information, and compressed into the parquet format for further processing and analysis.

For an exploration of the dataset, see `check_data_info.ipynb` in the `process` folder. `convert_to_parquet.py` offers the data selection and transformation methods, as well as conversion operations. You can easily download an HDF file from NASA (links provided in the last section), use `./h4toh5 <hdf_filename> <h5_filename>` to convert it to H5 format, and then use `convert_to_parquet` to play with the output file. A convenient tool to read and check parquet information is `parquet-tools`, which could be installed using `pip`.

Note that granules and geo locations are not one-to-one correspondence. On the same day, the instrument fly over the same area multiple times, and the fly-over cover the area from different angles with different shapes, and will be labeled with different granule numbers.

To facilitate more complex data processing and analysis, the parquet files are loaded in a Hive database.
