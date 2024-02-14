# EarthAI

This repository contains the code and docs for the project "EarthAI".

## Data Collection

The data for this project is provided by AIRS, the Atmospheric Infrared Sounder on NASA's Aqua satellite, which gathers infrared energy emitted from Earth's surface and atmosphere globally on a daily basis. AIRS data are used by weather centers around the world to improve their forecasts, as well as scientists to study Earth's climate and weather. The data is available from the NASA GES DISC (Goddard Earth Sciences Data and Information Services Center) at this [link](https://disc.gsfc.nasa.gov/datasets?keywords=airs%20version%207&page=1&source=AQUA%20AIRS&processingLevel=1). There are two potential datasets we could use: [AIRICRAD_NRT 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_NRT_6.7/summary?keywords=airs%20version%207) and [AIRICRAD 6.7](https://disc.gsfc.nasa.gov/datasets/AIRICRAD_6.7/summary?keywords=airs%20version%207). The former is the Near Real Time (NRT) dataset, which is available within 3 hours of observation but only for two weeks, and the latter is the standard dataset spanning from 2002.

## Data Preprocessing

The AIRS L1C files are written in HDF-EOS swath format. According to "V6.7_L1C_Product_User_Guide.pdf" in the `doc` folder, the recommended tool to visualize HDF-EOS files is [Panoply](https://www.giss.nasa.gov/tools/panoply/download/).
