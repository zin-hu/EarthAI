from osgeo import gdal
import pyarrow as pa
import pyarrow.parquet as pq



# Open the HDF file and list the subdatasets
f = gdal.Open('../data/0131.hdf')
f.GetSubDatasets()

# Open the radiances subdataset
radiances = gdal.Open('HDF4_EOS:EOS_SWATH:"../data/0131.hdf":L1C_AIRS_Science:radiances')
rad = radiances.ReadAsArray()
(rad.min(), rad.max(), rad.mean(), rad.std())

# Convert the first spectrum to parquet
pa_table = pa.table({"data": rad[0, 0]})
pq.write_table(pa_table, "../data/0131.01.parquet")
