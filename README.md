# EarthAI

This repository contains the code and docs for the project "EarthAI".

## Data Collection

The data for this project is provided by AIRS, the Atmospheric Infrared Sounder on NASA's Aqua satellite, which gathers infrared energy emitted from Earth's surface and atmosphere globally on a daily basis. AIRS data are used by weather centers around the world to improve their forecasts, as well as scientists to study Earth's climate and weather. The data is available from the NASA GES DISC (Goddard Earth Sciences Data and Information Services Center) at this [link](https://disc.gsfc.nasa.gov/datasets?keywords=airs%20version%207&page=1&source=AQUA%20AIRS&processingLevel=1). There are two potential datasets we could use: [AIRICRAD_NRT 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_NRT_6.7/summary?keywords=airs%20version%207) and [AIRICRAD 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_6.7/summary?keywords=airs%20version%207). The former is the Near Real Time (NRT) dataset, which is available within 3 hours of observation but only for two weeks, and the latter is the standard dataset spanning from 2002.

## Data Preprocessing

The AIRS L1C files are written in HDF-EOS swath format. According to "V6.7_L1C_Product_User_Guide.pdf" in the `doc` folder, the recommended tool to visualize HDF-EOS files is [Panoply](https://www.giss.nasa.gov/tools/panoply/download/).

### Approach A: read HDF files and save as `parquet` files

To execute this approach, follow these steps:

0. **Without Docker**: The reason to use Docker is that some systems do not support `python3-gdal`, and simply installing with `pip install gdal` leads to build failure. The package `gdal` has better support for `conda` though. If the `gdal` library dependency could be resolved in another way, please skip the Docker part and go directly to step 3.

1. **Set Up Docker Environment**: Ensure Docker is installed and opened on your system. Then, build the Docker image using the provided Dockerfile:
    ```bash
    docker build -t earth:0.1 .
    ```

2. **Run Docker Container**: Start a Docker container from the built image, mapping the local directory containing the project files (`earthAI`) to the container's `/root/earthAI` directory:
    ```bash
    docker run -it --name earth -v $(pwd)/earthAI:/root/earthAI -d earth:0.1

    # Inside the container go to the project working directory
    cd /root/earthAI
    ```

3. **Execute Python Script**: Within the Docker container, install required Python packages, as specified in `requirements.txt`. Run the Python script `hdf2par.py` to convert HDF files to Parquet format:
    ```bash
    pip install -r requirements.txt
    python3 preprocess/hdf2par.py
    ```

4. **Output**: The script will process the HDF file (`data/0131.hdf`), extract the required data, and save it as Parquet format (`data/0131.01.parquet`).

**Note**:
- The provided Dockerfile sets up the necessary environment with Python and GDAL dependencies.
- Replace the example HDF file path (`data/0131.hdf`) to the actual location of the target HDF file within the container.
- Adjust the script and Dockerfile as needed for different file paths or dependencies.
